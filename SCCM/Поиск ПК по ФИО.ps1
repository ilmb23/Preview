$userlist = "
ИВАНОВ Иван Иванович
Петров Петр Петрович
" -split "\n" | ForEach-Object { $_.trim() } | Where-Object { $_ }

# Данные базы данных
$dataSource = "ServerFQDN"
$database = "BDName"

# Подключение к базе данных
Clear-Host
Write-host "Подключение к базе данных: '$database' на сервере: '$dataSource'"
#Использование Windows Authentication
$connectionString = "Server=$dataSource;Database=$database;Integrated Security=SSPI;"
# Using SQL authentication
#$connectionString = "Server=$dataSource;Database=$database;uid=ConfigMgrDB_Read;pwd=Pa$$w0rd;Integrated Security=false"
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

# Запрос в БД
Write-host "Выполнение запроса"

$query = "
    select distinct 
    upm.UserResourceID,
    upm.MachineID,
    vru.Name0 as [User],
    vrs.Name0 as [MachineName],
    --vgp.name0 as [ProcessorName],
    --RAM.TotalPhysicalMemory0 as [TotalMemory],
    --vgws.LastHWScan as [LastHWScan],
    vrs.Distinguished_Name0 as [DistinguishedName]
    from
    v_UsersPrimaryMachines upm 
    join v_R_User vru on upm.UserResourceID = vru.ResourceID
    join v_R_System vrs on upm.MachineID = vrs.ResourceID
    --join v_GS_PROCESSOR vgp on upm.MachineID = vgp.ResourceID
    --join v_GS_WORKSTATION_STATUS vgws on upm.MachineID = vgws.ResourceID
    --join V_GS_X86_PC_MEMORY RAM on RAM.ResourceID = vrs.ResourceID
"
$command = $connection.CreateCommand()
$command.CommandText = $query
$result = $command.ExecuteReader()
$table = $null
$table = new-object "System.Data.DataTable"
$table.Load($result)
$table_1 = $table | Where-Object { $_.User -notlike $null }


# Закрытие сессии
$connection.Close()

$result = $null
$result = @()
foreach ($user in $userlist) {
    Write-Host $user
    $bd = $null
    $bd = @()
    $bd = $table_1 | Where-Object { $_.user -like "*$user*" }
    foreach ($machine in $bd) {
        $Result += New-Object psobject -Property @{
            "User"              = $user
            "UserInBase"        = $machine.user
            "MachineName"       = $machine.machinename
            "ProcessorName"     = $machine.ProcessorName
            "TotalMemory"       = $machine.TotalMemory / 1mb
            "LastHWScan"        = $machine.LastHWScan
            "DistinguishedName" = $machine.DistinguishedName
        }
    }
}

$Result | Select-Object User, UserInBase, MachineName, ProcessorName, TotalMemory, LastHWScan, DistinguishedName | Out-GridView