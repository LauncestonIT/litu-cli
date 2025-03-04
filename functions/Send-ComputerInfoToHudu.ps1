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
