$users_exc = 'SAN1', 'SAN2'
$server = "domain2"
$Day = 60
$OUs = 'OU1', 'OU2', 'OU3'
$User = foreach ($OU in $OUs) { Get-ADUser -Server $server -SearchBase $OU -Filter { (Enabled -eq $true) } -Properties LastLogonDate, SID, whenCreated, CanonicalName }

$disable_user = $User | Where-Object { ($_.LastLogonDate -lt (Get-Date).AddDays("-$Day")) -and ($_.whenCreated -lt (Get-Date).AddDays("-$Day")) } | Where-Object { ($_.SamAccountName -notin $users_exc) }
$GoodBody = @()
$BadBody = @()

foreach ($user in $disable_user) {
    try {
        Disable-ADAccount $user -server $server
        $GoodBody += $user
    }
    catch [Microsoft.ActiveDirectory.Management.ADException] {
        $BadBody += $user
    }
    finally {
        
    }
}
$table = @()
$table += "Добрый день, отчет о блокрировке в домене <b>$server</b> <br>Критерием отключения учетной записи является отсутсвие активности в домене<br>Критерий для текущего домена - <b>$day</b> дней<br>Дата последнего входа указана в формате - <b>месяц/день/год</b><br>Для корректировки списка исключений обращайтесь в </b>отдел системного администрирования</b>"
$table += "<hr>"
if ($GoodBody.count -ge 1) {
    $table += "<b>Отключены следующие пользователи:</b><br>"
    [string]$table += "<table><tr><td><b>ФИО</td></b><td><b>Учетная запись</td></b><td><b>Последний вход в систему</td></b><td><b>Расположение объекта в AD</td></b></tr>" + $($GoodBody | ForEach-Object { "<tr><td>"; $_.name; '</td><td>'; "$server\" + $_.SamAccountName; '</td><td>'; $_.LastLogonDate; '</td><td>'; $_.CanonicalName; '</td></tr>' }) + "</table>"
    $table += "<hr>"
}
if ($BadBody.count -ge 1) {
    $table += "<b>Не удалось отключить пользователей:</b><br>"
    [string]$table += "<table><tr><td><b>ФИО</td></b><td><b>Учетная запись</td></b><td><b>Последний вход в систему</td></b><td><b>Расположение объекта в AD</td></b></tr>" + $($BadBody | ForEach-Object { "<tr><td>"; $_.name; '</td><td>'; "$server\" + $_.SamAccountName; '</td><td>'; $_.LastLogonDate; '</td><td>'; $_.CanonicalName; '</td></tr>' }) + "</table>"
    $table += "<hr>"
}
$table += "<b>Список исключений:</b>"
$table += "<table>"
foreach ($exc in $users_exc) {
    $table += "<br>$server\$exc"
}
$table += "</table>"
$table += "<hr>"
$table += "<br>Выполнено под уз $(whoami) на сервере $($env:COMPUTERNAME)"
[string]$table
