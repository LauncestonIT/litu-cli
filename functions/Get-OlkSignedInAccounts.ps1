function Get-OutlookSignedInAccounts {
    param (
        [string]$UsersFolder = "C:\Users"
    )

    # Get the list of user folders, excluding common system profiles
    $UserFolders = Get-ChildItem $UsersFolder | Where-Object {
        $_.PSIsContainer -and
        $_.Name -notin @('All Users', 'Default', 'Default User', 'Public', 'DefaultAppPool')
    }

    # Display the menu of users
    Write-Output "Available user profiles:"
    for ($i = 0; $i -lt $UserFolders.Count; $i++) {
        Write-Output "$($i + 1). $($UserFolders[$i].Name)"
    }

    # Prompt the user for a selection
    $selection = Read-Host "Select user number"

    # Validate the selection
    if (-not [int]::TryParse($selection, [ref]$null) -or $selection -lt 1 -or $selection -gt $UserFolders.Count) {
        Write-Error "Invalid selection. Please select a number between 1 and $($UserFolders.Count)."
        return
    }

    # Get the selected user profile folder name
    $selectedUserProfile = $UserFolders[$selection - 1].Name
    $JsonPath = "$UsersFolder\$selectedUserProfile\AppData\Local\Microsoft\Olk\UserSettings.json"

    # Check if the JSON file exists
    if (-not (Test-Path $JsonPath)) {
        Write-Error "UserSettings.json file not found for the selected user: $selectedUserProfile."
        return
    }

    # Load the JSON file
    try {
        $jsonData = Get-Content -Path $JsonPath -Raw | ConvertFrom-Json
    }
    catch {
        Write-Error "Failed to read or parse the JSON file: $_"
        return
    }

    # Check if the necessary properties are available in the JSON structure
    if (-not $jsonData.Identities -or -not $jsonData.Identities.IdentityMap) {
        Write-Error "IdentityMap not found in the UserSettings.json file. Verify the JSON structure."
        return
    }

    # Use property access to get the IdentityMap as a hashtable
    $identityMap = @{}
    foreach ($property in $jsonData.Identities.IdentityMap.PSObject.Properties) {
        $identityMap[$property.Name] = $property.Value
    }

    # Convert to a custom object for table formatting
    $signedInAccounts = $identityMap.Keys | ForEach-Object {
        [PSCustomObject]@{
            "Email Address" = $_
        }
    }

    # Display in table format
    $signedInAccounts | Format-Table -AutoSize
}
