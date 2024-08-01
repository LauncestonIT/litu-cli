# Function to display the menu and get user input
function Show-Menu {
    Write-Host "Please select an option:"
    Write-Host "1) Option 1"
    Write-Host "2) Option 2"
    Write-Host "3) Option 3"
    Write-Host "4) Option 4"
    Write-Host "Enter a number (1-4):"
    
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

# Show the menu to the user
Show-Menu
