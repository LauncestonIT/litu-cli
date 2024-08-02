function Show-MainMenu {
    Clear-Host
    Show-Logo
    Write-Host "Please select an option:"
    Write-Host "1) Install"
    Write-Host "2) Config"
    Write-Host "3) Audit"
    Write-Host "Enter a number (1-3):"
    
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
        default {
            Write-Host "Invalid selection. Please enter a number between 1 and 4."
            Show-Menu
        }
    }
}