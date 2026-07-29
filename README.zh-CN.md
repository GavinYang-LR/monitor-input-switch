# Display Switch

[English](README.md) | [简体中文](README.zh-CN.md)

通过 DDC/CI，在共用一台 AOC CU34G2X 显示器的 Mac mini 和 Windows PC
之间一键切换输入源。

![Display Switch 图标](assets/monitor-switch-icon.png)

实机验证的接线方式：

- Mac mini 连接 HDMI2（`0x12`）
- Windows PC 连接 DP2（`0x10`）
- 输入源选择使用 VCP `0x60`

## 显示器设置

打开 AOC 显示器菜单，将 `Extra → DDC/CI` 设置为 `Yes`。

## macOS：切换到 Windows

1. 安装并启动
   [BetterDisplay](https://github.com/waydabber/BetterDisplay)，DDC 输入切换属于其免费功能。
2. 从最新 Release 下载 `Mac-To-Windows-v1.1.0.zip`。
3. 将 `To Windows.app` 移动到“应用程序”或桌面。
4. 打开 App，将显示器切换到 Windows 所连接的 DP2。

首次运行如果被 macOS 阻止，请右键 App 并选择“打开”。

从源码构建：

```shell
./mac/build-app.sh 1.1.0
```

## Windows：切换到 Mac

1. 下载并解压 `Windows-To-Mac-v1.1.0.zip`。
2. 运行 `Install-Desktop-Shortcut.cmd`。
3. 安装器将运行文件复制到 `%LOCALAPPDATA%\DisplaySwitch`。
4. 打开桌面的 `To Mac`，或按 `Ctrl+Alt+M`。
5. 安装完成后，可以删除下载的 ZIP 和整个解压目录。

日常运行通过 `wscript.exe` 静默启动，不会显示 CMD 或 PowerShell 黑框。
程序直接调用 Windows `Dxva2.dll`，不需要安装 ControlMyMonitor。

卸载时，在开始菜单打开 `Display Switch`，运行 `Uninstall Display Switch`。

## 诊断

在解压后的 Windows 安装包中运行 `Test-Switch-To-Mac.cmd`。测试窗口会保留，
并将显示器枚举、当前 VCP 值和切换结果写入 `last-run.log`。

## 输入源值

| 输入源 | 值 |
|---|---:|
| DP1 | `0x0F` |
| DP2 | `0x10` |
| HDMI1 | `0x11` |
| HDMI2 | `0x12` |

如果接线不同，请修改 macOS 脚本中的 `WINDOWS_DP2` 和 Windows 脚本中的
`$MacHdmi2`。其他型号显示器可能使用不同的输入值，修改前请检查实际 DDC capabilities。

## 许可证

[MIT](LICENSE)
