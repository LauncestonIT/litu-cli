function Deploy-Sophos {

    <#
    .SYNOPSIS
        Downloads Sophos from URL and Installs any exe installer silently.
    #>

    # Get the user input
    Write-Host "Enter Sophos exe URL"
    $URL = Read-Host 

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
