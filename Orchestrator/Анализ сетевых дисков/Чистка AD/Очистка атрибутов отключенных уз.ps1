Import-Module ActiveDirectory
$server = "domain2"
$PrimaryGroup = get-adgroup -server $server "Уволенные" -properties @("primaryGroupToken")
$OUs = "OU1", "OU2"
$userlist = foreach ($OU in $OUs) {
    Get-ADUser -server $server -SearchBase $OU -Properties OfficePhone, Manager, Company, Department, Title, EmployeeID, PrimaryGroup, MemberOf -filter * | Where-Object { ($_.enabled -eq $false) -and (($_.PrimaryGroup -ne $PrimaryGroup.DistinguishedName) -or ($_.OfficePhone -ne $null) -or ($_.Manager -ne $null) -or ($_.Company -ne $null) -or ($_.Department -ne $null) -or ($_.Title -ne $null) -or ($_.EmployeeID -ne $null)) }
}
$GoodBody = @()
$GoodUsers = @()
$BadBody = @()
$BadUsers = @()
$table = @()
$Date = get-date -Format yyyy-MM-dd

#Подключение к БД
[Void][Reflection.Assembly]::LoadWithPartialName('System.Data')
[Data.SqlClient.SqlConnection]$DBCnn = "Server=Servername; Database=BDNAME; Integrated Security=True;"
$DBCnn.Open()

foreach ($user in $userlist) {
    ###Записываем старые атрибуты в БД
    $DBCmd = $DBCnn.CreateCommand()
    $DBCmd.CommandText = @"
    USE [BDName]
    INSERT INTO [dbo].[Old_AD_Attribute]([Name],[SamAccountName],[OfficePhone],[Manager],[Company],[Department],[Title],[EmployeeID],[Date])
    VALUES (
    $("'"+$user.name+"'"),$("'"+$("$server"+"\"+"$($user.SamAccountName)")+"'"),$("'"+$user.OfficePhone+"'"),$("'"+$user.Manager+"'"),$("'"+$user.Company+"'"),$("'"+$user.Department+"'"),$("'"+$user.Title+"'"),$("'"+$user.EmployeeID+"'"),$("'"+$date+"'")
    )
"@
    $SQL = $null
    $SQL = New-Object Data.DataTable;
    $DBCmd.CommandTimeout = 0;
    $SQL.Load($DBCmd.ExecuteReader())

    ###Проверка записи в БД
    #$DBCmd=$DBCnn.CreateCommand()
    $DBCmd.CommandText = @"
    SELECT [Name],[SamAccountName],[Date]
    FROM [ForSCO].[dbo].[Old_AD_Attribute]
    $("WHERE SamAccountName='"+"$($($server)+"\"+$($user.SamAccountName))"+"' and date='"+$date+"'")
"@
    $SQL = $null
    $SQL = New-Object Data.DataTable;
    $DBCmd.CommandTimeout = 0;
    $SQL.Load($DBCmd.ExecuteReader())
    if ([string]$sql -notlike $null) {
        $GoodUsers += $user
    }
    else {
        $BadUsers += $user
    }
}

###Отключение от БД
$DBCnn.Close()

###Очистка атрибутов
$problem = @() #нет прав
$problem2 = @() #уз переместили

if ($GoodUsers.count -ge 1) {
    $GoodBody += "<b>Очищены учетные записи:</b>"
    $GoodBody += "<table><tr><td><b>ФИО</td></b><td><b>Учетная запись</td></b></tr>"
    foreach ($GoodUser in $GoodUsers) {
        try {
            Set-ADUser -server $server -Identity $GoodUser -OfficePhone $null -Manager $null -Company $null -Department $null -Title $null -EmployeeID $null -ErrorAction Ignore
            $GoodBody += "<tr><td>$($GoodUser.name)</td><td>$($server+"\"+$GoodUser.SamAccountName)</td></tr>"
        }
        catch [Microsoft.ActiveDirectory.Management.ADException] {
            $poroblem += $GoodUser
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            $problem2 += $GoodUser
        }
    }
    $GoodBody += "</table>"
    $GoodBody += "<br>"
    $GoodBody += "<hr>"
    if (($GoodUsers.count - ($problem.Count + $problem2.count)) -ne $GoodUsers.count) {
        $GoodBody += "Всего учетных записей добавлено в базу данных - <b>$($GoodUsers.count)</b>"
        $GoodBody += "<br>Кол-во возникщих проблем - <b>$($problem.Count + $problem2.count)</b>"
        if ($problem.count -ge 1) {
            $GoodBody += "<br><b>Нет прав на изменение учетных записей:</b>"
            $GoodBody += "<table><tr><td><b>ФИО</td></b><td><b>Учетная запись</td></b></tr>"
            $GoodBody += $problem | ForEach-Object { "<tr><td>"; $_.name; "</td><td>"; $($server + "\" + $_.SamAccountName); "</td></tr>" }
            $GoodBody += "</table><br><br>Вероятнее всего необходимо восстановить наследование прав на учетных записях"
        }
        if ($problem2.count -ge 1) {
            $GoodBody += "<br><b>Учетные записи были перемещены из технической OU:</b>"
            $GoodBody += "<table><tr><td><b>ФИО</td></b><td><b>Учетная запись</td></b></tr>"
            $GoodBody += $problem | ForEach-Object { "<tr><td>"; $_.name; "</td><td>"; $($server + "\" + $_.SamAccountName); "</td></tr>" }
            $GoodBody += "</table><br><br>Дополнительных действий со стороны отдела системного администрирования не требуется"
        }
        $GoodBody += "<hr>"
    }
}

if ($BadUsers.count -ge 1) {
    $BadBody += "<b>Не удалось добавить учетные записи в базу данных:</b>"
    $BadBody += "<table><tr><td><b>ФИО</td></b><td><b>Учетная запись</td></b></tr>"
    $BadBody += $BadUsers | ForEach-Object { "<tr><td>"; $_.name; "</td><td>"; $($server + "\" + $_.SamAccountName); "</td></tr>" }
    $BadBody += "</table><br><br> Необходима диагностика со стороны отдела системного администрирования"
    $BadBody += "<hr>"
}
###Собираем отчет
$table += "Добрый день, отчет об очистке атрибутов Active Directory уволенных сотрудников в домене <b>$($server)</b>"
$table += "<br>Критерии очистки учетной записи: учетная запись выключена и находится в технической OU"
$table += "<br>OU для текущего домена - <b>$([string]$OUs)</b>"
$table += "<br>"
$table += "<hr>"
if ($GoodBody.count -ge 1) {
    $table += $GoodBody
}
if ($BadBody.count -ge 1) {
    $table += $BadBody
}
$table += "<br>Сервер базы данных - v00-sql-001<br>База данных - forsco<br>Таблица - dbo.Old_AD_Attribute"
$table += "<br>Выполнено под уз $(whoami) на сервере $($env:COMPUTERNAME)"
[string]$table
