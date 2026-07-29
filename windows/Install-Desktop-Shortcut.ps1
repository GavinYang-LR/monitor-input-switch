$ErrorActionPreference = "Stop"

$desktop = [Environment]::GetFolderPath(
    [Environment+SpecialFolder]::DesktopDirectory
)
$shortcutPath = Join-Path $desktop "Switch to Mac.lnk"
$switchScript = Join-Path $PSScriptRoot "Switch-To-Mac.ps1"
$iconPath = Join-Path $PSScriptRoot "MonitorSwitch.ico"
$powerShell = Join-Path $env:SystemRoot "System32\WindowsPowerShell\v1.0\powershell.exe"

if (-not (Test-Path $switchScript)) {
    throw "Switch script not found: $switchScript"
}

if (-not (Test-Path $iconPath)) {
    throw "Icon not found: $iconPath"
}

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $powerShell
$shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$switchScript`""
$shortcut.WorkingDirectory = $PSScriptRoot
$shortcut.IconLocation = "$iconPath,0"
$shortcut.Description = "Switch AOC CU34G2X to the Mac mini on HDMI2"
$shortcut.Hotkey = "CTRL+ALT+M"
$shortcut.Save()

if (-not (Test-Path $shortcutPath)) {
    throw "Shortcut was not created: $shortcutPath"
}

Write-Host ""
Write-Host "Shortcut created successfully:" -ForegroundColor Green
Write-Host $shortcutPath
Write-Host ""
Write-Host "Double-click 'Switch to Mac' or press Ctrl+Alt+M."
