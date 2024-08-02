


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


function Send-ComputerInfoToHudu {
    # Display a progress bar while collecting computer information
    $progressPercentage = 0
    $incrementStep = 8.3

    Write-Progress -Activity "Collecting Computer Information" -Status "$progressPercentage% Complete" -PercentComplete $progressPercentage

    function Get-ClientId {
        # Define the API endpoint with the encoded client name
        $endpoint = "$baseURL/companies?slug=$URLslug"
        try {
            # Perform the GET request using the correct header for API key
            $response = Invoke-RestMethod -Uri $endpoint -Method Get -Headers @{ "x-api-key" = $apiKey }
        
            # Extract the ID from the first company in the response array
            if ($response.companies -and $response.companies.Count -gt 0) {
                return $response.companies[0].id
            } else {
                Write-Output "No company was found"
                return $null
            }
        } catch {
            Write-Host "Error: $_"
            return $null
        }
    }
    
    function Get-Hostname {
        return $env:computername
    }
    
    function Get-Brand {
        $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -Property Manufacturer
        return $computerSystem.Manufacturer
    }
    
    function Get-Model {
        $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -Property Model
        return $computerSystem.Model
    }
    
    function Get-PrimaryEthernetAdapter {
        $activeAdapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.PhysicalMediaType -ne 'Native 802.11' }
        foreach ($adapter in $activeAdapters) {
            $ipAddressDetails = Get-NetIPAddress -InterfaceIndex $adapter.ifIndex | Where-Object { $_.AddressFamily -eq 'IPv4' }
            foreach ($ip in $ipAddressDetails) {
                if ($ip.PrefixOrigin -eq 'Dhcp' -or $ip.PrefixOrigin -eq 'Manual') {
                    return $adapter
                }
            }
        }
        return $null
    }
    
    function Get-WiFiAdapter {
        $wifiAdapters = Get-NetAdapter | Where-Object { $_.PhysicalMediaType -eq 'Native 802.11' }
        foreach ($adapter in $wifiAdapters) {
            return $adapter
        }
        return $null
    }
    
    function Get-IPAddressWiFi {
        $primaryAdapter = Get-WiFiAdapter
        if ($primaryAdapter) {
            # Check if the adapter is connected
            $adapterStatus = Get-NetAdapter -Name $primaryAdapter.Name | Where-Object { $_.Status -eq 'Up' }
            if ($adapterStatus) {
                $ipAddressDetails = Get-NetIPAddress -InterfaceIndex $primaryAdapter.ifIndex | Where-Object { $_.AddressFamily -eq 'IPv4' }
                if ($ipAddressDetails) {
                    $ipAddress = ($ipAddressDetails | Where-Object { $_.InterfaceIndex -eq $primaryAdapter.ifIndex }).IPAddress -join ', '
                    return $ipAddress
                } else {
                    return ""
                }
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    function Get-MACAddressWiFi {
        $primaryAdapter = Get-WiFiAdapter
        if ($primaryAdapter) {
            return $primaryAdapter.MacAddress -replace '-', ':'
        } else {
            return ""
        }
    }
    
    function Get-IPAddressEthernet {
        $wifiAdapter = Get-WiFiAdapter
        if ($wifiAdapter) {
            $wifiStatus = Get-NetAdapter -Name $wifiAdapter.Name | Where-Object { $_.Status -eq 'Up' }
            if ($wifiStatus) {
                return ""
            }
        }
    
        $primaryAdapter = Get-PrimaryEthernetAdapter
        if ($primaryAdapter) {
            $ipAddressDetails = Get-NetIPAddress -InterfaceIndex $primaryAdapter.ifIndex | Where-Object { $_.AddressFamily -eq 'IPv4' }
            if ($ipAddressDetails) {
                return ($ipAddressDetails | Where-Object { $_.InterfaceIndex -eq $primaryAdapter.ifIndex }).IPAddress -join ', '
            } else {
                Write-Host "No IP address found for Ethernet adapter."
                return ""
            }
        } else {
            Write-Host "No primary Ethernet adapter found."
            return ""
        }
    }
    
    function Get-MACAddressEthernet {
        $primaryAdapter = Get-PrimaryEthernetAdapter
        if ($primaryAdapter) {
            return $primaryAdapter.MacAddress -replace '-', ':'
        } else {
            Write-Host "No primary adapter found."
            return ""
        }
    }
    
    function Get-CPU {
        $processor = Get-CimInstance -ClassName Win32_Processor
        return $processor.Name
    }
    
    function Get-Memory {
        $totalMemoryGB = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
        return "{0:N2} GB" -f $totalMemoryGB
    }
    
    function Get-Drive {
        # Get all physical disks
        $disks = Get-PhysicalDisk
    
        # Determine the largest disk based on size
        $largestDisk = $disks | Sort-Object -Property Size -Descending | Select-Object -First 1
    
        # Determine the media type (SSD, HDD, or NVMe)
        $mediaType = switch ($largestDisk.MediaType) {
            "SSD" { "SSD" }
            "HDD" { "HDD" }
            "Unspecified" { if ($largestDisk.BusType -eq "NVMe") { "NVMe SSD" } else { $largestDisk.MediaType } }
            default { $largestDisk.MediaType }
        }
    
        # Return the size in GB and the media type
        $sizeGB = [math]::Round($largestDisk.Size / 1GB, 2)
        return "$sizeGB GB $mediaType"
    }
    
    function Get-OperatingSystem {
        $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -Property Caption
        $formattedOsName = $osInfo.Caption -replace 'Microsoft Windows', 'Windows' -replace '64-bit', ''
        return "$formattedOsName"
    }
    
    function Get-Notes {
        Write-Host "Enter any notes"
        $notes = Read-Host 
        return "$notes"
    }
    
    function Send-PCInfoToHudu {
        $assetTypeId = 9  # Asset type ID for Windows PCs
        $clientID = Get-ClientId
        
        # Endpoint to create an asset in Hudu
        $endpoint = "$baseURL/companies/$clientID/assets"
    
        # Body of the request
        $body = @{
            asset = @{
                asset_layout_id = $assetTypeId
                name = $($pcInfo.Hostname)
                fields = @(
                    @{
                        value = $($pcInfo.Hostname)
                        asset_layout_field_id = 81  # Hostname
                    },
                    @{
                        value = $($pcInfo.Brand)
                        asset_layout_field_id = 56  #  Brand
                    },
                    @{
                        value = $($pcInfo.Model)
                        asset_layout_field_id = 57  # Model
                    },
                    @{
                        value = $($pcInfo.IPAddressEthernet)
                        asset_layout_field_id = 173  #  IP Address (Ethernet)
                    }
                    @{
                        value = $($pcInfo.MACAddressEthernet)
                        asset_layout_field_id = 171  # MAC Address (Ethernet)
                    },
                    @{
                        value = $($pcInfo.IPAddressWiFi)
                        asset_layout_field_id = 174  # IP Address (Wi-Fi)
                    },
                    @{
                        value = $($pcInfo.MACAddressWiFi)
                        asset_layout_field_id = 172  # MAC Address (Wi-Fi)
                    },
                    @{
                        value = $($pcInfo.CPU)
                        asset_layout_field_id = 140  # CPU
                    },
                    @{
                        value = $($pcInfo.Memory)
                        asset_layout_field_id = 58  # Memory
                    },
                    @{
                        value = $($pcInfo.Drive)
                        asset_layout_field_id = 59  # Drive
                    },
                    @{
                        value = $($pcInfo.OperatingSystem)
                        asset_layout_field_id = 62  # Operating system
                    },
                    @{
                        value = $($pcInfo.Notes)
                        asset_layout_field_id = 63  # Notes
                    }
                )
            }
        } | ConvertTo-Json -Depth 5
    
        try {
            # Perform the POST request
            $response = Invoke-RestMethod -Uri $endpoint -Method Post -Headers @{ "x-api-key" = $apiKey} -Body $body -ContentType "application/json"
            Write-Output "Asset successfully created with ID: $($response.id)"
        } catch {
            Write-Output "Failed to create asset in Hudu: $_"
        }
    }
    
    # Increment progress bar and collect computer information
    $progressPercentage += $incrementStep
    Write-Progress -Activity "Collecting Computer Information" -Status "$progressPercentage% Complete" -PercentComplete $progressPercentage
    $hostname = Get-Hostname
    
    $progressPercentage += $incrementStep
    Write-Progress -Activity "Collecting Computer Information" -Status "$progressPercentage% Complete" -PercentComplete $progressPercentage
    $brand = Get-Brand
    
    $progressPercentage += $incrementStep
    Write-Progress -Activity "Collecting Computer Information" -Status "$progressPercentage% Complete" -PercentComplete $progressPercentage
    $model = Get-Model
    
    $progressPercentage += $incrementStep
    Write-Progress -Activity "Collecting Computer Information" -Status "$progressPercentage% Complete" -PercentComplete $progressPercentage
    $ipAddressEthernet = Get-IPAddressEthernet
    
    $progressPercentage += $incrementStep
    Write-Progress -Activity "Collecting Computer Information" -Status "$progressPercentage% Complete" -PercentComplete $progressPercentage
    $macAddressEthernet = Get-MACAddressEthernet
    
    $progressPercentage += $incrementStep
    Write-Progress -Activity "Collecting Computer Information" -Status "$progressPercentage% Complete" -PercentComplete $progressPercentage
    $ipAddressWiFi = Get-IPAddressWiFi
    
    $progressPercentage += $incrementStep
    Write-Progress -Activity "Collecting Computer Information" -Status "$progressPercentage% Complete" -PercentComplete $progressPercentage
    $macAddressWiFi = Get-MACAddressWiFi
    
    $progressPercentage += $incrementStep
    Write-Progress -Activity "Collecting Computer Information" -Status "$progressPercentage% Complete" -PercentComplete $progressPercentage
    $cpu = Get-CPU
    
    $progressPercentage += $incrementStep
    Write-Progress -Activity "Collecting Computer Information" -Status "$progressPercentage% Complete" -PercentComplete $progressPercentage
    $memory = Get-Memory
    
    $progressPercentage += $incrementStep
    Write-Progress -Activity "Collecting Computer Information" -Status "$progressPercentage% Complete" -PercentComplete $progressPercentage
    $drive = Get-Drive
    
    $progressPercentage += $incrementStep
    Write-Progress -Activity "Collecting Computer Information" -Status "$progressPercentage% Complete" -PercentComplete $progressPercentage
    $os = Get-OperatingSystem
    
    $progressPercentage += $incrementStep
    Write-Progress -Activity "Collecting Computer Information" -Status "$progressPercentage% Complete" -PercentComplete $progressPercentage
    $notes = Get-Notes
    
    # Create a PowerShell object with the properties
    $pcInfo = [PSCustomObject]@{
        Hostname = $hostname
        Brand = $brand
        Model = $model
        IPAddressEthernet = $ipAddressEthernet
        MACAddressEthernet = $macAddressEthernet
        IPAddressWiFi = $ipAddressWiFi
        MACAddressWiFi = $macAddressWiFi
        CPU = $cpu
        Memory = $memory
        Drive = $drive
        Location = ""
        OperatingSystem = $os
        Notes = $notes
    }

    # Complete the progress bar
    Write-Progress -Activity "Collecting Computer Information" -Status "100% Complete" -PercentComplete 100 -Completed

    # Convert the object to JSON
    $json = $pcInfo | ConvertTo-Json

    # Output the JSON
    $data = $json | ConvertFrom-Json

    $data | Format-List -Property Hostname, Brand, Model, IPAddressEthernet, MACAddressEthernet, IPAddressWiFi, MACAddressWiFi, CPU, Memory, Drive, Location, OperatingSystem, Notes

    # Prompt the user for confirmation
    Write-Host "Do you want to send this data to Hudu? (yes/no)"
    $response = Read-Host 

    if ($response -eq "yes") {
        # Prompt the user for input and store the values in variables
        Write-Host "Please enter your API Key"
        $apiKey = Read-Host 
        Write-Host "Please enter the Client URL"
        $clientURL = Read-Host 

        # Check if API Key is empty
        if ([string]::IsNullOrWhiteSpace($apiKey)) {
            Write-Error "API Key cannot be empty. Please provide a valid API Key."
            return
        }

        # Check if Client URL is empty
        if ([string]::IsNullOrWhiteSpace($clientURL)) {
            Write-Error "Client URL cannot be empty. Please provide a valid Client URL."
            return
        }

        # Validate Client URL format
        if ($clientURL -notmatch '^https?://') {
            Write-Error "Invalid Client URL format. Please provide a URL starting with http:// or https://."
            return
        }

        $HuduURL = $clientURL -replace '/c/.*', '' 
        $URLslug = $clientURL -replace '.*c/', ''

        $baseURL = "$HuduURL/api/v1"

        Send-PCInfoToHudu
    } else {
        Write-Host "Operation canceled."
    }
}


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


function Show-ConfigMenu {
    Clear-Host
    Write-Host "Please select an option:"
    Write-Host "0) Return to Main Menu"
    Write-Host "1) Change Hostname"
    Write-Host "Enter a number (1-3):"
    
    $choice = Read-Host
    
    switch ($choice) {
        0 {
            Show-MainMenu
        }
        1 {
            Set-Hostname
        }
        2 {
            Show-ConfigMenu
        }
        3 {
            Show-ConfigMenu
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 1 and 4."
            Show-Menu
        }
    }
}

function Show-InstallMenu {
    Clear-Host
    Write-Host "Please select an option:"
    Write-Host "0) Return to Main Menu"
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
    Write-Host "Enter a number (1-3):"
    
    $choice = Read-Host
    
    switch ($choice) {
        1 {
            Show-InstallMenu
        }
        2 {
            Show-ConfigMenu
        }
        3 {
            Send-ComputerInfoToHudu
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 1 and 4."
            Show-Menu
        }
    }
}


# Open Main menu
Show-MainMenu

