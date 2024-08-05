function Remove-Backblaze {
    Clear-Host

    $Path = "C:\Program Files (x86)\Backblaze"
    $Exe = "C:\Program Files (x86)\Backblaze\bzdoinstall.exe"

    Write-Host "Checking if Backblaze is installed.."
    if (Test-Path -Path $Path -PathType Container) {
        Write-Host "Starting uninstall.."
        Start-Process -FilePath $Exe -ArgumentList "-douninstall -nogui" -Wait
        taskkill.exe /IM bzbui.exe /F
        Remove-Item -Path $Path -Recurse -Force
        Write-Host "Successfully uninstalled, returning to menu.."
        Start-Sleep -Seconds 3
        Show-MainMenu
    } else {
        Write-Host "Backblaze isn't installed, returning to main menu.."
        Start-Sleep -Seconds 3
        Show-MainMenu
    }
}