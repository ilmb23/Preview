<#
#Учетные записи которые будут менять членсвто в группе
$domain1adm = Get-Credential "domain1\admin"
$domain2adm = Get-Credential "domain2\admin"

Скрипт записан в кодировке UTF8 для корректного отображения символов на гите, для корректной работы с русскими символами нужна кодировка windows 1251, по этому скрипт упадет в ошибку если запустить его в VS Code по средствам нажатия кнопки F5, для того что бы работало в VS Code, нужно выделить весь скрипт(ctrl+a) и нажать F8
Вывод информации об успехе не означает что пользователь был в группе, а лишь показывает, что вызов операции не привел к ошибке

скрипт прицелен на работу с группами из доменов domain1 и domain2, при необходимости можно добавить работу с группами из домена domain3
#>
Clear-Host
$error.clear()

$group = "groupname" #Укажите имя группы
$domaingroup = "domain1" #Укажите домен группы
#В массив userlist запишите список пользоватей, критерием поиска в AD выступает полное совпадение по ФИО
$userlist = "

Иванов Иван Иванович
Петров Петр Петрович

" -split "\n" | ForEach-Object { $_.trim() } | Where-Object { $_ }
$result = @()
$cred = $null

switch ($domaingroup) {
    'domain1' { 
        $cred = $domain1adm 
    }
    'domain2' { 
        $cred = $domain2adm 
    }
    default { 
        $cred = $null 
    }
}

if ($null -eq $cred) {
    Write-Host "Не определен домен группы, остановка скрипта" -ForegroundColor Red
}
else {
    try {
        $group = get-adgroup $group -Server $domaingroup
    }
    catch {
        Write-Host "Группа с именем $group не найдена в домене $domaingroup" -ForegroundColor Red
        break
    }
    if ($group.GroupScope -eq 'DomainLocal') {
        foreach ($user in $userlist) {
            write-host "В обработке - $user"
            $domain1User = $null
            $domain1User = Get-AdUser -Filter { name -like $user } -server domain1 -ErrorAction SilentlyContinue
            $domain2User = $null
            $domain2User = Get-AdUser -Filter { name -like $user } -server domain2 -ErrorAction SilentlyContinue
            $domain3User = $null
            $domain3User = Get-AdUser -Filter { name -like $user } -server domain3 -ErrorAction SilentlyContinue
            if ($null -ne $domain1User) {
                $value = $null
                if (($domain1User.GetType()).name -eq "ADUser") {
                    Write-Host "Пробую удалить учетку domain1\$($domain1User.SamAccountName) из группы"
                    try {
                        Remove-ADGroupMember $group $domain1User -Server $domaingroup -Credential $cred -Confirm:$false
                        $value = $false
                        Write-Host "Успех"-ForegroundColor Green
                    }
                    catch {
                        $value = $true
                        Write-Host "Не успех"-ForegroundColor red
                    }
                }
                else {
                    write-host "---------------------------------------------------------------------"
                    Write-Host "$($user): есть полные совпадение имен в домене domain1!" -ForegroundColor Red
                    Write-Host "Учетная запись не будет удалена из группы!" -ForegroundColor Red
                    Write-Host "Учетную запись необходимо обработать в ручную" -ForegroundColor Red
                    write-host "---------------------------------------------------------------------"
                    $value = $true
                }
                $result += new-object psobject -Property @{
                    SearchObject = $user
                    ADObject     = "domain1\$($domain1User.SamAccountName)"
                    Group        = "$domaingroup\$($Group.name)"
                    Error        = $value
                }
            }
            if ($null -ne $domain2User) {
                $value = $null
                if (($domain2User.GetType()).name -eq "ADUser") {
                    Write-Host "Пробую удалить учетку domain2\$($domain2User.SamAccountName) из группы"
                    try {
                        Remove-ADGroupMember $group $domain2User -Server $domaingroup -Credential $cred -Confirm:$false
                        $value = $false
                        Write-Host "Успех "-ForegroundColor Green
                    }
                    catch {
                        $value = $true
                        Write-Host "Не успех"-ForegroundColor red
                    }
                }
                else {
                    write-host "---------------------------------------------------------------------"
                    Write-Host "$($user): есть полные совпадение имен в домене domain2!" -ForegroundColor Red
                    Write-Host "Учетная запись не будет удалена из группы!" -ForegroundColor Red
                    Write-Host "Учетную запись необходимо обработать в ручную" -ForegroundColor Red
                    write-host "---------------------------------------------------------------------"
                    $value = $true
                }
                $result += new-object psobject -Property @{
                    SearchObject = $user
                    ADObject     = "domain2\$($domain2User.SamAccountName)"
                    Group        = "$domaingroup\$($Group.name)"
                    Error        = $value
                }
            }
            if ($null -ne $domain3User) {
                $value = $null
                if (($domain3User.GetType()).name -eq "ADUser") {
                    Write-Host "Пробую удалить учетку domain3\$($domain3User.SamAccountName) из группы"
                    try {
                        Remove-ADGroupMember $group $domain3User -Server $domaingroup -Credential $cred -Confirm:$false
                        $value = $false
                        Write-Host "Успех"-ForegroundColor Green
                    }
                    catch {
                        $value = $true
                        Write-Host "Не успех"-ForegroundColor red
                    }
                }
                else {
                    write-host "---------------------------------------------------------------------"
                    Write-Host "$($user): есть полные совпадение имен в домене domain3!" -ForegroundColor Red
                    Write-Host "Учетная запись не будет удалена из группы!" -ForegroundColor Red
                    Write-Host "Учетную запись необходимо обработать в ручную" -ForegroundColor Red
                    write-host "---------------------------------------------------------------------"
                    $value = $true
                }
                $result += new-object psobject -Property @{
                    SearchObject = $user
                    ADObject     = "domain3\$($domain3User.SamAccountName)"
                    Group        = "$domaingroup\$($Group.name)"
                    Error        = $value
                }
            }
            Write-Host "---------------------------------------------------------------------"
        }
    }
    else {
        foreach ($user in $userlist) {
            write-host "В обработке - $user"
            $value = $null
            $ADuser = $null
            $ADuser = Get-AdUser -Filter { name -like $user } -server $domaingroup -ErrorAction SilentlyContinue
            if (($ADuser.GetType()).name -eq "ADUser") {
                Write-Host "Пробую удалить учетку $domaingroup\$($domain1User.SamAccountName) из группы"
                try {
                    Remove-ADGroupMember $group $ADuser -Server $domaingroup -Credential $cred -Confirm:$false
                    $value = $false
                    Write-Host "Успех "-ForegroundColor Green
                }
                catch {
                    $value = $true
                    Write-Host "Не успех"-ForegroundColor red
                }
            }
            else {
                write-host "---------------------------------------------------------------------"
                Write-Host "$($user): есть полные совпадение имен в домене $domaingroup!" -ForegroundColor Red
                Write-Host "Учетная запись не будет удалена из группы!" -ForegroundColor Red
                Write-Host "Учетную запись необходимо обработать в ручную" -ForegroundColor Red
                write-host "---------------------------------------------------------------------"
                $value = $true
            }
            $result += new-object psobject -Property @{
                SearchObject = $user
                ADObject     = "$domaingroup\$($ADuser.SamAccountName)"
                Group        = "$domaingroup\$($Group.name)"
                Error        = $value
            }
            Write-Host "---------------------------------------------------------------------"
        }
    }
}
$result | select-object SearchObject, ADObject, Group, Error | Out-GridView