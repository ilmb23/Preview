Clear-Host
#Функция FileHash
function Get-FileHash {
    param (
        [string]
        $Path
    )

    $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider;
    $Hash = [System.BitConverter]::ToString($hashAlgorithm.ComputeHash([System.IO.File]::ReadAllBytes($Path)));
    $Properties = @{'Algorithm' = 'MD5';
        'Path'                  = $Path;
        'Hash'                  = $Hash.Replace('-', '');
    };
    $Ret = New-Object –TypeName PSObject –Prop $Properties
    return $Ret;
}

#Модули
Import-Module BitsTransfer

#Переменные
$Horizontal = $null
$Vertical = $null
$FileName = '1.jpg'
$PauseTime = 2
$LocalFileHash = $null
$ServerFileHash = $null
$ServerFolder = "\\PATH\"

#Проверка папки C:\wallpaper
switch (Test-Path C:\wallpaper) {
    'False' {
        New-Item -Path C:\Wallpaper -ItemType directory
        Start-Sleep $PauseTime
        switch (Test-Path C:\wallpaper) {
            'False' { Exit }
        }
    }
}

#Проверка наличия лог файла
switch (Test-Path C:\Wallpaper\wallpaper.log) {
    'False' { New-Item C:\Wallpaper\wallpaper.log -ItemType file }
}
Add-Content C:\Wallpaper\wallpaper.log -Value "*****"
#Проверка C:\wallpaper\BGInfo
switch (Test-Path C:\wallpaper\BGInfo) {
    'False' {
        Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Создание папки C:\wallpaper\BGInfo')
        New-Item -Path C:\wallpaper\BGInfo -ItemType directory
        Start-Sleep $PauseTime
        switch (Test-Path C:\wallpaper\BGInfo) {
            'False' {
                Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Проблемы с созданием папки BGinfo')
                Exit
            }
            'True' { Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Папка BGInfo успешно создана') }
        }
    
    }
    'True' { Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Папка BGInfo уже существует') }
}

#Проверка C:\wallpaper\BGInfo\Bginfo.exe
switch (Test-Path C:\wallpaper\BGInfo\Bginfo.exe) {
    'False' {
        Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Копирование файла Bginfo.exe')
        Start-BitsTransfer -Source \\v00-cmdp-001.resources.smpgroup.ru\Soft\Wallpaper\BGInfo\Bginfo.exe -Destination C:\wallpaper\BGInfo
        switch (Test-Path C:\wallpaper\BGInfo\Bginfo.exe) {
            'False' {
                Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Проблемы с копированием файла Bginfo.exe')
                Exit
            }
            'True' { Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Файл Bginfo.exe успешно скопирован') }
        }
    
    }
    'True' { Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Bginfo.exe уже существует') }
}

#Проверка C:\wallpaper\BGInfo\BGI_IPv4.vbs
switch (Test-Path C:\wallpaper\BGInfo\BGI_IPv4.vbs) {
    'False' {
        Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Копирование файла BGI_IPv4.vbs')
        Start-BitsTransfer -Source \\v00-cmdp-001.resources.smpgroup.ru\Soft\Wallpaper\BGInfo\BGI_IPv4.vbs -Destination C:\wallpaper\BGInfo
        switch (Test-Path C:\wallpaper\BGInfo\BGI_IPv4.vbs) {
            'False' {
                Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Проблемы с копированием файла BGI_IPv4.vbs')
                Exit
            }
            'True' { Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Файл BGI_IPv4.vbs успешно скопирован') }
        }
    
    }
    'True' { Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'BGI_IPv4.vbs уже существует') }
}

#Проверка наличия конфига BGInfo
switch (Test-Path C:\Wallpaper\BGInfo\Config.bgi) {
    'False' {
        Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + "Копирование файла Config.bgi")
        Start-BitsTransfer -Source \\v00-cmdp-001.resources.smpgroup.ru\Soft\Wallpaper\BGInfo\Config.bgi -Destination C:\wallpaper\BGInfo
        switch (Test-Path C:\wallpaper\BGInfo\Config.bgi) {
            'False' {
                Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Config.bgi не скопировался')
                Exit
            }
            'True' { Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Config.bgi успешно скопировался') }
        }
    
    }
    'True' {
        Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Config.bgi уже существует')
    }
}

#Определение разрешения экрана
$Horizontal = Get-WmiObject Win32_DesktopMonitor | Select-Object -first 1 | ForEach-Object { $_.ScreenWidth }
if ($Horizontal -like $null) { $Horizontal = Get-WmiObject -Class Win32_VideoController | Select-Object -first 1 | ForEach-Object { $_.CurrentHorizontalResolution } }
$Vertical = Get-WmiObject Win32_DesktopMonitor | Select-Object -first 1 | ForEach-Object { $_.ScreenHeight }
if ($Vertical -like $null) { $Vertical = Get-WmiObject -Class Win32_VideoController | Select-Object -first 1 | ForEach-Object { $_.CurrentVerticalResolution } }
if (($Vertical -like $null) -or ($Horizontal -like $null)) { $Log += 'Не удалось определить разрешение экрана!' }
else {
    $FileName = "$Horizontal" + "x" + "$Vertical" + ".jpg"
    Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + "Определен фон - $FileName")
}
#Проверка наличия файла на сервере
switch (Test-Path ("$ServerFolder" + "$FileName")) {
    'False' {
        Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + "Файла фона нет на сервере, используется Default фон")
        $FileName = '1.jpg'
    }
    'True' {
        Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Файл фона есть на сервере')
    }
}
            
#Проверка наличия файла
switch (Test-Path C:\wallpaper\Wallpaper.jpg) {
    'False' {
        Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + "Копирование файла $FileName")
    
        Start-BitsTransfer -Source ("$ServerFolder" + "$FileName") -Destination C:\wallpaper
        switch (Test-Path C:\wallpaper\$FileName) {
            'False' {
                Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + "Файл $FileName не скопировался")
                Exit
            }
            'True' { Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + "Файл $FileName успешно скопировался") }
        }
    
    }
    'True' {
        Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Фон уже существует')
        #Проверка хеш суммы файлов
        Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Сравнение хеш файлов фона')
        $LocalFileHash = Get-FileHash ("$ServerFolder" + "$FileName")
        Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + "Хеш локального файла - $LocalFileHash")
        $ServerFileHash = Get-FileHash C:\wallpaper\Wallpaper.jpg
        Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + "Хеш серверного файла - $ServerFileHash")
        switch ($LocalFileHash.Hash -eq $ServerFileHash.Hash) {
            'True' { Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Замена файлов фона не требуется') }
            'False' {
                Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Требуется замена файлов фона')    
                Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + "Копирование файла $FileName")
                Start-BitsTransfer -Source ("$ServerFolder" + "$FileName") -Destination C:\wallpaper
                Remove-Item "C:\Wallpaper\Wallpaper.jpg"
                switch (Test-Path C:\wallpaper\$FileName) {
                    'False' {
                        Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + "Файл $FileName не скопировался")
                        Exit
                    }
                    'True' { Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + "Файл $FileName успешно скопировался") }
                }
            }
        }

    }
}

#Переименование файла
switch (Test-Path C:\wallpaper\Wallpaper.jpg) {
    'True' { Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Файл уже подготовлен') }
    'False' {
        Rename-Item "C:\Wallpaper\$FileName" -NewName "Wallpaper.jpg"
        Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + "Переименование файла $FileName в Wallpaper.jpg")
    }
}

#Применение фона
switch (Test-Path C:\wallpaper\Wallpaper.jpg) {
    'True' {
        Start-Process C:\Wallpaper\BGInfo\Bginfo.exe "C:\Wallpaper\BGInfo\Config.bgi /NOLICPROMPT /timer:0"
        Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Проверка пройдена, применение фона')
    }
    'False' {
        Add-Content C:\Wallpaper\wallpaper.log -Value ((Get-Date -Format d) + ";" + (Get-Date -Format T) + ";" + 'Проверка не пройдена, остановка скрипта')
        exit
    }
}


