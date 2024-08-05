function Show-InstallMenu {
    Clear-Host
    Show-Logo
    Write-Host "--------------------------------------------"
    Write-Host "-----------------INSTALL--------------------"
    Write-Host "--------------------------------------------"
    Write-Host "Please select an option:"
    Write-Host "0) Return to Main Menu"
    Write-Host "1) Comet"
    Write-Host "2) Sophos ( or silent install exe)"
    Write-Host "Enter a number (0-2):"
    
    $choice = Read-Host
    
    switch ($choice) {
        0 {
            Show-MainMenu
        }
        1 {
            Deploy-CometBackup
        }
        2 {
            Deploy-Sophos
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 1 and 2."
            Show-Menu
        }
    }
}