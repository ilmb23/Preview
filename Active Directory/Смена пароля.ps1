#В качестве входящих данных используется SamAccountName
$pwd1 = "q w r t i s f g h j z" -split " "
$pwd2 = "Q W E R Y I P S D F G J L Z V N" -split " "
$pwd3 = "1 2 3 4 5 6 7 8 9" -split " "
$server = "domain2"
$userlist = "

SAN1
SAN2
SAN3

" -split "\n" | ForEach-Object { $_.trim() } | Where-Object { $_ }
$result = @()
foreach ($user in $userlist) {
    $resetpassword = $null
    $password = $null
    $password = (Get-Random $pwd2) + (Get-Random $pwd2) + (Get-Random $pwd3) + (Get-Random $pwd1) + (Get-Random $pwd1) + (Get-Random $pwd1) + (Get-Random $pwd1) + (Get-Random $pwd2) + (Get-Random $pwd2)
    try {
        Set-ADAccountPassword -Identity $user -reset -NewPassword (ConvertTo-SecureString -AsPlainText $password -Force) -Confirm:$false -server $server
        $resetpassword = $true
    }
    catch {
        $resetpassword = $false
        $password = "PaSSw0rd#"
    }
    finally {
        $result += New-Object psobject -Property @{
            Domain         = $server
            SamAccountName = $user
            Reset          = $resetpassword
            Password       = $password
        }
    }
}
$result | Select-Object domain, SamAccountName, Reset, Password | Out-GridView
