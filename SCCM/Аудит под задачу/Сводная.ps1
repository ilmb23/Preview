$fl = Get-ChildItem \\PATH
$result = @()
foreach ($f in $fl) {
    $result += Import-Csv $f.fullname -Encoding utf8 -Delimiter "@"
}
$result | Export-Csv \\PATH\audit.csv -Delimiter "@" -Encoding utf8 -NoTypeInformation -Force