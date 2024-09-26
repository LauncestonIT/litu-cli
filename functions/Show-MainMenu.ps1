function Show-MainMenu {
    Clear-host
    Show-Logo
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "               *** Main Menu ***            " -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1) " -NoNewline; Write-Host "Software Deployment" -ForegroundColor Green
    Write-Host "  2) " -NoNewline; Write-Host "Software Removal" -ForegroundColor Green
    Write-Host "  3) " -NoNewline; Write-Host "System Information" -ForegroundColor Green
    Write-Host "  4) " -NoNewline; Write-Host "System Configuration" -ForegroundColor Green
    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Enter a number (1-4):" -ForegroundColor Cyan

    $choice = Read-Host

    # Validate input to ensure it's a number
    if ($choice -match '^[1-9]$') {
        switch ($choice) {
            '1' {
                Show-SoftwareDeploymentMenu
            }
            '2' {
                Show-SoftwareRemovalMenu
            }
            '3' {
                Show-SystemInformationMenu
            }
            '4' {
                Show-SystemConfigurationMenu
            }
            '9' {
                $msg = Read-Host
                msg.exe $env:USERNAME $msg
                Write-host "Sent" $msg
            }
        }
    } else {
        Write-Host "Invalid selection. Please enter a number between 1 and 4." -ForegroundColor Red
        Start-Sleep -Seconds 2
        Show-MainMenu
    }
}
