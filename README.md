# Display Switch

[English](README.md) | [简体中文](README.zh-CN.md)

One-click DDC/CI input switching for a monitor shared by a Mac and a Windows
PC. The Mac app configures both computer inputs and exports a Windows installer
ZIP with the selected Mac input embedded.

![Display Switch icon](assets/monitor-switch-icon.png)

The current default wiring is:

- Mac on DP1 through a USB-C-to-DisplayPort cable (`0x0F`)
- Windows PC on DP2 (`0x10`)
- Input Select on VCP `0x60`

## Monitor setup

Open the AOC monitor menu and set `Extra → DDC/CI` to `Yes`.

## macOS: switch to Windows

1. Download the Mac ZIP from the latest release.
2. Move both `Display Switch.app` and `To Windows.app` to Applications.
3. Open `Display Switch.app` to configure the Mac and Windows inputs.
4. For daily use, open `To Windows.app`; it switches immediately without
   showing the settings window.

The Mac app includes Apple Silicon USB-C/DisplayPort DDC support and does not
require BetterDisplay.

## Generate the Windows installer

1. Confirm both input selections in the Mac app.
2. Click **Export Windows installer ZIP…** and choose a destination.
3. The app creates `Windows-To-Mac-INPUT.zip` with the selected Mac input
   embedded in the PowerShell switcher.
4. Copy the ZIP to Windows, extract it, and run
   `Install-Desktop-Shortcut.cmd`.
5. Open the desktop shortcut `To Mac`, or press `Ctrl+Alt+M`.

The first launch may require right-clicking the app and choosing **Open**.

To build the app from source:

```shell
./mac/build-app.sh 1.1.0
```

## Windows: switch to Mac

A prebuilt package with the default configuration can also be used:

1. Download and extract `Windows-To-Mac-v1.1.0.zip`.
2. Run `Install-Desktop-Shortcut.cmd`.
3. The installer copies runtime files to `%LOCALAPPDATA%\DisplaySwitch`.
4. Open the desktop shortcut `To Mac`, or press `Ctrl+Alt+M`.
5. The downloaded ZIP and extracted directory can be deleted after installation.

Daily use is launched silently through `wscript.exe`, so no CMD or PowerShell
window appears. The native implementation uses Windows `Dxva2.dll` and does
not require ControlMyMonitor.

To uninstall, open `Display Switch` in the Start menu and run
`Uninstall Display Switch`.

## Diagnostics

Run `Test-Switch-To-Mac.cmd` from the extracted Windows package. It keeps the
console open and writes monitor enumeration, the current VCP value, and the
switch result to `last-run.log`.

## Input values

| Input | Value |
|---|---:|
| DP1 | `0x0F` |
| DP2 | `0x10` |
| HDMI1 | `0x11` |
| HDMI2 | `0x12` |

These four standard inputs can be selected directly in the Mac app. Other
monitor models may use different values; the current UI supports the values in
the table, so verify the monitor's DDC capabilities first.

## License

[MIT](LICENSE)
