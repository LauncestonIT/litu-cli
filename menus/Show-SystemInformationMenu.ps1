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
    Write-Host "  4) " -NoNewline; Write-Host "Get Local User/s Last Logon Time" -ForegroundColor Green
    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Enter a number (0-4):" -ForegroundColor Cyan

    $choice = Read-Host

    switch ($choice) {
        0 {
            Show-MainMenu
        }
        1 {
            Send-ComputerInfoToHudu
        }
        2 {
            Get-BrowserExtensions
        }
        3 {
            Get-OSTFiles
        }
        4 {
            Get-LocalUserLastLogon
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 0 and 3." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-SystemInformationMenu
        }
    }
}
