


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
        Start-Process -FilePath $installExe -ArgumentList "/S /LOBBY /SHORTCUT=disable /dat=$installDat" -Wait
        Set-Location $env:USERPROFILE
    }
}

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
        throw "Sophos installer is missing."
    } else {
        # Start the installer with silent install flag
        Write-Host "Quietly running installer..."
        Start-Process -FilePath $exePath -ArgumentList "--quiet" -Wait
    }
}


function Enable-RDP {
    # Enable RDP by modifying the registry key
    try {
        Write-Host "Enabling Remote Desktop..." -ForegroundColor Green
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\' -Name "fDenyTSConnections" -Value 0
        Write-Host "Remote Desktop enabled successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to enable Remote Desktop." -ForegroundColor Red
        $_ | Out-String
    }

    # Enable RDP through the Windows Firewall
    try {
        Write-Host "Allowing Remote Desktop through the firewall..." -ForegroundColor Green
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
        Write-Host "Firewall rule for Remote Desktop enabled successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to enable firewall rule for Remote Desktop." -ForegroundColor Red
        $_ | Out-String
    }
}

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


function Remove-Backblaze {
    Clear-Host

    $BackblazePath = "C:\Program Files (x86)\Backblaze"
    $Exe = "C:\Program Files (x86)\Backblaze\bzdoinstall.exe"
    $AppName = "Backblaze"

    Write-Host "Checking if Backblaze is installed.."
    if (Test-Path -Path $BackblazePath -PathType Container) {
        Write-Host "Starting uninstall.."
        Start-Process -FilePath $Exe -ArgumentList "-douninstall -nogui" -Wait
        taskkill.exe /IM bzbui.exe /F
        Start-Sleep -Seconds 15
        Remove-Item -Path $BackblazePath -Recurse -Force

        # Define the registry paths for startup applications
    $regPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
    )

    # Iterate through each registry path and remove the application
    foreach ($path in $regPaths) {
        if (Test-Path "$path\$AppName") {
            Remove-ItemProperty -Path $path -Name $AppName -Force
            Write-Output "$AppName removed from $path"
        } else {
            Write-Output "$AppName not found in $path"
        }
    }

    # Define the startup folder paths
    $startupFolders = @(
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
    )

    # Iterate through each startup folder and remove the application shortcut
    foreach ($folder in $startupFolders) {
        $shortcutPath = Join-Path -Path $folder -ChildPath "$AppName.lnk"
        if (Test-Path $shortcutPath) {
            Remove-Item -Path $shortcutPath -Force
            Write-Output "$AppName.lnk removed from $folder"
        } else {
            Write-Output "$AppName.lnk not found in $folder"
        }
    }
        
        Write-Host "Successfully uninstalled, returning to menu.."
        Start-Sleep -Seconds 3
        Show-MainMenu
    } else {
        Write-Host "Backblaze isn't installed, returning to main menu.."
        Start-Sleep -Seconds 3
        Show-MainMenu
    }
}

function Remove-UrBackup {
    Clear-Host

    $UrBackup = "C:\Program Files\UrBackup\Uninstall.exe"

    if (Test-Path -Path $UrBackup -PathType leaf) {
        Write-Host "Starting uninstall.."
        Start-Process -FilePath $UrBackup -ArgumentList "/S" -Wait
        
        Write-Host "Successfully uninstalled, returning to menu.."
        Start-Sleep -Seconds 3
        Show-MainMenu
    } else {
        Write-Host "UrBackup isn't installed, returning to main menu.."
        Start-Sleep -Seconds 3
        Show-MainMenu
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
    Write-Host "Please enter the new hostname"
    $NewHostname = Read-Host 

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
    Clear-host
    Show-Logo
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "               *** Main Menu ***            " -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1) " -NoNewline; Write-Host "Software Deployment" -ForegroundColor Green
    Write-Host "  2) " -NoNewline; Write-Host "Software Removal" -ForegroundColor Green
    Write-Host "  3) " -NoNewline; Write-Host "System Information" -ForegroundColor Green
    Write-Host "  4) " -NoNewline; Write-Host "System Configuration" -ForegroundColor Green
    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Enter a number (1-4):" -ForegroundColor Cyan

    $choice = Read-Host

    # Validate input to ensure it's a number
    if ($choice -match '^[1-9]$') {
        switch ($choice) {
            '1' {
                Show-SoftwareDeploymentMenu
            }
            '2' {
                Show-SoftwareRemovalMenu
            }
            '3' {
                Show-SystemInformationMenu
            }
            '4' {
                Show-SystemConfigurationMenu
            }
            '9' {
                $msg = Read-Host
                msg.exe $env:USERNAME $msg
                Write-host "Sent" $msg
            }
        }
    } else {
        Write-Host "Invalid selection. Please enter a number between 1 and 4." -ForegroundColor Red
        Start-Sleep -Seconds 2
        Show-MainMenu
    }
}


