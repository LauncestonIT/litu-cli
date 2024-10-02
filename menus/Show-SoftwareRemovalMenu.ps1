function Show-SoftwareRemovalMenu {
    Clear-Host
    Show-Logo
    # Adding a title with more formatting
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "          *** Software Removal ***          " -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host ""
    # Display options with numbered choices
    Write-Host "  0) " -NoNewline; Write-Host "Return to Main Menu" -ForegroundColor Green
    Write-Host "  1) " -NoNewline; Write-Host "Uninstall Backblaze" -ForegroundColor Green
    Write-Host "  2) " -NoNewline; Write-Host "Uninstall UrBackup" -ForegroundColor Green
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
            Remove-Backblaze
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "Press Enter to return to Software Removal Menu" -ForegroundColor Gray
            Read-Host
            Show-SoftwareRemovalMenu
        }
        2 {
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Remove-UrBackup
            Write-Host "--------------------------------------------" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "Press Enter to return to Software Removal Menu" -ForegroundColor Gray
            Read-Host
            Show-SoftwareRemovalMenu
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 0 and 2." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-SoftwareRemovalMenu
        }
    }
}
