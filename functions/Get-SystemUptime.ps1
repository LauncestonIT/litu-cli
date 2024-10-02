function Get-SystemUptime {
    # Get the last boot up time
    $lastBootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime

    # Calculate uptime
    $uptime = (Get-Date) - $lastBootTime

    # Format the output in a more human-readable way
    $formattedUptime = "{0} days, {1} hours, {2} minutes, {3} seconds" -f $uptime.Days, $uptime.Hours, $uptime.Minutes, $uptime.Seconds

    # Display the formatted uptime
    Write-Output "Uptime: $formattedUptime"
}