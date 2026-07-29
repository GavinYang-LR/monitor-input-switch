$ErrorActionPreference = "Stop"

$installDir = Join-Path $env:LOCALAPPDATA "DisplaySwitch"
$legacyInstallDir = Join-Path $env:LOCALAPPDATA "MonitorInputSwitcher"
$desktop = [Environment]::GetFolderPath(
    [Environment+SpecialFolder]::DesktopDirectory
)
$desktopShortcut = Join-Path $desktop "To Mac.lnk"
$legacyDesktopShortcut = Join-Path $desktop "Switch to Mac.lnk"
$startMenuDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Display Switch"
$legacyStartMenuDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Monitor Input Switcher"

if (Test-Path $desktopShortcut) {
    Remove-Item -LiteralPath $desktopShortcut -Force
}

if (Test-Path $legacyDesktopShortcut) {
    Remove-Item -LiteralPath $legacyDesktopShortcut -Force
}

if (Test-Path $startMenuDir) {
    Remove-Item -LiteralPath $startMenuDir -Recurse -Force
}

if (Test-Path $legacyStartMenuDir) {
    Remove-Item -LiteralPath $legacyStartMenuDir -Recurse -Force
}

if (Test-Path $legacyInstallDir) {
    Remove-Item -LiteralPath $legacyInstallDir -Recurse -Force
}

Write-Host "Display Switch was uninstalled."
Write-Host "Removing installed files..."

$cleanupCommand = "Start-Sleep -Milliseconds 500; Remove-Item -LiteralPath '$installDir' -Recurse -Force"
Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @(
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-Command",
    $cleanupCommand
)
