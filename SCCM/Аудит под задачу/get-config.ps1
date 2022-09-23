<#
1. проверка установки софта
    1.1 Agent
        1.1.1 {B580BD74-668F-4A95-8B41-3AD21FB04B1D}
        1.1.2 {94CF21AF-DEEF-41CF-9ED2-F7EB79D1D8E7}
    1.2 ClientTools
        1.2.1 {923974F7-8F2D-46E9-9BE4-FD6AFAB211A7}
        1.2.2 {51628285-F90D-4A56-9153-52A5F0486A73}
    1.3 eToken
        1.3.1 {58322376-17EC-4F7E-BD03-D925A09E072B}
        1.3.2 {79F4DFED-4835-4F8B-9BCE-53C699B6E406}
    1.4 JaCarta
        1.4.1 {61DFCBE5-FF9F-42CC-9736-4C43914AB6B3}
        1.4.2 {C6083436-2961-4E1A-A9F9-50E2081C4F27}
    1.5 JaCarta_RuToken
        1.5.1 rtDrivers
            1.5.1.1 {293D0B93-6443-4BBE-9B62-0D3EACF7B044}
            1.5.1.2 {5F78AD98-DD4E-4BEC-B532-D3A62B86FF80}
        1.5.2 SafeNetAuthenticationClient
            1.5.2.1 {3D5172FD-9C72-4074-8D06-6A9B3FA9536D}
            1.5.2.2 {C4F0FBBF-9190-4C49-BE95-486EA6F0A9F4}
    1.6 Registry
        1.6.1 {86123D93-65CA-495B-8E8B-FB17DEA49956}
        1.6.2 {44509025-B6E9-48D0-A15A-56E7B36C12FC}
    1.7 Rutoken
        1.7.1 {5067AE84-B503-41F5-A2E3-14AD927AD844}
        1.7.2 {6BB73C51-1994-4D88-8D7A-7BB8239D6CBC}
2. проверка запущенных служб
    2.1 IndeedCM.Client.Server.Monitor
        [string](Get-Service "IndeedCM.Client.Server.Monitor" | ForEach-Object { $_.status, ",", $_.starttype }) -replace ("\ ", "")
    2.2 IndeedCM.Certificate.Manager
        [string](Get-Service "IndeedCM.Certificate.Manager" | ForEach-Object { $_.status, ",", $_.starttype }) -replace ("\ ", "")
    2.3 Indeed CM Agent Service
        [string](Get-Service "Indeed CM Agent Service" | ForEach-Object { $_.status, ",", $_.starttype }) -replace ("\ ", "")
    2.4 SCardSvr
        [string](Get-Service "SCardSvr" | ForEach-Object { $_.status, ",", $_.starttype }) -replace ("\ ", "")

3. проверка параметров реестра
    3.1 MachineRegistryCardEnabled
    3.2 UserRegistryCardEnabled

#>
$error.clear()
Clear-Host
$result = @()
$wmi = Get-WmiObject win32_product | Select-Object *
$registry = Get-ItemProperty "HKLM:\SOFTWARE\Policies\IndeedCM\client" -ErrorAction SilentlyContinue

