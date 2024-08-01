function Set-Hostname {
    # Prompt the user for the new hostname
    $NewHostname = Read-Host "Please enter the new hostname"

    # Get the current hostname
    $currentHostname = (Get-WmiObject -Class Win32_ComputerSystem).Name

    # Check if the new hostname is the same as the current one
    if ($currentHostname -eq $NewHostname) {
        Write-Host "The hostname is already set to '$NewHostname'. No changes needed."
        return
    }

    try {
        # Set the new hostname
        Rename-Computer -NewName $NewHostname -Force

        # Prompt for restart to apply the new hostname
        Write-Host "Hostname changed to '$NewHostname'. A restart is required to apply the changes."
    }
    catch {
        Write-Error "An error occurred while changing the hostname: $_"
    }
}
