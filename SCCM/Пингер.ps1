$Complist = "

COMPNAME1
COMPNAME2

" -split "\n" | ForEach-Object { $_.trim() } | Where-Object { $_ }

$counter = 1
$result = @()
foreach ($obj in $Complist) {
    Write-Host $counter
    $counter ++
    #Проверка ICMP
    $Connect = $null
    $Connect = Test-NetConnection $obj -hops 1
    #Проверка в AD
    if ($connect.PingSucceeded -eq $true) {
        $ad = $null
        try {
            $ad = Get-ADComputer $obj -Server "domain1" -Properties CanonicalName, operatingsystem -ErrorAction SilentlyContinue
        }
        catch {
            try {
                $ad = Get-ADComputer $obj -Server "domain2" -Properties CanonicalName, operatingsystem -ErrorAction SilentlyContinue
            }
            catch {
                try {
                    $ad = Get-ADComputer $obj -Server "domain3" -Properties CanonicalName, operatingsystem -ErrorAction SilentlyContinue
                }
                catch {
                    $ad = $null
                }
            }
        }
        if ($null -notlike $ad) {
            $result += New-Object psobject -Property @{
                Name            = $obj
                StatusConnect   = $true
                EnabledInAD     = $ad.enabled
                CanonicalName   = $ad.canonicalname
                operatingsystem = $ad.operatingsystem
                IPv4            = $Connect.RemoteAddress.IPAddressToString
            }
        }
        else {
            $result += New-Object psobject -Property @{
                Name            = $obj
                StatusConnect   = $true
                EnabledInAD     = $null
                CanonicalName   = $null
                operatingsystem = $null
                IPv4            = $Connect.RemoteAddress.IPAddressToString
            }
        }
    }
    else {
        $result += New-Object psobject -Property @{
            Name            = $obj
            StatusConnect   = $false
            EnabledInAD     = $null
            CanonicalName   = $null
            operatingsystem = $null
            IPv4            = $null
        }
    }

}
 
$Result | Select-Object "Name", "StatusConnect", "IPv4", "EnabledInAD", "CanonicalName", "operatingsystem" | out-gridview
$result | select-object "Name", "StatusConnect", "IPv4", "EnabledInAD", "CanonicalName" | Export-Csv ".\Аудит не активных клиентов\output\BadClients.csv" -Encoding UTF8 -Force -NoTypeInformation