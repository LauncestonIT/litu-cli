function Show-MainMenu {
    Clear-Host
    Show-Logo
    Write-Host "Please select an option:"
    Write-Host "1) Install"
    Write-Host "2) Config"
    Write-Host "3) Audit"
    Write-Host "Enter a number (1-2):"
    
    $choice = Read-Host
    
    switch ($choice) {
        1 {
            Show-InstallMenu
        }
        2 {
            Show-ConfigMenu
        }
        3 {
            Write-Host "You selected Option 3."
            # Add the action for Option 3 here
        }
        4 {
            Write-Host "You selected Option 4."
            # Add the action for Option 4 here
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 1 and 4."
            Show-Menu
        }
    }
}