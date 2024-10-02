function Get-ClassicSignedInAccounts {
    # Define the users directory
    $UsersFolder = "C:\Users"

    # Get the list of user folders, excluding common system profiles
    $UserFolders = Get-ChildItem $UsersFolder | Where-Object {
        $_.PSIsContainer -and
        $_.Name -notin @('All Users', 'Default', 'Default User', 'Public', 'DefaultAppPool')
    }

    if ($UserFolders.Count -eq 0) {
        return
    }

    # Display the menu of users
    for ($i = 0; $i -lt $UserFolders.Count; $i++) {
        Write-Host "$($i + 1). $($UserFolders[$i].Name)"
    }

    # Prompt the user for a selection
    $selection = Read-Host "Select user number"

    # Validate the selection
    if ($selection -match '^\d+$' -and
        $selection -ge 1 -and
        $selection -le $UserFolders.Count) {

        # Get the selected user
        $SelectedUser = $UserFolders[$selection - 1]

        # Define the path to the user's AppData\Local\Microsoft\Outlook folder
        $OutlookFolder = Join-Path $SelectedUser.FullName "AppData\Local\Microsoft\Outlook"

        # Check if the Outlook folder exists
        if (Test-Path $OutlookFolder) {

            # Search for OST files in the user's Outlook folder
            $OSTFiles = Get-ChildItem -Path $OutlookFolder -Filter *.ost -ErrorAction SilentlyContinue

            # Display the OST files in a formatted table
            if ($OSTFiles) {
                $OutputTable = @()

                foreach ($OSTFile in $OSTFiles) {
                    # Handle both formats: email@domain.com.ost and email@domain.com - Profile.ost
                    if ($OSTFile.Name -match '^([\w\.-]+@[\w\.-]+)\.ost$') {
                        $Email = $matches[1]
                        $Profile = "Default" # Default profile name
                    }
                    elseif ($OSTFile.Name -match '^([\w\.-]+@[\w\.-]+)( - )(.*)\.ost$') {
                        $Email = $matches[1]
                        $Profile = $matches[3]
                    }
                    else {
                        continue
                    }

                    # Create an object with the extracted information
                    $OutputTable += [pscustomobject]@{
                        'Profile Name'  = $Profile
                        'Email Address' = $Email
                    }
                }

                # Group the table by Profile Name, then sort by Email Address within each group
                $GroupedTable = $OutputTable | Sort-Object -Property 'Profile Name', 'Email Address'

                # Display each profile with its associated emails
                $CurrentProfile = ""
                foreach ($Row in $GroupedTable) {
                    if ($Row.'Profile Name' -ne $CurrentProfile) {
                        # Print a blank line between profile sections
                        if ($CurrentProfile -ne "") {
                            Write-Host "_____________"
                        }

                        # Display the profile name header
                        $CurrentProfile = $Row.'Profile Name'
                        Write-Host ""
                        Write-Host "Profile: $CurrentProfile" -ForegroundColor Yellow
                        Write-Host "-------------"
                    }
                    # Display each email under the corresponding profile
                    Write-Host "$($Row.'Email Address')" -ForegroundColor Cyan
                }
            }
        }
    }
}
