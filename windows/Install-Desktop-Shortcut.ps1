$ErrorActionPreference = "Stop"

$installDir = Join-Path $env:LOCALAPPDATA "DisplaySwitch"
$legacyInstallDir = Join-Path $env:LOCALAPPDATA "MonitorInputSwitcher"
$desktop = [Environment]::GetFolderPath(
    [Environment+SpecialFolder]::DesktopDirectory
)
$shortcutPath = Join-Path $desktop "To Mac.lnk"
$legacyShortcutPath = Join-Path $desktop "Switch to Mac.lnk"
$startMenuDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Display Switch"
$legacyStartMenuDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Monitor Input Switcher"
$uninstallShortcutPath = Join-Path $startMenuDir "Uninstall Display Switch.lnk"
$sourceSwitchScript = Join-Path $PSScriptRoot "Switch-To-Mac.ps1"
$sourceLauncher = Join-Path $PSScriptRoot "Switch-To-Mac.vbs"
$sourceIcon = Join-Path $PSScriptRoot "MonitorSwitch.ico"
$sourceUninstaller = Join-Path $PSScriptRoot "Uninstall.ps1"
$switchScript = Join-Path $installDir "Switch-To-Mac.ps1"
$launcherPath = Join-Path $installDir "Switch-To-Mac.vbs"
$iconPath = Join-Path $installDir "MonitorSwitch.ico"
$uninstallerPath = Join-Path $installDir "Uninstall.ps1"
$powerShell = Join-Path $env:SystemRoot "System32\WindowsPowerShell\v1.0\powershell.exe"
$wscript = Join-Path $env:SystemRoot "System32\wscript.exe"

if (-not (Test-Path $sourceSwitchScript)) {
    throw "Switch script not found: $sourceSwitchScript"
}

if (-not (Test-Path $sourceIcon)) {
    throw "Icon not found: $sourceIcon"
}

if (-not (Test-Path $sourceLauncher)) {
    throw "Silent launcher not found: $sourceLauncher"
}

if (-not (Test-Path $sourceUninstaller)) {
    throw "Uninstaller not found: $sourceUninstaller"
}

$null = New-Item -ItemType Directory -Path $installDir -Force
$null = New-Item -ItemType Directory -Path $startMenuDir -Force

if (Test-Path $legacyShortcutPath) {
    Remove-Item -LiteralPath $legacyShortcutPath -Force
}

if (Test-Path $legacyStartMenuDir) {
    Remove-Item -LiteralPath $legacyStartMenuDir -Recurse -Force
}

Copy-Item -LiteralPath $sourceSwitchScript -Destination $switchScript -Force
Copy-Item -LiteralPath $sourceLauncher -Destination $launcherPath -Force
Copy-Item -LiteralPath $sourceIcon -Destination $iconPath -Force
Copy-Item -LiteralPath $sourceUninstaller -Destination $uninstallerPath -Force

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $wscript
$shortcut.Arguments = "`"$launcherPath`""
$shortcut.WorkingDirectory = $installDir
$shortcut.IconLocation = "$iconPath,0"
$shortcut.Description = "Switch the display to the Mac"
$shortcut.Hotkey = "CTRL+ALT+M"
$shortcut.Save()

$uninstallShortcut = $shell.CreateShortcut($uninstallShortcutPath)
$uninstallShortcut.TargetPath = $powerShell
$uninstallShortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$uninstallerPath`""
$uninstallShortcut.WorkingDirectory = $installDir
$uninstallShortcut.IconLocation = "$iconPath,0"
$uninstallShortcut.Description = "Uninstall Display Switch"
$uninstallShortcut.Save()

if (-not (Test-Path $shortcutPath)) {
    throw "Shortcut was not created: $shortcutPath"
}

Write-Host ""
Write-Host "Shortcut created successfully:" -ForegroundColor Green
Write-Host $shortcutPath
Write-Host ""
Write-Host "Installed files:"
Write-Host $installDir
Write-Host ""
Write-Host "Double-click 'To Mac' or press Ctrl+Alt+M."
Write-Host "The downloaded ZIP and extracted folder can now be deleted."

if ((Test-Path $legacyInstallDir) -and ($legacyInstallDir -ne $installDir)) {
    Remove-Item -LiteralPath $legacyInstallDir -Recurse -Force
}
