function Get-WindowsVersion {
    # Get Windows version details from the registry and operating system
    $windowsVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseID
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $osBuild = $os.BuildNumber
    $osVersion = $os.Version
    $windowsEdition = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion

    # Display the version information in a human-readable format
    Write-Output "Windows Version: $windowsVersion"
    Write-Output "OS Build: $osBuild"
    Write-Output "OS Version: $osVersion"
    Write-Output "Display Version: $windowsEdition"
}