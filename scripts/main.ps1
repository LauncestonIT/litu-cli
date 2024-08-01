Show-Logo
function Show-MainMenu {
    Write-Host "Please select an option:"
    Write-Host "1) Install"
    Write-Host "2) Audit"
    Write-Host "Enter a number (1-2):"
    
    $choice = Read-Host
    
    switch ($choice) {
        1 {
            Write-Host "You selected Option 1."
            # Add the action for Option 1 here
        }
        2 {
            Write-Host "You selected Option 2."
            # Add the action for Option 2 here
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
# Open Main menu
Show-MainMenu
