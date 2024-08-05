function Show-MainMenu {
    Clear
    Show-Logo
    Write-Host "--------------------------------------------"
    Write-Host "---------------MAIN MENU--------------------"
    Write-Host "--------------------------------------------"
    Write-Host "Please select an option:"
    Write-Host "1) Install"
    Write-Host "2) Config"
    Write-Host "3) Audit"
    Write-Host "4) Maintenance"
    Write-Host "Enter a number (1-4):"
    
    $choice = Read-Host
    
    switch ($choice) {
        1 {
            Show-InstallMenu
        }
        2 {
            Show-ConfigMenu
        }
        3 {
            Send-ComputerInfoToHudu
        }
        4 {
            Show-MaintenanceMenu
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 1 and 4."
            Show-MainMenu
        }
    }
}