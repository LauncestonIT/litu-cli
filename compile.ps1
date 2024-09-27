$scriptname = "litu-cli.ps1"

# Create the script in memory.
$script_content = [System.Collections.Generic.List[string]]::new()

# Add Header
$script_content.Add($header)
$script_content.Add("")

# Add Version
$start_content = Get-Content .\scripts\start.ps1 -Raw
$start_content = $start_content.replace('#{replaceme}', "$(Get-Date -Format yy.MM.dd)")
$script_content.Add($start_content)
$script_content.Add("")

# Add Menu Content
Get-ChildItem .\menus -Recurse -File | ForEach-Object {
    $script_content.Add($(Get-Content $_.FullName -Raw))
    $script_content.Add("")
}

# Add Functions
Get-ChildItem .\functions -Recurse -File | ForEach-Object {
    $script_content.Add($(Get-Content $_.FullName -Raw))
    $script_content.Add("")
}

# Add Main Script Content
$script_content.Add($(Get-Content .\scripts\main.ps1 -Raw))

# Save the compiled script
Set-Content -Path $scriptname -Value ($script_content -join "`r`n") -Encoding ascii

# Run the script if the $run flag is set
if ($run) {
    try {
        Start-Process -FilePath "pwsh" -ArgumentList ".\$scriptname"
    } catch {
        Start-Process -FilePath "powershell" -ArgumentList ".\$scriptname"
    }
}
