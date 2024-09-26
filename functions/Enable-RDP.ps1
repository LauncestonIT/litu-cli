function Enable-RDP {
    # Enable RDP by modifying the registry key
    try {
        Write-Host "Enabling Remote Desktop..." -ForegroundColor Green
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\' -Name "fDenyTSConnections" -Value 0
        Write-Host "Remote Desktop enabled successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to enable Remote Desktop." -ForegroundColor Red
        $_ | Out-String
    }

    # Enable RDP through the Windows Firewall
    try {
        Write-Host "Allowing Remote Desktop through the firewall..." -ForegroundColor Green
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
        Write-Host "Firewall rule for Remote Desktop enabled successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to enable firewall rule for Remote Desktop." -ForegroundColor Red
        $_ | Out-String
    }
}