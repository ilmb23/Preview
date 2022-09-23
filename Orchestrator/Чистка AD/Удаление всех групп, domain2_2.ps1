###
Import-Module ActiveDirectory
$server = "domain2"
$serverbd = "ServerFQDN"
$BD = "BDName"
$BDTable = "Old_AD_Groups"
$BDColumns = "[Name],[SamAccountName],[Group],[Date]"
$Date = get-date -Format yyyy-MM-dd
$PrimaryGroup = get-adgroup -server $server "Уволенные" -properties @("primaryGroupToken")
$OUs = "OU=Уволенные,DC=mosoblbank,DC=local"
$Result = @() #Объекты для загрузки в базу данных
$BadObj = @() #Не удалось добавить объект в базу данных
$GoodUsers = @() #Массив для добавления в группу "Уволенные"
$BadUsers = @() #Не удалось добавить в группу "Уволенные"
$GoodUsersInGroup = @()#Массив для чистки всех групп кроме группы "уволенные"
$Table = @()#Массив для отчета

###Выгружаем пользователей
$userlist = foreach ($OU in $OUs) {
    Get-ADUser -server $server -SearchBase $OU -Properties PrimaryGroup, MemberOf -filter * | Where-Object { ($_.enabled -eq $false) -and (($_.PrimaryGroup -ne $PrimaryGroup.DistinguishedName) -or ($_.MemberOf.count -ge 1)) }
}

