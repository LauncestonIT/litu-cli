function Show-MaintenanceMenu {
    Clear-Host
    Show-Logo
    Write-Host "--------------------------------------------"
    Write-Host "---------------MAINTENANCE------------------"
    Write-Host "--------------------------------------------"
    Write-Host "Please select an option:"
    Write-Host "0) Return to Main Menu"
    Write-Host "1) Remove Backblaze"
    Write-Host "2) Remove UrBackup"
    Write-Host "3) List Browser Extensions"
    Write-Host "4) List OST Files"
    Write-Host "Enter a number (0-4):"
    
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
        3 {
            Get-BrowserExtensions
        }
        4 {
            Get-OSTFiles
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 1 and 2."
            Show-MaintenanceMenu
        }
    }
}