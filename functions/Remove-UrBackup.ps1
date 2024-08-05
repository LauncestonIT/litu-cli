function Remove-UrBackup {
    Clear-Host

    $UrBackup = "C:\Program Files\UrBackup\Uninstall.exe"

    if (Test-Path -Path $UrBackup -PathType Container) {
        Write-Host "Starting uninstall.."
        Start-Process -FilePath $UrBackup -ArgumentList "/S" -Wait
        
        Write-Host "Successfully uninstalled, returning to menu.."
        Start-Sleep -Seconds 3
        Show-MainMenu
    } else {
        Write-Host "UrBackup isn't installed, returning to main menu.."
        Start-Sleep -Seconds 3
        Show-MainMenu
    }
}