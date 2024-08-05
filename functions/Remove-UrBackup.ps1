function Remove-UrBackup {
    Clear-Host

    $UrBackup = "C:\Program Files\UrBackup"
    $Exe = "C:\Program Files\UrBackup\Uninstall.exe"

    Write-Host "Checking if UrBackup is installed.."
    if (Test-Path -Path $UrBackup -PathType Container) {
        Write-Host "Starting uninstall.."
        Start-Process -FilePath $Exe -ArgumentList "/S" -Wait
        
        Write-Host "Successfully uninstalled, returning to menu.."
        Start-Sleep -Seconds 3
        Show-MainMenu
    } else {
        Write-Host "Backblaze isn't installed, returning to main menu.."
        Start-Sleep -Seconds 3
        Show-MainMenu
    }
}