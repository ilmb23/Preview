$share = "SharePath" #Можно менять под задачу
$serverbd = "ServerFQDN"
$BD = "BDName"

#Таблица 1, анализ размера папок
$BDTable = "FileShare"
$BDColumns = "[Path],[Files],[Containers],[Sum],[Length_GB],[Length_B],[AuditProblems],[JobTime],[Date]"

#Таблица 2, всевозможные ошибки с детализацией
[string]$BDTable2 = "FileShare_errors"
$BDColumns2 = "[Path],[CategoryInfo],[Date]"

#Таблица 3, настройки аудита отличаются от родительской папки
[string]$BDTable3 = "FileShare_audit"
$BDColumns3 = "[Path],[AuditRule],[Parent],[Parent_AuditRule],[Date]"

#статичные переменные
$Date = get-date -Format yyyy-MM-dd
$c = 1
$result = @()
$problems = @()
$audit = (get-acl $share -Audit).AuditToString

$folderlist = Get-ChildItem $share -Directory -Force -ErrorAction SilentlyContinue
if ($null -like $audit) {
    #отправить почту что нет аудита
    $EmailFrom = "user@domain" #Имя отправуителя
    $SmtpServer = "smtpserver" #Сервер отправки
    $EmailTo = "user1mail,user2mail" #Получатели
    $message = New-Object System.Net.Mail.MailMessage $EmailFrom, $EmailTo
    $message.Subject = "Проверка настроек аудита - ошибка"
    $message.Body = "Не настроен аудит $share"
    $message.IsBodyHtml = $true
    $SmtpClient = New-Object Net.Mail.SmtpClient($SmtpServer)
    $SmtpClient.Send($message)

    #не проводить анализ аудита
    $auditcheck = 0
}
else {
    $auditcheck = 1
}

foreach ($folder in $folderlist) {
    $StartTimeCycle = $null
    $StartTimeCycle = get-date 
    $len = 0
    $file = 0
    $Container = 0
    $auditproblems = @()
    Get-ChildItem $folder.fullname -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $len += $_.length
        if ($_.PSIsContainer -eq $false ) { 
            $file++
        }
        else { 
            $Container++
            #Если на родительской папке настроен аудит
            if ($auditcheck -eq 1) {
                $auditrule = $null
                $auditrule = (get-acl $folder.fullname -Audit).AuditToString
                if ($audit -notlike $auditrule) {
                    $auditproblems += New-Object psobject -Property @{
                        path        = $folder.fullname
                        parent      = $share
                        auditrule   = $auditrule
                        auditparent = $audit
                    }
                }
            }
        }
    }
    $EndTimeCycle = $null
    $EndTimeCycle = get-date 
    $result += New-Object psobject -Property @{
        Path          = $folder.fullname
        Files         = $file
        Containers    = $Container
        Count         = $file + $Container
        Length_GB     = '{0:N3} GB' -f ($len / 1Gb)
        Length_B      = $len
        JobTime       = $(([string]($EndTimeCycle - $StartTimeCycle | ForEach-Object { $_.hours; ':'; $_.Minutes; ':'; $_.seconds })).Replace(' ', '').trim())
        AuditProblems = $auditproblems.count
    }
    $c++
    if ($auditproblems.count -ge 1) {
        $problems += $auditproblems
    }
}

###Подключаемся к БД
[Void][Reflection.Assembly]::LoadWithPartialName('System.Data')
[Data.SqlClient.SqlConnection]$DBCnn = "Server=$serverbd; Database=$bd; Integrated Security=True;"
$DBCnn.Open()

###Задачи с БД
#Загрузка аудита
foreach ($obj in $result) {
    ##Загрузка данных в БД
    $DBCmd = $DBCnn.CreateCommand()
    $DBCmd.CommandText = @"
    USE [$($BD)]
    INSERT INTO [dbo].[$($BDTable)]($BDColumns)
    VALUES (
    $("'"+$obj.Path+"'"),$("'"+$obj.Files+"'"),$("'"+$obj.Containers+"'"),$("'"+$obj.Count+"'"),$("'"+$obj.Length_GB+"'"),$("'"+$obj.Length_B+"'"),$("'"+$obj.AuditProblems+"'"),$("'"+$obj.JobTime+"'"),$("'"+$date+"'")
    )
"@
    $SQL = $null
    $SQL = New-Object Data.DataTable;
    $DBCmd.CommandTimeout = 0;
    $SQL.Load($DBCmd.ExecuteReader())
}

#Загрузка ошибок
foreach ($obj in $error) {
    ##Загрузка данных в БД
    $DBCmd = $DBCnn.CreateCommand()
    $DBCmd.CommandText = @"
    USE [$($BD)]
    INSERT INTO [dbo].[$($BDTable2)]($BDColumns2)
    VALUES (
    $("'"+$obj.TargetObject+"'"),$("'"+$obj.CategoryInfo+"'"),$("'"+$date+"'")
    )
"@
    $SQL = $null
    $SQL = New-Object Data.DataTable;
    $DBCmd.CommandTimeout = 0;
    $SQL.Load($DBCmd.ExecuteReader())
}

#Загрузка ошибок аудита
if ($auditcheck -eq 1) {
    foreach ($obj in $problems) {
        ##Загрузка данных в БД
        $DBCmd = $DBCnn.CreateCommand()
        $DBCmd.CommandText = @"
        USE [$($BD)]
        INSERT INTO [dbo].[$($BDTable3)]($BDColumns3)
        VALUES (
        $("'"+$obj.path+"'"),$("'"+$obj.auditrule+"'"),$("'"+$obj.parent+"'"),$("'"+$obj.auditparent+"'"),$("'"+$date+"'")
        )
"@
        $SQL = $null
        $SQL = New-Object Data.DataTable;
        $DBCmd.CommandTimeout = 0;
        $SQL.Load($DBCmd.ExecuteReader())
    }
}
else {
    ##Загрузка данных в БД
    $DBCmd = $DBCnn.CreateCommand()
    $DBCmd.CommandText = @"
    USE [$($BD)]
    INSERT INTO [dbo].[$($BDTable3)]($BDColumns3)
    VALUES (
    $("'"+$share+"'"),$("'Аудит не настроен'"),$("'Аудит не настроен'"),$("'Аудит не настроен'"),$("'"+$date+"'")
    )
"@
    $SQL = $null
    $SQL = New-Object Data.DataTable;
    $DBCmd.CommandTimeout = 0;
    $SQL.Load($DBCmd.ExecuteReader())
}


###Отключение от БД
$DBCnn.Close()