$result += New-Object psobject -Property @{
    #FQDN
    ComputerName                     = "$env:COMPUTERNAME.$((Get-WmiObject -Class Win32_ComputerSystem).domain)"
    #Приложения
    Agent                            = if ($($wmi | Where-Object { ($_.PackageCode -eq "{B580BD74-668F-4A95-8B41-3AD21FB04B1D}") -or ($_.PackageCode -eq "{94CF21AF-DEEF-41CF-9ED2-F7EB79D1D8E7}") } ) -notlike $null) { "Installed" } else { "Not Installed" }
    ClientTools                      = if ($($wmi | Where-Object { ($_.PackageCode -eq "{923974F7-8F2D-46E9-9BE4-FD6AFAB211A7}") -or ($_.PackageCode -eq "{51628285-F90D-4A56-9153-52A5F0486A73}") } ) -notlike $null) { "Installed" } else { "Not Installed" }
    eToken                           = if ($($wmi | Where-Object { ($_.PackageCode -eq "{58322376-17EC-4F7E-BD03-D925A09E072B}") -or ($_.PackageCode -eq "{79F4DFED-4835-4F8B-9BCE-53C699B6E406}") } ) -notlike $null) { "Installed" } else { "Not Installed" }
    JaCarta                          = if ($($wmi | Where-Object { ($_.PackageCode -eq "{61DFCBE5-FF9F-42CC-9736-4C43914AB6B3}") -or ($_.PackageCode -eq "{C6083436-2961-4E1A-A9F9-50E2081C4F27}") } ) -notlike $null) { "Installed" } else { "Not Installed" }
    rtDrivers                        = if ($($wmi | Where-Object { ($_.PackageCode -eq "{293D0B93-6443-4BBE-9B62-0D3EACF7B044}") -or ($_.PackageCode -eq "{5F78AD98-DD4E-4BEC-B532-D3A62B86FF80}") } ) -notlike $null) { "Installed" } else { "Not Installed" }
    SafeNetAuthenticationClient      = if ($($wmi | Where-Object { ($_.PackageCode -eq "{3D5172FD-9C72-4074-8D06-6A9B3FA9536D}") -or ($_.PackageCode -eq "{C4F0FBBF-9190-4C49-BE95-486EA6F0A9F4}") } ) -notlike $null) { "Installed" } else { "Not Installed" }
    Registry                         = if ($($wmi | Where-Object { ($_.PackageCode -eq "{86123D93-65CA-495B-8E8B-FB17DEA49956}") -or ($_.PackageCode -eq "{44509025-B6E9-48D0-A15A-56E7B36C12FC}") } ) -notlike $null) { "Installed" } else { "Not Installed" }
    Rutoken                          = if ($($wmi | Where-Object { ($_.PackageCode -eq "{5067AE84-B503-41F5-A2E3-14AD927AD844}") -or ($_.PackageCode -eq "{6BB73C51-1994-4D88-8D7A-7BB8239D6CBC}") } ) -notlike $null) { "Installed" } else { "Not Installed" }
    #Службы
    "IndeedCM.Client.Server.Monitor" = [string](Get-Service "IndeedCM.Client.Server.Monitor" | ForEach-Object { $_.status, ",", $_.starttype }) -replace ("\ ", "")
    "IndeedCM.Certificate.Manager"   = [string](Get-Service "IndeedCM.Certificate.Manager" | ForEach-Object { $_.status, ",", $_.starttype }) -replace ("\ ", "")
    "Indeed CM Agent Service"        = [string](Get-Service "Indeed CM Agent Service" | ForEach-Object { $_.status, ",", $_.starttype }) -replace ("\ ", "")
    "SCardSvr"                       = [string](Get-Service "SCardSvr" | ForEach-Object { $_.status, ",", $_.starttype }) -replace ("\ ", "")
    #Реестр
    MachineRegistryCardEnabled       = if ($null -notlike $registry.MachineRegistryCardEnabled) { $registry.MachineRegistryCardEnabled } else { $null }
    UserRegistryCardEnabled          = if ($null -notlike $registry.UserRegistryCardEnabled) { $registry.UserRegistryCardEnabled } else { $null }
}
$result | Select-Object ComputerName, Agent, ClientTools, eToken, JaCarta, rtDrivers, SafeNetAuthenticationClient, Registry, Rutoken, "IndeedCM.Client.Server.Monitor", "IndeedCM.Certificate.Manager", "Indeed CM Agent Service", "SCardSvr", MachineRegistryCardEnabled, UserRegistryCardEnabled | Export-Csv \\PATH\$env:COMPUTERNAME.$((Get-WmiObject -Class Win32_ComputerSystem).domain).csv -Encoding Default -NoTypeInformation -Delimiter "@"