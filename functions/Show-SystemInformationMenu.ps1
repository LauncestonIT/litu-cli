function Show-SystemInformationMenu {
    Clear-Host
    Show-Logo
    # Adding a title with more formatting
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "        *** System Information ***          " -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host ""
    # Display options with numbered choices
    Write-Host "  0) " -NoNewline; Write-Host "Return to Main Menu" -ForegroundColor Green
    Write-Host "  1) " -NoNewline; Write-Host "Send Computer Info to Hudu" -ForegroundColor Green
    Write-Host "  2) " -NoNewline; Write-Host "Retrieve Installed Browser Extensions" -ForegroundColor Green
    Write-Host "  3) " -NoNewline; Write-Host "Get OST Files" -ForegroundColor Green
    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Enter a number (0-3):" -ForegroundColor Cyan

    $choice = Read-Host

    switch ($choice) {
        0 {
            Write-Host "Returning to Main Menu..." -ForegroundColor Magenta
            Start-Sleep -Seconds 2
            Show-MainMenu
        }
        1 {
            Write-Host "Sending Computer Info to Hudu..." -ForegroundColor Green
            Start-Sleep -Seconds 2
            Send-ComputerInfoToHudu
        }
        2 {
            Write-Host "Retrieving Browser Extensions..." -ForegroundColor Green
            Start-Sleep -Seconds 2
            Get-BrowserExtensions
        }
        3 {
            Write-Host "Getting OST Files..." -ForegroundColor Green
            Start-Sleep -Seconds 2
            Get-OSTFiles
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 0 and 3." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-SystemInformationMenu
        }
    }
}
