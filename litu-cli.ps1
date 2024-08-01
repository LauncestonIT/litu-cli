


# If script isn't running as admin, show error message and quit
If (([Security.Principal.WindowsIdentity]::GetCurrent()).Owner.Value -ne "S-1-5-32-544")
{
    Write-Host "===========================================" -Foregroundcolor Red
    Write-Host "-- Scripts must be run as Administrator ---" -Foregroundcolor Red
    Write-Host "-- Right-Click Start -> Terminal(Admin) ---" -Foregroundcolor Red
    Write-Host "===========================================" -Foregroundcolor Red
    break
}

function Deploy-CometBackup {

    <#
    .SYNOPSIS
        Installs Comet Backup from Comet Backup Server.
    #>
    Write-Host "Starting install of Comet Backup..."

    # Get the user input
    $cometURL = Read-Host "Enter your Comet Backup server URL"

    if (-not $cometURL) {
        throw "No URL provided."
    }

    $url = "$cometURL/dl/1"
    $zipPath = "$env:TEMP\comet.zip"
    $extractPath = "$env:TEMP\comet"
    
    # Download the zip file
    try {
        Write-Host "Downloading Comet Backup from $url..."
        Invoke-WebRequest -Uri $url -OutFile $zipPath
    }
    catch {
        throw "Failed to download the file from $url. $_"
    }

    # Verify the zip file is downloaded
    if (-Not (Test-Path $zipPath)) {
        throw "The ZIP file was not downloaded successfully."
    }

    # Extract the zip file
    if (Test-Path $extractPath) {
        Remove-Item -Path $extractPath -Recurse -Force
    }
    
    try {
        Write-Host "Extracting Comet Backup installer..."
        Expand-Archive -Path $zipPath -DestinationPath $extractPath
    }
    catch {
        throw "Failed to extract the ZIP file. $_"
    }

    # Verify the necessary files are extracted
    $installExe = Join-Path -Path $extractPath -ChildPath "install.exe"
    $installDat = Join-Path -Path $extractPath -ChildPath "install.dat"
    
    if (-Not (Test-Path $installExe) -Or -Not (Test-Path $installDat)) {
        throw "Installation files are missing."
    } else {
        # Start the installer with silent install flag
        Write-Host "Silently running installer in lobby mode..."
        Set-Location -Path $extractPath
        $process = Start-Process -FilePath $installExe -ArgumentList "/S /LOBBY /SHORTCUT=disable /dat=$installDat" -Wait
        Set-Location $env:USERPROFILE

        if ($process.ExitCode -eq 0) {
            Write-Host "Installation completed successfully."
        } else {
            Write-Host "Installation failed with exit code $($process.ExitCode)."
        }
    }
}

function Deploy-Sophos {

    <#
    .SYNOPSIS
        Downloads Sophos from URL and Installs any exe installer silently.
    #>

    # Get the user input
    $URL = Read-Host "Enter Sophos exe URL"

    if (-not $URL) {
        throw "No URL provided."
    }

    $exePath = "$env:TEMP\SophosSetup.exe"
    
    # Download the zip file
    try {
        Write-Host "Downloading Sophos from $url..."
        Invoke-WebRequest -Uri $url -OutFile $exePath
    }
    catch {
        throw "Failed to download the file from $url. $_"
    }
    
    if (-Not (Test-Path $exePath)) {
        throw "Sophos installer are missing."
    } else {
        # Start the installer with silent install flag
        Write-Host "Quietly running installer..."
        Start-Process -FilePath $exePath -ArgumentList "--quiet" -Wait
    }
}




function Show-InstallMenu {
    Write-Host "Please select an option:"
    Write-Host "0) Main Menu"
    Write-Host "1) Comet"
    Write-Host "2) Sophos ( or silent install exe)"
    Write-Host "Enter a number (0-2):"
    
    $choice = Read-Host
    
    switch ($choice) {
        0 {
            Show-MainMenu
        }
        1 {
            Deploy-CometBackup
        }
        2 {
            Deploy-Sophos
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 1 and 2."
            Show-Menu
        }
    }
}

Function Show-Logo {
    <#

    .SYNOPSIS
        Prints the logo
    #>


                                                                                                             
                                                                                                             
Write-Host "lllllll   iiii          tttt                                                                 lllllll   iiii  "
Write-Host "l:::::l  i::::i      ttt:::t                                                                 l:::::l  i::::i "
Write-Host "l:::::l   iiii       t:::::t                                                                 l:::::l   iiii  "
Write-Host "l:::::l              t:::::t                                                                 l:::::l         "
Write-Host " l::::l iiiiiiittttttt:::::ttttttt    uuuuuu    uuuuuu                       cccccccccccccccc l::::l iiiiiii "
Write-Host " l::::l i:::::it:::::::::::::::::t    u::::u    u::::u                     cc:::::::::::::::c l::::l i:::::i "
Write-Host " l::::l  i::::it:::::::::::::::::t    u::::u    u::::u                    c:::::::::::::::::c l::::l  i::::i "
Write-Host " l::::l  i::::itttttt:::::::tttttt    u::::u    u::::u   --------------- c:::::::cccccc:::::c l::::l  i::::i "
Write-Host " l::::l  i::::i      t:::::t          u::::u    u::::u   -:::::::::::::- c::::::c     ccccccc l::::l  i::::i "
Write-Host " l::::l  i::::i      t:::::t          u::::u    u::::u   --------------- c:::::c              l::::l  i::::i "
Write-Host " l::::l  i::::i      t:::::t          u::::u    u::::u                   c:::::c              l::::l  i::::i "
Write-Host " l::::l  i::::i      t:::::t    ttttttu:::::uuuu:::::u                   c::::::c     ccccccc l::::l  i::::i "
Write-Host "l::::::li::::::i     t::::::tttt:::::tu:::::::::::::::uu                 c:::::::cccccc:::::cl::::::li::::::i"
Write-Host "l::::::li::::::i     tt::::::::::::::t u:::::::::::::::u                  c:::::::::::::::::cl::::::li::::::i"
Write-Host "l::::::li::::::i       tt:::::::::::tt  uu::::::::uu:::u                   cc:::::::::::::::cl::::::li::::::i"
Write-Host "lllllllliiiiiiii         ttttttttttt      uuuuuuuu  uuuu                     cccccccccccccccclllllllliiiiiiii"
}


function Show-MainMenu {
    Clear-Host
    Show-Logo
    Write-Host "Please select an option:"
    Write-Host "1) Install"
    Write-Host "2) Config"
    Write-Host "3) Audit"
    Write-Host "Enter a number (1-2):"
    
    $choice = Read-Host
    
    switch ($choice) {
        1 {
            Show-InstallMenu
        }
        2 {
            Show-ConfigMenu
        }
        3 {
            Write-Host "You selected Option 3."
            # Add the action for Option 3 here
        }
        4 {
            Write-Host "You selected Option 4."
            # Add the action for Option 4 here
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 1 and 4."
            Show-Menu
        }
    }
}


# Open Main menu
Show-MainMenu

