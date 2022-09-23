#Поиск групп пользователя в доменах domain1,domain2,domain3,domain4ources
import-module activedirectory
Clear-Host
$domain4ult = @()
$userlist = read-host "Введите имена пользователей"
$userlist = $userlist -split '\n' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
$GroupsIndomain1 = Get-ADGroup -Filter * -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain1
$GroupsIndomain2 = Get-ADGroup -Filter * -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain2
$GroupsIndomain3 = Get-ADGroup -Filter * -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain3
$GroupsIndomain4 = Get-ADGroup -Filter * -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain4
foreach ($user in $userlist) {
    $domain1User = $null
    $domain1User = Get-AdUser -Filter { name -like $user } -server domain1
    $domain2User = $null
    $domain2User = Get-AdUser -Filter { name -like $user } -server domain2
    $domain3User = $null
    $domain3User = Get-AdUser -Filter { name -like $user } -server domain3
    $domain4User = $null
    $domain4User = Get-AdUser -Filter { name -like $user } -server domain4
    if ($null -ne $domain1User) {
        Write-Host "Найдена учетная запись domain1\$($domain1User.SamAccountName)" -ForegroundColor Green
        $domain1GroupList = Get-ADPrincipalGroupMembership $domain1user -Server domain1 
        foreach ($domain1Group in $domain1GroupList) {
            $domain1Group = Get-ADGroup $domain1Group -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain1
            $domain4ult += New-Object psobject -Property @{
                "User"          = "domain1\$($domain1User.SamAccountName)"
                "Group"         = "domain1\$($domain1Group.name)"
                "GroupCategory" = $domain1Group.GroupCategory
                "GroupScope"    = $domain1Group.GroupScope
                "Description"   = $domain1Group.Description
                "CanonicalName" = $domain1Group.CanonicalName
            }
        }
        foreach ($domain2Group in $GroupsIndomain2) {
            if ($domain2Group.Members -like "*$($domain1User.SID)*") {
                $domain2Group = Get-ADGroup $domain2Group -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain2
                $domain4ult += New-Object psobject -Property @{
                    "User"          = "domain1\$($domain1User.SamAccountName)"
                    "Group"         = "domain2\$($domain2Group.Name)"
                    "GroupCategory" = $domain2Group.GroupCategory
                    "GroupScope"    = $domain2Group.GroupScope
                    "Description"   = $domain2Group.Description
                    "CanonicalName" = $domain2Group.CanonicalName
                }
            }
        }
        foreach ($domain3Group in $GroupsIndomain3) {
            if ($domain3Group.Members -like "*$($domain1User.SID)*") {
                $domain3Group = Get-ADGroup $domain3Group -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain3
                $domain4ult += New-Object psobject -Property @{
                    "User"          = "domain1\$($domain1User.SamAccountName)"
                    "Group"         = "domain3\$($domain3Group.Name)"
                    "GroupCategory" = $domain3Group.GroupCategory
                    "GroupScope"    = $domain3Group.GroupScope
                    "Description"   = $domain3Group.Description
                    "CanonicalName" = $domain3Group.CanonicalName
                }
            }
        }
        foreach ($domain4Group in $GroupsIndomain4) {
            if ($domain4Group.Members -like "*$($domain1User.SID)*") {
                $domain4Group = Get-ADGroup $domain4Group -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain4
                $domain4ult += New-Object psobject -Property @{
                    "User"          = "domain1\$($domain1User.SamAccountName)"
                    "Group"         = "domain4\$($domain4Group.Name)"
                    "GroupCategory" = $domain4Group.GroupCategory
                    "GroupScope"    = $domain4Group.GroupScope
                    "Description"   = $domain4Group.Description
                    "CanonicalName" = $domain4Group.CanonicalName
                }
            }
        }
    }
    if ($null -ne $domain2User) {
        Write-Host "Найдена учетная запись domain2\$($domain2User.SamAccountName)" -ForegroundColor Green
        $domain2GroupList = Get-ADPrincipalGroupMembership $domain2User -Server domain2
        foreach ($domain2Group in $domain2GroupList) {
            $domain2Group = Get-ADGroup $domain2Group -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain2
            $domain4ult += New-Object psobject -Property @{
                "User"          = "domain2\$($domain2User.SamAccountName)"
                "Group"         = "domain2\$($domain2Group.Name)"
                "GroupCategory" = $domain2Group.GroupCategory
                "GroupScope"    = $domain2Group.GroupScope
                "Description"   = $domain2Group.Description
                "CanonicalName" = $domain2Group.CanonicalName
            }
        }
        foreach ($domain1Group in $GroupsIndomain1) {
            if ($domain1Group.Members -like "*$($domain2User.SID)*") {
                $domain1Group = Get-ADGroup $domain1Group -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain1
                $domain4ult += New-Object psobject -Property @{
                    "User"          = "domain2\$($domain2User.SamAccountName)"
                    "Group"         = "domain1\$($domain1Group.Name)"
                    "GroupCategory" = $domain1Group.GroupCategory
                    "GroupScope"    = $domain1Group.GroupScope
                    "Description"   = $domain1Group.Description
                    "CanonicalName" = $domain1Group.CanonicalName
                }
            }
        }
        foreach ($domain4Group in $GroupsIndomain4) {
            if ($domain4Group.Members -like "*$($domain2User.SID)*") {
                $domain4Group = Get-ADGroup $domain4Group -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain4
                $domain4ult += New-Object psobject -Property @{
                    "User"          = "domain2\$($domain2User.SamAccountName)"
                    "Group"         = "domain4\$($domain4Group.Name)"
                    "GroupCategory" = $domain4Group.GroupCategory
                    "GroupScope"    = $domain4Group.GroupScope
                    "Description"   = $domain4Group.Description
                    "CanonicalName" = $domain4Group.CanonicalName
                }
            }
        }
    }
    if ($null -ne $domain3User) {
        Write-Host "Найдена учетная запись domain3\$($domain3User.SamAccountName)" -ForegroundColor Green
        $domain3GroupList = Get-ADPrincipalGroupMembership $domain3User -Server domain3 
        foreach ($domain3Group in $domain3GroupList) {
            $domain3Group = Get-ADGroup $domain3Group -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain3
            $domain4ult += New-Object psobject -Property @{
                "User"          = "domain3\$($domain3User.SamAccountName)"
                "Group"         = "domain3\$($domain3Group.name)"
                "GroupCategory" = $domain3Group.GroupCategory
                "GroupScope"    = $domain3Group.GroupScope
                "Description"   = $domain3Group.Description
                "CanonicalName" = $domain3Group.CanonicalName
            }
        }
        foreach ($domain1Group in $GroupsIndomain1) {
            if ($domain1Group.Members -like "*$($domain3User.SID)*") {
                $domain1Group = Get-ADGroup $domain1Group -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain1
                $domain4ult += New-Object psobject -Property @{
                    "User"          = "domain3\$($domain3User.SamAccountName)"
                    "Group"         = "domain1\$($domain1Group.Name)"
                    "GroupCategory" = $domain1Group.GroupCategory
                    "GroupScope"    = $domain1Group.GroupScope
                    "Description"   = $domain1Group.Description
                    "CanonicalName" = $domain1Group.CanonicalName
                }
            }
        }
        foreach ($domain4Group in $GroupsIndomain4) {
            if ($domain4Group.Members -like "*$($domain3User.SID)*") {
                $domain4Group = Get-ADGroup $domain4Group -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain4
                $domain4ult += New-Object psobject -Property @{
                    "User"          = "domain3\$($domain3User.SamAccountName)"
                    "Group"         = "domain4\$($domain4Group.Name)"
                    "GroupCategory" = $domain4Group.GroupCategory
                    "GroupScope"    = $domain4Group.GroupScope
                    "Description"   = $domain4Group.Description
                    "CanonicalName" = $domain4Group.CanonicalName
                }
            }
        }
    }
    if ($null -ne $domain4User) {
        Write-Host "Найдена учетная запись domain4\$($domain4User.SamAccountName)" -ForegroundColor Green
        $domain4GroupList = (get-aduser $domain4user -Properties memberof -server domain4).memberof
        foreach ($domain4Group in $domain4GroupList) {
            $domain4Group = Get-ADGroup $domain4Group -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain4
            $domain4ult += New-Object psobject -Property @{
                "User"          = "domain4\$($domain4User.SamAccountName)"
                "Group"         = "domain4\$($domain4Group.name)"
                "GroupCategory" = $domain4Group.GroupCategory
                "GroupScope"    = $domain4Group.GroupScope
                "Description"   = $domain4Group.Description
                "CanonicalName" = $domain4Group.CanonicalName
            }
        }
        foreach ($domain2Group in $GroupsIndomain2) {
            if ($domain2Group.Members -like "*$($domain4User.SID)*") {
                $domain2Group = Get-ADGroup $domain2Group -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain2
                $domain4ult += New-Object psobject -Property @{
                    "User"          = "domain4\$($domain4User.SamAccountName)"
                    "Group"         = "domain2\$($domain2Group.Name)"
                    "GroupCategory" = $domain2Group.GroupCategory
                    "GroupScope"    = $domain2Group.GroupScope
                    "Description"   = $domain2Group.Description
                    "CanonicalName" = $domain2Group.CanonicalName
                }
            }
        }
        foreach ($domain3Group in $GroupsIndomain3) {
            if ($domain3Group.Members -like "*$($domain4User.SID)*") {
                $domain3Group = Get-ADGroup $domain3Group -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain3
                $domain4ult += New-Object psobject -Property @{
                    "User"          = "domain4\$($domain4User.SamAccountName)"
                    "Group"         = "domain3\$($domain3Group.Name)"
                    "GroupCategory" = $domain3Group.GroupCategory
                    "GroupScope"    = $domain3Group.GroupScope
                    "Description"   = $domain3Group.Description
                    "CanonicalName" = $domain3Group.CanonicalName
                }
            }
        }
        foreach ($domain1Group in $GroupsIndomain1) {
            if ($domain1Group.Members -like "*$($domain4User.SID)*") {
                $domain1Group = Get-ADGroup $domain1Group -Properties MemberOf, Members, GroupCategory, Description, CanonicalName -server domain1
                $domain4ult += New-Object psobject -Property @{
                    "User"          = "domain4\$($domain4User.SamAccountName)"
                    "Group"         = "domain1\$($domain1Group.Name)"
                    "GroupCategory" = $domain1Group.GroupCategory
                    "GroupScope"    = $domain1Group.GroupScope
                    "Description"   = $domain1Group.Description
                    "CanonicalName" = $domain1Group.CanonicalName
                }
            }
        }
    }
}
$domain4ult | Select-Object "User", "Group", "GroupCategory", "GroupScope", "Description", "CanonicalName" | Out-GridView 