function Show-SoftwareDeploymentMenu {
    Clear-Host
    Show-Logo
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "         *** Software Deployment ***        " -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  0) " -NoNewline; Write-Host "Return to Main Menu" -ForegroundColor Green
    Write-Host "  1) " -NoNewline; Write-Host "Deploy Comet Backup" -ForegroundColor Green
    Write-Host "  2) " -NoNewline; Write-Host "Deploy Sophos" -ForegroundColor Green
    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Enter a number (0-2):" -ForegroundColor Cyan

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
            Write-Host "Invalid selection. Please enter a number between 0 and 2." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-SoftwareDeploymentMenu
        }
    }
}


function Show-SoftwareRemovalMenu {
    Clear-Host
    Show-Logo
    # Adding a title with more formatting
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "          *** Software Removal ***          " -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host ""
    # Display options with numbered choices
    Write-Host "  0) " -NoNewline; Write-Host "Return to Main Menu" -ForegroundColor Green
    Write-Host "  1) " -NoNewline; Write-Host "Uninstall Backblaze" -ForegroundColor Green
    Write-Host "  2) " -NoNewline; Write-Host "Uninstall UrBackup" -ForegroundColor Green
    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Enter a number (0-2):" -ForegroundColor Cyan

    $choice = Read-Host

    switch ($choice) {
        0 {
            Show-MainMenu
        }
        1 {
            Remove-Backblaze
        }
        2 {
            Remove-UrBackup
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 0 and 2." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-SoftwareRemovalMenu
        }
    }
}


function Show-SystemConfigurationMenu {
    Clear-Host
    Show-Logo
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "       *** System Configuration ***         " -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  0) " -NoNewline; Write-Host "Return to Main Menu" -ForegroundColor Green
    Write-Host "  1) " -NoNewline; Write-Host "Change Hostname" -ForegroundColor Green
    Write-Host "  2) " -NoNewline; Write-Host "Enable RDP (Remote Desktop Protocol)" -ForegroundColor Green
    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Enter a number (0-2):" -ForegroundColor Cyan

    $choice = Read-Host

    switch ($choice) {
        0 {
            Show-MainMenu
        }
        1 {
            Set-Hostname
        }
        2 {
            Enable-RDP
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 0 and 2." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-SystemConfigurationMenu
        }
    }
}


function Show-SystemInformationMenu {
    Clear-Host
    Show-Logo
    # Adding a title with more formatting
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "        *** System Information ***          " -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host ""
    # Display options with numbered choices
    Write-Host "  0) " -NoNewline; Write-Host "Return to Main Menu" -ForegroundColor Green
    Write-Host "  1) " -NoNewline; Write-Host "Send Computer Info to Hudu" -ForegroundColor Green
    Write-Host "  2) " -NoNewline; Write-Host "Retrieve Installed Browser Extensions" -ForegroundColor Green
    Write-Host "  3) " -NoNewline; Write-Host "Get OST Files" -ForegroundColor Green
    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Enter a number (0-3):" -ForegroundColor Cyan

    $choice = Read-Host

    switch ($choice) {
        0 {
            Write-Host "Returning to Main Menu..." -ForegroundColor Magenta
            Start-Sleep -Seconds 2
            Show-MainMenu
        }
        1 {
            Write-Host "Sending Computer Info to Hudu..." -ForegroundColor Green
            Start-Sleep -Seconds 2
            Send-ComputerInfoToHudu
        }
        2 {
            Write-Host "Retrieving Browser Extensions..." -ForegroundColor Green
            Start-Sleep -Seconds 2
            Get-BrowserExtensions
        }
        3 {
            Write-Host "Getting OST Files..." -ForegroundColor Green
            Start-Sleep -Seconds 2
            Get-OSTFiles
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 0 and 3." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-SystemInformationMenu
        }
    }
}



# Open Main menu
Show-MainMenu

