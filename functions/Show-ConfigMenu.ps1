function Show-ConfigMenu {
    Clear-Host
    Show-Logo
    Write-Host "--------------------------------------------"
    Write-Host "------------------CONFIG--------------------"
    Write-Host "--------------------------------------------"
    Write-Host "Please select an option:"
    Write-Host "0) Return to Main Menu"
    Write-Host "1) Change Hostname"
    Write-Host "Enter a number (1-3):"
    
    $choice = Read-Host
    
    switch ($choice) {
        0 {
            Show-MainMenu
        }
        1 {
            Set-Hostname
        }
        2 {
            Show-ConfigMenu
        }
        3 {
            Show-ConfigMenu
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 1 and 4."
            Show-Menu
        }
    }
}