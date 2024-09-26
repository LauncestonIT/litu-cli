function Show-SystemConfigurationMenu {
    Clear-Host
    Show-Logo
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "       *** System Configuration ***         " -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  0) " -NoNewline; Write-Host "Return to Main Menu" -ForegroundColor Green
    Write-Host "  1) " -NoNewline; Write-Host "Change Hostname" -ForegroundColor Green
    Write-Host "  2) " -NoNewline; Write-Host "Enable RDP (Remote Desktop Protocol)" -ForegroundColor Green
    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Enter a number (0-2):" -ForegroundColor Cyan

    $choice = Read-Host

    switch ($choice) {
        0 {
            Show-MainMenu
        }
        1 {
            Set-Hostname
        }
        2 {
            Enable-RDP
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 0 and 2." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-SystemConfigurationMenu
        }
    }
}
