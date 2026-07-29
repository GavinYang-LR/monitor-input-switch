# Display Switch

[English](README.md) | [简体中文](README.zh-CN.md)

One-click DDC/CI input switching for an AOC CU34G2X shared by a Mac mini
and a Windows PC.

![Display Switch icon](assets/monitor-switch-icon.png)

The tested setup is:

- Mac mini on HDMI2 (`0x12`)
- Windows PC on DP2 (`0x10`)
- Input Select on VCP `0x60`

## Monitor setup

Open the AOC monitor menu and set `Extra → DDC/CI` to `Yes`.

## macOS: switch to Windows

1. Install and start
   [BetterDisplay](https://github.com/waydabber/BetterDisplay). DDC input
   switching is included in its free feature set.
2. Download `Mac-To-Windows-v1.1.0.zip` from the latest release.
3. Move `To Windows.app` to Applications or the Desktop.
4. Open the app to switch the monitor to Windows on DP2.

The first launch may require right-clicking the app and choosing **Open**.

To build the app from source:

```shell
./mac/build-app.sh 1.1.0
```

## Windows: switch to Mac

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

To support another wiring layout, update `WINDOWS_DP2` in the macOS script and
`$MacHdmi2` in the Windows script. Other monitor models may use different
values; verify their DDC capabilities before changing inputs.

## License

[MIT](LICENSE)
