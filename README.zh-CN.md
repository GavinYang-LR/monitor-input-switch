# Display Switch

[English](README.md) | [简体中文](README.zh-CN.md)

通过 DDC/CI，在共用一台显示器的 Mac 和 Windows PC 之间一键切换输入源。
Mac App 可配置两台电脑各自连接的输入源，并直接生成已经写入配置的 Windows
安装 ZIP。

![Display Switch 图标](assets/monitor-switch-icon.png)

当前默认接线方式：

- Mac 通过 Type-C 转 DP 连接 DP1（`0x0F`）
- Windows PC 连接 DP2（`0x10`）
- 输入源选择使用 VCP `0x60`

## 显示器设置

打开 AOC 显示器菜单，将 `Extra → DDC/CI` 设置为 `Yes`。

## macOS：切换到 Windows

1. 从最新 Release 下载 Mac 安装 ZIP。
2. 将 `Display Switch.app` 和 `To Windows.app` 都移动到“应用程序”。
3. 打开 `Display Switch.app`，分别选择 Mac 和 Windows 所连接的输入源。
4. 日常直接打开 `To Windows.app`，它会立即切换，不显示设置窗口。

Mac App 已内置 Apple Silicon Type-C/DisplayPort DDC 支持，不需要安装
BetterDisplay。

## 生成 Windows 安装包

1. 在 Mac App 中确认 Mac 和 Windows 的输入源设置正确。
2. 点击“导出 Windows 安装 ZIP…”并选择保存位置。
3. App 会生成 `Windows-To-Mac-输入源.zip`，Mac 的输入源值已经写入安装包。
4. 将 ZIP 复制到 Windows、解压，并运行 `Install-Desktop-Shortcut.cmd`。
5. 之后打开桌面的 `To Mac`，或按 `Ctrl+Alt+M`。

首次运行如果被 macOS 阻止，请右键 App 并选择“打开”。

从源码构建：

```shell
./mac/build-app.sh 1.1.0
```

## Windows：切换到 Mac

也可以使用预先构建的默认配置包：

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

上述四种输入源可以直接在 Mac App 中选择。其他型号显示器可能使用不同的输入值；
当前界面仅支持表中这些标准值，请先检查显示器的 DDC capabilities。

## 许可证

[MIT](LICENSE)
