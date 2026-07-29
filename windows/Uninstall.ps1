$ErrorActionPreference = "Stop"

$installDir = Join-Path $env:LOCALAPPDATA "MonitorInputSwitcher"
$desktop = [Environment]::GetFolderPath(
    [Environment+SpecialFolder]::DesktopDirectory
)
$desktopShortcut = Join-Path $desktop "Switch to Mac.lnk"
$startMenuDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Monitor Input Switcher"

if (Test-Path $desktopShortcut) {
    Remove-Item -LiteralPath $desktopShortcut -Force
}

if (Test-Path $startMenuDir) {
    Remove-Item -LiteralPath $startMenuDir -Recurse -Force
}

Write-Host "Monitor Input Switcher was uninstalled."
Write-Host "Removing installed files..."

$cleanupCommand = "Start-Sleep -Milliseconds 500; Remove-Item -LiteralPath '$installDir' -Recurse -Force"
Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @(
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-Command",
    $cleanupCommand
)
