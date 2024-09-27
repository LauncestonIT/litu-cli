function Get-LocalUserLastLogon {
    # Get all local user profiles
    $userProfiles = Get-WmiObject -Class Win32_NetworkLoginProfile | Where-Object { $_.Name -ne "SYSTEM" -and $_.Name -ne "LOCAL SERVICE" -and $_.Name -ne "NETWORK SERVICE" }

    # Loop through each user and display the name and last logon date
    foreach ($user in $userProfiles) {
        # Check if the LastLogon value is valid
        if ($user.LastLogon -and $user.LastLogon -ne '**********') {
            $lastLogon = [Management.ManagementDateTimeConverter]::ToDateTime($user.LastLogon)
        } else {
            $lastLogon = 'Never logged in'
        }

        # Output the user details
        [PSCustomObject]@{
            UserName      = $user.Name
            LastLogon     = $lastLogon
        }
    }
}