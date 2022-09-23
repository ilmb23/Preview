$CurrentIPAddress = $null
$CurrentIPAddress = (Test-Connection $env:COMPUTERNAME -Count 1).IPV4Address.IPAddressToString
$CurrentSubNet = $null
$CurrentSubNet = $CurrentIPAddress -split "\."
$CurrentSubNet = $CurrentSubNet[0] + "." + $CurrentSubNet[1] + "." + $CurrentSubNet[2]
 
$PrimaryMP = ''
$SecondaryMP = ''
$DP = ''
 
#Статические переменные, порты
$PortSubnetToPrimaryMP = "80", "443", "10123", "8530"
$PortSubnetToSecondaryMP = "80", "443", "445", "10123"
$PortSubnetToDP = "80", "443", "445"
 
$ResourcesDcList = "DC", "DC2", "dc3", "dc4", "dc5", "dc6", "dc7"
$PortSubnetToADDS = "3268", "88", "389"
 
$Result = $null
$Result = @()
 
#Проверка: Подсеть > Первичный сайт
foreach ($Port in $PortSubnetToPrimaryMP) {
    $portcheck = $null
    $portcheck = (New-Object System.Net.Sockets.TcpClient($PrimaryMP, $Port)).Connected
    if ($null -eq $portcheck) {
        $portcheck = "False"
    }
    $Result += New-Object psobject -Property @{
        WhoNeedsAccess = $CurrentSubNet
        CheckingFrom   = $CurrentIPAddress
        To             = (Test-Connection $PrimaryMP -Count 1).IPV4Address.IPAddressToString
        Port           = $Port
        Result         = $portcheck
    }
}
 
#Проверка: Подсеть > Вторичный сайт
foreach ($Port in $PortSubnetToSecondaryMP) {
    $portcheck = $null
    $portcheck = (New-Object System.Net.Sockets.TcpClient($SecondaryMP, $Port)).Connected
    if ($null -eq $portcheck) {
        $portcheck = "False"
    }
    $Result += New-Object psobject -Property @{
        WhoNeedsAccess = $CurrentSubNet
        CheckingFrom   = $CurrentIPAddress
        To             = (Test-Connection $SecondaryMP -Count 1).IPV4Address.IPAddressToString
        Port           = $Port
        Result         = $portcheck
    }
}
 
#Проверка: Подсеть > DistributionPoint
foreach ($Port in $PortSubnetToDP ) {
    $portcheck = $null
    $portcheck = (New-Object System.Net.Sockets.TcpClient($DP, $Port)).Connected
    if ($null -eq $portcheck) {
        $portcheck = "False"
    }
    $Result += New-Object psobject -Property @{
        WhoNeedsAccess = $CurrentSubNet
        CheckingFrom   = $CurrentIPAddress
        To             = (Test-Connection $DP -Count 1).IPV4Address.IPAddressToString
        Port           = $Port
        Result         = $portcheck
    }
}
 
foreach ($DC in $ResourcesDcList) {
    foreach ($Port in $PortSubnetToADDS) {
        $portcheck = $null
        $portcheck = (New-Object System.Net.Sockets.TcpClient($Dc, $Port)).Connected
        if ($null -eq $portcheck) { $portcheck = "False" }
        $Result += New-Object psobject -Property @{
            WhoNeedsAccess = $CurrentSubNet
            CheckingFrom   = $CurrentIPAddress
            To             = $DC
            Port           = $Port
            Result         = $portcheck
        }
    }
}

$checkfolder = test-path "c:\windows\temp\sccm"
if ($checkfolder -eq $false) { new-item "c:\windows\temp\sccm" -ItemType directory }
$Result | Select-Object "WhoNeedsAccess", "CheckingFrom", "To", "Port", "Result" | export-csv C:\Windows\temp\SCCM\$env:COMPUTERNAME.txt -Encoding utf8 -Force
#$Result | Select-Object "WhoNeedsAccess", "CheckingFrom", "To", "Port", "Result" | Out-GridView
