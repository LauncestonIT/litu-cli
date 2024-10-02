function Show-SoftwareDeploymentMenu {
    Clear-Host
    Show-Logo
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "         *** Software Deployment ***        " -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  0) " -NoNewline; Write-Host "Return to Main Menu" -ForegroundColor Green
    Write-Host "  1) " -NoNewline; Write-Host "Deploy Comet Backup" -ForegroundColor Green
    Write-Host "  2) " -NoNewline; Write-Host "Deploy Sophos" -ForegroundColor Green
    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Enter a number (0-2):" -ForegroundColor Cyan

    $choice = Read-Host

    switch ($choice) {
        0 {
            Write-Host "Returning to Main Menu..." -ForegroundColor Gray
            Show-MainMenu
        }
        1 {
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Deploy-CometBackup
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "Press Enter to return to Software Deployment Menu" -ForegroundColor Gray
            Read-Host
            Show-SoftwareDeploymentMenu
        }
        2 {
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Deploy-Sophos
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "Press Enter to return to Software Deployment Menu" -ForegroundColor Gray
            Read-Host
            Show-SoftwareDeploymentMenu
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 0 and 2." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-SoftwareDeploymentMenu
        }
    }
}
