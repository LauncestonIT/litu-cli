function Remove-Backblaze {
    Clear-Host

    $BackblazePath = "C:\Program Files (x86)\Backblaze"
    $Exe = "C:\Program Files (x86)\Backblaze\bzdoinstall.exe"
    $AppName = "bzbui"

    Write-Host "Checking if Backblaze is installed.."
    if (Test-Path -Path $BackblazePath -PathType Container) {
        Write-Host "Starting uninstall.."
        Start-Process -FilePath $Exe -ArgumentList "-douninstall -nogui" -Wait
        taskkill.exe /IM bzbui.exe /F
        Start-Sleep -Seconds 15
        Remove-Item -Path $BackblazePath -Recurse -Force

        # Define the registry paths for startup applications
    $regPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
    )

    # Iterate through each registry path and remove the application
    foreach ($path in $regPaths) {
        if (Test-Path "$path\$AppName") {
            Remove-ItemProperty -Path $path -Name $AppName -Force
            Write-Output "$AppName removed from $path"
        } else {
            Write-Output "$AppName not found in $path"
        }
    }

    # Define the startup folder paths
    $startupFolders = @(
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
    )

    # Iterate through each startup folder and remove the application shortcut
    foreach ($folder in $startupFolders) {
        $shortcutPath = Join-Path -Path $folder -ChildPath "$AppName.lnk"
        if (Test-Path $shortcutPath) {
            Remove-Item -Path $shortcutPath -Force
            Write-Output "$AppName.lnk removed from $folder"
        } else {
            Write-Output "$AppName.lnk not found in $folder"
        }
    }
        
        Write-Host "Successfully uninstalled, returning to menu.."
        Start-Sleep -Seconds 3
        Show-MainMenu
    } else {
        Write-Host "Backblaze isn't installed, returning to main menu.."
        Start-Sleep -Seconds 3
        Show-MainMenu
    }
}