###Проверка RAID
#Переменные вывода информации
$StatusOK = 1#"Рейд статус - ОК"
$StatusError = 2#"Рейд статус - Есть ошибка"
$StatusUnknown = 3#"Рейд не опознан"
$StatusScriptError = 4#"Сбой скрипта"
$StatusCliFileError = 5#"Нет файла CLI"
$StatusVirtualDisk = 6#"Виртуальный диск"
#Переменные с расположением CLI
$IntelCLI = "C:\CLI_Tools\x64\rstcli64.exe"
$HPCLI = "C:\Program Files\Compaq\Hpacucli\Bin\hpacucli.exe"
$HPCLIx86 = "C:\Program Files (x86)\Compaq\Hpacucli\Bin\hpacucli.exe"
$MegaCLI = "C:\MegaCli-8.4.10-Win\MegaCli64.exe"
#Путь для выгрузки
$LogPath = "\\v00-cmdp-001.resources.smpgroup.ru\Soft\Logs\Raid_Monitoring\Logs\$(get-date -Format dd.MM.yyyy)"
if (-not (test-path $LogPath)) { New-Item $LogPath -ItemType directory }
#кодидорвка консоли
function ConvertTo-Encoding ([string]$From, [string]$To) {
    Begin {
        $encFrom = [System.Text.Encoding]::GetEncoding($from)
        $encTo = [System.Text.Encoding]::GetEncoding($to)
    }
    Process {
        $bytes = $encTo.GetBytes($_)
        $bytes = [System.Text.Encoding]::Convert($encFrom, $encTo, $bytes)
        $encTo.GetString($bytes)
    }
}
#Определяем тип рейда
[string]$wmimodel = get-wmiobject win32_diskdrive | % { $_.model }
if ($wmimodel -like "*Virtual*") { $Raidmodel = "Виртуальный диск" }
if ($wmimodel -like "Virtual*") { $Raidmodel = "Виртуальный диск" }
if ($wmimodel -like "backup-v*") { $Raidmodel = "Виртуальный диск" }
if ($wmimodel -like "ST*") { $Raidmodel = "Программный рейд" }
if ($wmimodel -like "WD*") { $Raidmodel = "Программный рейд" }
if ($wmimodel -like "TOSHIBA*") { $Raidmodel = "Программный рейд" }
if ($wmimodel -like "DELL PERC*") { $Raidmodel = "Программный рейд" }
if ($wmimodel -like "Intel Raid*") { $Raidmodel = "Intel Raid" }
if ($wmimodel -like "LSI MegaSR*") { $Raidmodel = "LSI MegaSR" }
if ($wmimodel -like "HP LOGICAL*") { $Raidmodel = "HP LOGICAL" }
#
switch ($Raidmodel) {
    "Программный рейд" {
        [string]$diskvolume = "list volume" | diskpart | ConvertTo-Encoding cp866 windows-1251
        $diskvolume = $diskvolume | Select-String "Ошибка"
        if ($diskvolume -like $null) {
            [string]$diskvolume = "list volume" | diskpart
            $diskvolume = $diskvolume | Select-String "Ошибка"
        }
        if ($diskvolume -like $null) { $ReidStatus = $StatusOK }
        else { $ReidStatus = $StatusError }
    }
    "Intel Raid" {
        #Проверяем наличие intel raid cli tool на сервере
        if (test-path $IntelCLI) {
            #Собираем информацию о состоянии RAID
            Stop-Service IAStorDataMgrSvc -Force
            sleep 5
            $clireport = C:\CLI_Tools\x64\rstcli64.exe -I
            Start-Service IAStorDataMgrSvc
            [string]$status = $clireport | Select-String "State:*"
            $CheckError = $status -like "*missing*"
            #Логика проверки
            if ($CheckError -eq $true) { $ReidStatus = $StatusError }
            else { $ReidStatus = $StatusOK }
        }
        else { $ReidStatus = $StatusCliFileError }
    }
    "LSI MegaSR" {
        if (test-path $MegaCLI) {
            [string]$status = C:\MegaCli-8.4.10-Win\MegaCli64.exe " -LDInfo -Lall -a0" | Select-String "state"
            if ($status -notlike "*Optimal*") { $ReidStatus = $StatusError }
            else { $ReidStatus = $StatusOK }
        }
        else { $ReidStatus = $StatusCliFileError }
    }
    "HP LOGICAL" {
        if (test-path $HPCLI) { $HPCLI = $HPCLI }
        else { $HPCLI = $HPCLIx86 }
        if (test-path $HPCLI) {
            Start-Process $HPCLI -ArgumentList "ctrl all show status" -RedirectStandardOutput "c:\windows\temp\HPraidmon.txt" -Wait
            [string]$status = Get-Content "c:\windows\temp\HPraidmon.txt" | Select-String "status"
            if ($status -notlike "*OK*") { $ReidStatus = $StatusError }
            else { $ReidStatus = $StatusOK }
            Remove-Item "c:\windows\temp\HPraidmon.txt" -Force
        }
        else { $ReidStatus = $StatusCliFileError }
    }
    "Виртуальный диск" { $ReidStatus = $StatusVirtualDisk }
    default {
        $Raidmodel = "Рейд не опознан"
        $ReidStatus = $StatusUnknown
    }
}

<#
Имя в SP,Имя в SQL,Тип данных
Имя сервера,ServerName,nchar(10)
Состояние,State,int
Производитель,Manufacture,nchar(10)
Модель,Model,nchar(10)
Дата проверки,CheckDate,date
Тип Raid,RaidType,nchar(10)
Домен,Domain,nchar(10)
#>

$result = @()
$result = New-Object psobject -Property @{
    ServerName  = $env:COMPUTERNAME
    State       = $ReidStatus
    Manufacture = $(Get-WmiObject win32_baseboard).Manufacturer
    Model       = $(Get-WmiObject win32_baseboard).product
    CheckDate   = $(get-date -Format yyyy-MM-ddThh:mm:ss)
    RaidType    = $Raidmodel
    Domain      = $(Get-WmiObject -Class Win32_ComputerSystem).domain
}

$result | select ServerName, State, Manufacture, Model, CheckDate, RaidType, Domain | Export-Csv "$LogPath\$env:COMPUTERNAME.txt" -Encoding Default -NoTypeInformation -Force