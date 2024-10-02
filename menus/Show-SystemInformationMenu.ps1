function Show-SystemInformationMenu {
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
    Write-Host "  4) " -NoNewline; Write-Host "Get Classic Outlook Signed In Accounts" -ForegroundColor Green
    Write-Host "  5) " -NoNewline; Write-Host "Get New Outlook Signed In Accounts" -ForegroundColor Green
    Write-Host "  6) " -NoNewline; Write-Host "Get Local User/s Last Logon Time" -ForegroundColor Green
    Write-Host "  7) " -NoNewline; Write-Host "Get System Uptime" -ForegroundColor Green
    Write-Host "  8) " -NoNewline; Write-Host "Get Windows Version" -ForegroundColor Green
    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Enter a number (0-8):" -ForegroundColor Cyan

    $choice = Read-Host

    switch ($choice) {
        0 {
            Show-MainMenu
        }
        1 {
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Send-ComputerInfoToHudu 
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "Press Enter to return to System Information Menu" -ForegroundColor Gray
            Read-Host
            Show-SystemInformationMenu
        }
        2 {
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Get-BrowserExtensions
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "Press Enter to return to System Information Menu" -ForegroundColor Gray
            Read-Host
            Show-SystemInformationMenu
        }
        3 {
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Get-OSTFiles 
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "Press Enter to return to System Information Menu" -ForegroundColor Gray
            Read-Host
            Show-SystemInformationMenu
        }
        4 {
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Get-ClassicSignedInAccounts 
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "Press Enter to return to System Information Menu" -ForegroundColor Gray
            Read-Host
            Show-SystemInformationMenu
        }
        5 {
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Get-OutlookSignedInAccounts
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "Press Enter to return to System Information Menu" -ForegroundColor Gray
            Read-Host
            Show-SystemInformationMenu
        }
        6 {
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Get-LocalUserLastLogon
            Get-LocalUserLastLogon
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "Press Enter to return to System Information Menu" -ForegroundColor Gray
            Read-Host
            Show-SystemInformationMenu
        }
        7 {
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Get-SystemUptime
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "Press Enter to return to System Information Menu" -ForegroundColor Gray
            Read-Host
            Show-SystemInformationMenu
        }
        8 {
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Get-WindowsVersion
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "Press Enter to return to System Information Menu" -ForegroundColor Gray
            Read-Host
            Show-SystemInformationMenu
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 0 and 8." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-SystemInformationMenu
        }
    }
}
