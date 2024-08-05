function Show-MaintenanceMenu {
    Clear-Host
    Write-Host "Please select an option:"
    Write-Host "0) Return to Main Menu"
    Write-Host "1) Remove Backblaze"
    Write-Host "2) Remove UrBackup"
    Write-Host "Enter a number (0-2):"
    
    $choice = Read-Host
    
    switch ($choice) {
        0 {
            Show-MainMenu
        }
        1 {
            Remove-Backblaze
        }
        2 {
            Remove-UrBackup
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 1 and 2."
            Show-Menu
        }
    }
}