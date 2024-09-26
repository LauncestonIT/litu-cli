function Show-SystemInformationMenu {
    Clear-Host
    Show-Logo
    Write-Host "--------------------------------------------"
    Write-Host "-------------Software Removal---------------"
    Write-Host "--------------------------------------------"
    Write-Host "Please select an option:"
    Write-Host ""
    Write-Host "0) Return to Main Menu"
    Write-Host "1) Remove Backblaze"
    Write-Host "2) Remove UrBackup"
    Write-Host "Enter a number (0-4):"
    
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

        default {
            Write-Host "Invalid selection. Please enter a number between 1 and 2."
            Show-MaintenanceMenu
        }
    }
}