
# If script isn't running as admin, show error message and quit
If (([Security.Principal.WindowsIdentity]::GetCurrent()).Owner.Value -ne "S-1-5-32-544")
{
    Write-Host "===========================================" -Foregroundcolor Red
    Write-Host "-- Scripts must be run as Administrator ---" -Foregroundcolor Red
    Write-Host "-- Right-Click Start -> Terminal(Admin) ---" -Foregroundcolor Red
    Write-Host "===========================================" -Foregroundcolor Red
    break
}