###Выгружаем группы
foreach ($user in $userlist) {
    foreach ($group in ((Get-ADPrincipalGroupMembership $user -Server $server | Where-Object { ($_.name -ne "Domain Users") -or ($_.name -ne "Уволенные") }).name)) {
        $Result += New-Object psobject -Property @{
            ФИО            = $user.name
            SamAccountName = $($server + "\" + $user.SamAccountName)
            Group          = $($server + "\" + $group)
        }
    }
}

###Подключаемся к БД
[Void][Reflection.Assembly]::LoadWithPartialName('System.Data')
[Data.SqlClient.SqlConnection]$DBCnn = "Server=$serverbd; Database=$bd; Integrated Security=True;"
$DBCnn.Open()

###Задачи с БД
foreach ($obj in $result) {
    ##Загрузка данных в БД
    $DBCmd = $DBCnn.CreateCommand()
    $DBCmd.CommandText = @"
    USE [$($BD)]
    INSERT INTO [dbo].[$($BDTable)]($BDColumns)
    VALUES (
    $("'"+$obj.ФИО+"'"),$("'"+$obj.SamAccountName+"'"),$("'"+$obj.Group+"'"),$("'"+$date+"'")
    )
"@
    $SQL = $null
    $SQL = New-Object Data.DataTable;
    $DBCmd.CommandTimeout = 0;
    $SQL.Load($DBCmd.ExecuteReader())

    ##Проверка данных в БД
    $DBCmd.CommandText = @"
    SELECT [Name],[SamAccountName],[Date]
    FROM [$($BD)].[dbo].[$($BDTable)]
    $("WHERE SamAccountName='"+"$($obj.SamAccountName)"+"' and date='"+$date+"'")
"@
    $SQL = $null
    $SQL = New-Object Data.DataTable;
    $DBCmd.CommandTimeout = 0;
    $SQL.Load($DBCmd.ExecuteReader())
    if ([string]$sql -like $null) {
        $BadObj += $obj
    }
}

###Отключение от БД
$DBCnn.Close()

###Убираем ползователей где есть ошибки с загрузкой в бд из массива $userlist
if ($BadObj.count -ge 1) {
    foreach ($user in $userlist) {
        if ($user.SamAccountName -notin $($BadObj | ForEach-Object { $_.samaccountname.replace("$server\", "") } | Select-Object -Unique)) {
            $GoodUsers += $user
        }
    }
}
else {
    $GoodUsers += $userlist
}

###Задачи с группой "Уволенные"
foreach ($user in $GoodUsers ) {
    ##Добаваляем пользователя в группу "Уволенные"
    if (($user.MemberOf -notcontains $PrimaryGroup.DistinguishedName) -and ($user.PrimaryGroup -ne $PrimaryGroup.DistinguishedName) ) {
        try {
            Add-ADGroupMember $PrimaryGroup $user -Server $server -ErrorAction Ignore
            Start-Sleep -Seconds 15
        }
        catch {
            $BadUsers += $user | Add-Member -Name Error -MemberType NoteProperty -Value "Не удалось добавить в группу $server\$($PrimaryGroup.name)" -Force -PassThru
        }
    }
    ##Назначаем группу "Уволенные" группой по умолчанию
    if ($user.PrimaryGroup -ne $PrimaryGroup.DistinguishedName) {
        try {
            Set-ADUser $user -replace @{primaryGroupID = $PrimaryGroup.primaryGroupToken } -Server $server -ErrorAction Ignore
            Start-Sleep -Seconds 15
        }
        catch {
            $BadUsers += $user | Add-Member -Name Error -MemberType NoteProperty -Value "Не удалось изменить основную группу" -Force -PassThru
        }
    }
}

###Убираем ползователей где есть ошибки с группами из массива $GoodUsers
if ($BadUsers.count -ge 1) {
    $BadUsers = $BadUsers | Select-Object -Unique
    foreach ($user in $GoodUsers) {
        if ($user.SamAccountName -notin $($BadUsers | ForEach-Object { $_.samaccountname } )) {
            $GoodUsersInGroup += $user
        }
    }
}
else {
    $GoodUsersInGroup += $GoodUsers
}

###Удаление групп
foreach ($user in $GoodUsersInGroup) {
    try {
        Remove-ADPrincipalGroupMembership $user -Server $server -MemberOf $(Get-ADPrincipalGroupMembership $user -server $server | Where-Object { $_.Name -ne $PrimaryGroup.Name }) -Confirm:$False -ErrorAction Ignore
    }
    catch {
        $BadUsers += $user | Add-Member -Name Error -MemberType NoteProperty -Value "Не удалось удалить группы" -Force -PassThru
    }
}

###Отчет:
$table += "Добрый день, отчет об очистке групп Active Directory уволенных сотрудников в домене <b>$($server)</b>"
$table += "<br>Критерии очистки учетной записи: учетная запись выключена и находится в технической OU"
$table += "<br>OU для текущего домена - <b>$([string]$OUs)</b>"
$table += "<br>"
$table += "<hr>"
$table += "Обнаружено объектов для записи в базу данных - <b>$($Result.count)</b>"
if ($BadObj.Count -ge 1) {
    $table += "<br>Всего объектов добавлено - <b>$($Result.Count - $BadObj.count)</b>"
}
else {
    $table += "<br>Все объекты были успешно добавлены"
}
$table += "<br>"
$table += "<hr>"
if ($BadObj.count -ge 1) {
    $table += "Кол-во объектов которых не удалось добавить в базу данных - <b>$($BadObj.count)</b> "
    $table += "<br>Детализация:"
    $table += "<table><tr><td><b>ФИО</td></b><td><b>Учетная запись</b></td><b><td>Группа</td></b></tr>"
    $table += $BadObj | ForEach-Object { "<tr><td>"; $_.ФИО; "</td><td>"; $($server + "\" + $_.SamAccountName); "</td><td>"; $_.group; "</td></tr>" }
    $table += "</table><br><br> Необходима диагностика со стороны отдела системного администрирования"
    $table += "<br>"
    $table += "<hr>"
}
if ($BadUsers.Count -ge 1) {
    $table += "Кол-во объектов которые не были обработаны - <b>$($Badusers.count)</b>"
    $table += "<br>Детализация:"
    $table += "<table><tr><td><b>ФИО</td></b><td><b>Учетная запись</b></td><b><td>Ошибка</td></b></tr>"
    $table += $Badusers | ForEach-Object { "<tr><td>"; $_.name; "</td><td>"; $($server + "\" + $_.SamAccountName); "</td><td>"; $_.error; "</td></tr>" }
    $table += "</table><br><br> Необходима диагностика со стороны отдела системного администрирования"
    $table += "<br>"
    $table += "<hr>"
}
$table += "<br>"
$table += "<br>Сервер базы данных - $serverbd"
$table += "<br>База данных - $BD"
$table += "<br>Таблица - dbo.$BDTable"
$table += "<br>Выполнено под уз $(whoami) на сервере $($env:COMPUTERNAME)"
[string]$table