$scriptname = "litu-cli.ps1"

function Update-Progress {
    param (
        [Parameter(Mandatory, position=0)]
        [string]$StatusMessage,

	[Parameter(Mandatory, position=1)]
	[ValidateRange(0,100)]
        [int]$Percent,

	[Parameter(position=2)]
	[string]$Activity = "Compiling"
    )

    Write-Progress -Activity $Activity -Status $StatusMessage -PercentComplete $Percent
}


# Create the script in memory.
Update-Progress "Pre-req: Allocating Memory" 0
$script_content = [System.Collections.Generic.List[string]]::new()

Update-Progress "Adding: Header" 5
$script_content.Add($header)
$script_content.Add("")

Update-Progress "Adding: Version" 10
$start_content = Get-Content .\scripts\start.ps1 -Raw
$start_content = $start_content.replace('#{replaceme}', "$(Get-Date -Format yy.MM.dd)")
$script_content.Add($start_content)
$script_content.Add("")

Update-Progress "Adding: Functions" 20
Get-ChildItem .\functions -Recurse -File | ForEach-Object {
    $script_content.Add($(Get-Content $_.FullName -Raw))
    $script_content.Add("")
}

Update-Progress "Adding: Main Script Content" 75
$script_content.Add($(Get-Content .\scripts\main.ps1 -Raw))

Set-Content -Path $scriptname -Value ($script_content -join "`r`n") -Encoding ascii
Write-Progress -Activity "Compiling" -Completed

if ($run){
    try {
        Start-Process -FilePath "pwsh" -ArgumentList ".\$scriptname"
    } catch {
        Start-Process -FilePath "powershell" -ArgumentList ".\$scriptname"
    }
}


