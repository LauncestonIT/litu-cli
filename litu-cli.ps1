


# If script isn't running as admin, show error message and quit
If (([Security.Principal.WindowsIdentity]::GetCurrent()).Owner.Value -ne "S-1-5-32-544")
{
    Write-Host "===========================================" -Foregroundcolor Red
    Write-Host "-- Scripts must be run as Administrator ---" -Foregroundcolor Red
    Write-Host "-- Right-Click Start -> Terminal(Admin) ---" -Foregroundcolor Red
    Write-Host "===========================================" -Foregroundcolor Red
    break
}

Function Show-Logo {
    <#

    .SYNOPSIS
        Prints the logo
    #>


    Write-Host "   ,--,                     ,----,                "
    Write-Host ",---.'|                   ,/   .`|                "
    Write-Host "|   | :       ,---,     ,`   .'  :                "
    Write-Host ":   : |    ,`--.' |   ;    ;     /          ,--,  "
    Write-Host "|   ' :    |   :  : .'___,/    ,'         ,'_ /|  "
    Write-Host ";   ; '    :   |  ' |    :     |     .--. |  | :  "
    Write-Host "'   | |__  |   :  | ;    |.';  ;   ,'_ /| :  . |  "
    Write-Host "|   | :.'| '   '  ; `----'  |  |   |  ' | |  . .  "
    Write-Host "'   :    ; |   |  |     '   :  ;   |  | ' |  | |  "
    Write-Host "|   |  ./  '   :  ;     |   |  '   :  | | :  ' ;  "
    Write-Host ";   : ;    |   |  '     '   :  |   |  ; ' |  | '  "
    Write-Host "|   ,/     '   :  |     ;   |.'    :  | : ;  ; |  "
    Write-Host "'---'      ;   |.'      '---'      '  :  `--'   \ "
    Write-Host "           '---'                   :  ,      .-./ "
    Write-Host "                                    `--`----'     "
    Write-Host ""
    Write-Host "======Launceston IT======"
    Write-Host "=====Windows Utility====="
}


Show-Logo
function Show-MainMenu {
    Write-Host "Please select an option:"
    Write-Host "1) Install"
    Write-Host "2) Audit"
    Write-Host "Enter a number (1-2):"
    
    $choice = Read-Host
    
    switch ($choice) {
        1 {
            Write-Host "You selected Option 1."
            # Add the action for Option 1 here
        }
        2 {
            Write-Host "You selected Option 2."
            # Add the action for Option 2 here
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

