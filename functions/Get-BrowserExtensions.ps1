function Get-BrowserExtensions {
    # Define browser extension paths
    $chromeExtensionsPath = "\AppData\Local\Google\Chrome\User Data\Default\Extensions"
    $edgeExtensionsPath = "\AppData\Local\Microsoft\Edge\User Data\Default\Extensions"

    # Function to get extensions for a selected browser and user
    function Get-BrowserExtensions {
        param (
            [string]$extensionsDir
        )

        if (Test-Path $extensionsDir) {
            # Get all extension directories
            $extensions = Get-ChildItem $extensionsDir | Where-Object { $_.PSIsContainer }

            # List the extensions
            foreach ($ext in $extensions) {
                # Get subdirectories which represent version numbers
                $versionDirs = Get-ChildItem $ext.FullName | Where-Object { $_.PSIsContainer }

                foreach ($versionDir in $versionDirs) {
                    $manifestPath = Join-Path $versionDir.FullName "manifest.json"
                    if (Test-Path $manifestPath) {
                        $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
                        Write-Host "Name: $($manifest.name)"
                        Write-Host "Description: $($manifest.description)"
                        Write-Host "Version: $($manifest.version)"
                        Write-Host "--------"
                    } else {
                        Write-Host "Extension ID: $($ext.Name) (No manifest.json found in version directory)"
                        Write-Host "--------"
                    }
                }
            }
        } else {
            Write-Host "Extensions directory not found."
        }
    }

    # Get all users in the C:\Users directory
    $users = Get-ChildItem "C:\Users" | Where-Object { $_.PSIsContainer }

    # Generate the browser selection menu
    $browsers = @("Google Chrome", "Microsoft Edge")
    Write-Host "Select a browser:"
    for ($i = 0; $i -lt $browsers.Count; $i++) {
        Write-Host "$($i + 1). $($browsers[$i])"
    }

    # Get browser selection input
    $browserSelection = Read-Host "Enter the number of the browser"
    $browserIndex = [int]$browserSelection - 1

    # Check if the selection is valid
    if ($browserIndex -ge 0 -and $browserIndex -lt $browsers.Count) {
        $selectedBrowser = $browsers[$browserIndex]

        # Generate the user selection menu
        Write-Host "Select a user to list their $selectedBrowser extensions:"
        for ($i = 0; $i -lt $users.Count; $i++) {
            Write-Host "$($i + 1). $($users[$i].Name)"
        }

        # Get user selection input
        $userSelection = Read-Host "Enter the number of the user"
        $userIndex = [int]$userSelection - 1

        # Check if the selection is valid
        if ($userIndex -ge 0 -and $userIndex -lt $users.Count) {
            $selectedUser = $users[$userIndex].Name

            # Determine the extension directory based on the browser selection
            if ($selectedBrowser -eq "Google Chrome") {
                $extensionsDir = "C:\Users\$selectedUser$chromeExtensionsPath"
            } elseif ($selectedBrowser -eq "Microsoft Edge") {
                $extensionsDir = "C:\Users\$selectedUser$edgeExtensionsPath"
            }

            # Get the extensions for the selected browser and user
            Write-Host "$selectedBrowser extensions for user '$selectedUser':"
            Get-BrowserExtensions -extensionsDir $extensionsDir
        } else {
            Write-Host "Invalid user selection."
        }
    } else {
        Write-Host "Invalid browser selection."
    }
}