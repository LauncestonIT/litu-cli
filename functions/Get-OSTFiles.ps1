function Get-OSTFiles {
    # Define the users directory
    $UsersFolder = "C:\Users"

    # Get the list of user folders, excluding common system profiles
    $UserFolders = Get-ChildItem $UsersFolder | Where-Object {
        $_.PSIsContainer -and
        $_.Name -notin @('All Users', 'Default', 'Default User', 'Public', 'DefaultAppPool')
    }

    # Display the menu of users
    for ($i = 0; $i -lt $UserFolders.Count; $i++) {
        Write-Output "$($i + 1). $($UserFolders[$i].Name)"
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

            # Display the full paths of any found OST files
            if ($OSTFiles) {
                $OSTFiles.FullName
            } else {
                Write-Output "No OST files found for user $($SelectedUser.Name)."
            }
        } else {
            Write-Output "Outlook folder does not exist for user $($SelectedUser.Name)."
        }
    } else {
        Write-Output "Invalid selection. Please enter a valid user number."
    }
}
