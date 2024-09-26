function Show-MainMenu {
    Clear
    Show-Logo
    Write-Host "--------------------------------------------"
    Write-Host "---------------Main Menu--------------------"
    Write-Host "--------------------------------------------"
    Write-Host "Please select an option:"
    Write-Host "1) Software Deployment"
    Write-Host "2) Software Removal"
    Write-Host "3) System Information"
    Write-Host "4) System Configuration"
    Write-Host "Enter a number (1-4):"
    
    $choice = Read-Host
    
    switch ($choice) {
        1 {
            Show-SoftwareDeploymentMenu
        }
        2 {
            Show-SoftwareRemovalMenu
        }
        3 {
            Show-SystemInformationMenu
        }
        4 {
            Show-SystemConfigurationMenu
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 1 and 4."
            Show-MainMenu
        }
    }
}