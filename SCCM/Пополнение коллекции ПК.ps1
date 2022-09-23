#Подключение к SCCM
$SiteCode = "" # Код сайта 
$ProviderMachineName = "" # Имя компьютера поставщика SMS
$initParams = @{}
if ($null -eq (Get-Module ConfigurationManager)) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}
if ($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}
$location = Get-Location
Set-Location "$($SiteCode):\" @initParams 
$CollectionName = "Обновления тестовая группа 1 - comp"
#New-CMDeviceCollection -LimitingCollectionId "SMS00001" -Name $CollectionName -RefreshType Both
$Computers = "
compname1
compname2

" -split "\n" | ForEach-Object { $_.trim() } | Where-Object { $_ }
Foreach ($Computer in $Computers) {
    Write-Host $Computer 
    add-cmdevicecollectiondirectmembershiprule -collectionname $CollectionName -resourceid (Get-CMDevice -Collectionid SMS00001 -name $Computer).ResourceID -Verbose
} 
Set-Location $location
