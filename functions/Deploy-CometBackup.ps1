function Deploy-CometBackup {

    <#
    .SYNOPSIS
        Installs Comet Backup from Comet Backup Server.
    #>
    Write-Host "Starting install of Comet Backup..."

    # Get the user input
    Write-Host "Enter your Comet Backup server URL"
    $cometURL = Read-Host 

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