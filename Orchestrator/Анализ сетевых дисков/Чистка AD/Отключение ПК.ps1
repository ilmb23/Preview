<#
Clear-Host
$Error.clear()
#>
Import-Module ActiveDirectory
###Переменные под задачу
$server = "domain2"
$Day = 150
$DestenationOU = 'OU1'
$serverbd = "ServerFQDN"
$BD = "BDNAME"
$BDTable = "Old_AD_Comp"
$BDColumns = "[Name],[CanonicalName],[OperatingSystem],[LastLogonDate],[Date]" #тут все строго

$Date = get-date -Format yyyy-MM-dd
$BadObj = @() #Массив для ошибок
$GoodComp = @() #Массив ПК для переноса
$goodcomp2 = @() #Массив успехно выключенных ПК
$MailBody = @()
$Table = @()#Массив для отчета

$excludelist = "

COMPNAME1
COMPNAME2

" -split "\n" | ForEach-Object { $_.trim() } | Where-Object { $_ }

###Выгружаем ПК
Import-Module ActiveDirectory
$cl = Get-ADComputer -Filter * -Properties "CanonicalName", "LastLogonDate", "OperatingSystem" -Server $server | Where-Object { $_.enabled -eq $true } | Where-Object { $_.CanonicalName -notlike "*Serv*" } | Where-Object { $_.CanonicalName -notlike "*Серв*" } | Where-Object { $_.CanonicalName -notlike "*GoldenImages*" } | Where-Object { $_.OperatingSystem -like "*Windows*" } | Where-Object { $_.OperatingSystem -notlike "*Serv*" } | Where-Object { $_.CanonicalName -notlike "*Переговорные*" } | where-Object { $_.LastLogonDate -le $((get-date).AddDays(-$day)) } | Where-Object { $_.name -notin $excludelist }
$MailBody += "<br>Обнаружено объектов для записи в базу данных - <b>$($cl.count)</b>"

###Подключаемся к БД
[Void][Reflection.Assembly]::LoadWithPartialName('System.Data')
[Data.SqlClient.SqlConnection]$DBCnn = "Server=$serverbd; Database=$bd; Integrated Security=True;"
$DBCnn.Open()

###Задачи с БД
foreach ($obj in $cl) {
    ##Загрузка данных в БД
    $DBCmd = $DBCnn.CreateCommand()
    $DBCmd.CommandText = @"
    USE [$($BD)]
    INSERT INTO [dbo].[$($BDTable)]($BDColumns)
    VALUES (
    $("'"+$obj.name+"'"),$("'"+$obj.canonicalname+"'"),$("'"+$obj.OperatingSystem+"'"),$("'"+$obj.LastLogonDate+"'"),$("'"+$date+"'")
    )
"@
    $SQL = $null
    $SQL = New-Object Data.DataTable;
    $DBCmd.CommandTimeout = 0;
    $SQL.Load($DBCmd.ExecuteReader())

    ##Проверка данных в БД
    $DBCmd.CommandText = @"
    SELECT [Name],[Date]
    FROM [$($BD)].[dbo].[$($BDTable)]
    $("WHERE Name=$("'"+$obj.name+"'") and date='"+$date+"'")
"@
    $SQL = $null
    $SQL = New-Object Data.DataTable;
    $DBCmd.CommandTimeout = 0;
    $SQL.Load($DBCmd.ExecuteReader())
    if ([string]$sql -like $null) {
        $BadObj += $obj | Add-Member -Name Error -MemberType NoteProperty -Value "Не удалось записать в БД" -Force -PassThru
    }
}

###Отключение от БД
$DBCnn.Close()

###Убираем ПК где есть ошибки с загрузкой в бд из массива $cl
if ($BadObj.count -ge 1) {
    $i = 1
    foreach ($c in $cl) {
        if ($c.name -notin $($BadObj | ForEach-Object { $_.name } )) {
            $GoodComp += $c
            $i++
        }
    }
    $MailBody += "<br>Не удалось добаить в бд - <b>$($cl.count - $i)</b>"
}
else {
    $GoodComp += $cl
    $MailBody += "<br>Все объекты были успешно добавлены в БД"
}
$MailBody += "<hr>"

###Выключаем ПК
$i = 0
foreach ($c in $GoodComp) {
    try {
        Disable-ADAccount $c -Server $server
        $GoodComp2 += $c
        $i++
    }
    catch {
        $BadObj += $c | Add-Member -Name Error -MemberType NoteProperty -Value "Не удалось выключить ПК" -Force -PassThru
    }
}
if ( ($GoodComp.count - $i) -eq 0) {
    $MailBody += "<br>Всего выключено ПК - <b>$i</b>"
}
else {
    $MailBody += "<br>Не удалось выключить - <b>$($GoodComp.count - $i)</b>"
}
$MailBody += "<hr>"

###Переносим успешно выключенные комп
$i = 0
foreach ($c in $GoodComp2) {
    try {
        Move-ADObject $c -TargetPath $DestenationOU -Server $server
        $i++
    }
    catch {
        $BadObj += $c | Add-Member -Name Error -MemberType NoteProperty -Value "Не удалось перенести в техническую OU" -Force -PassThru
    }
}
if (($GoodComp2.count - $i) -eq 0) {
    $MailBody += "<br>Всего перенесенных ПК - <b>$i</b>"
}
else {
    $MailBody += "<br>Не удалось перенести - <b>$($GoodComp2.count - $i)</b>"
}
$table += "Добрый день, отчет об отключении устаревщих ПК в Active Directory в домене $server"
$table += "<br>Критерий отключения, LastLogonDate > <b>$day дней</b>"
$table += "<br>Техническая OU - <b>$DestenationOU</b><hr>"
$table += $MailBody
$table += "<hr>"
if ($Badobj.count -ge 1) {
    $table += "<br>Кол-во объектов которые не были обработаны - <b>$($Badobj.count)</b>"
    $table += "<br>Детализация:<br><br>"
    $table += "<table><tr><td><b>Имя ПК</td></b><td><b>Последний вход в систему</td></b><td><b>Операционная система</td></b><td><b>Расположение объекта в AD</td></b><td><b>Ошибка</td></b></tr>" + $($Badobj | ForEach-Object { "<tr><td>"; $_.name; '</td><td>'; $_.lastlogondate; '</td><td>'; $_.operatingsystem; '</td><td>'; $_.CanonicalName; '</td><td>'; $_.error; '</td></tr>' }) + "</table>"
    $table += "<hr>"
}
$table += "Список исключений:<br>"
$table += $excludelist | ForEach-Object { "<br>" + $_ }
$table += "<hr>"
$table += "<br>Сервер базы данных - $serverbd<br>База данных - $bd<br>Таблица - $BDTable"
$table += "<br>Выполнено под уз $(whoami) на сервере $($env:COMPUTERNAME)"

[string]$table

