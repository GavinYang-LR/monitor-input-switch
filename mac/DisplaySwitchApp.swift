import AppKit

private struct InputSource {
    let name: String
    let value: UInt32

    var label: String { "\(name) (0x\(String(format: "%02X", value)))" }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let sources = [
        InputSource(name: "DP1", value: 0x0F),
        InputSource(name: "DP2", value: 0x10),
        InputSource(name: "HDMI1", value: 0x11),
        InputSource(name: "HDMI2", value: 0x12),
    ]

    private let defaults = UserDefaults(
        suiteName: "io.github.gavinyang-lr.display-switch.shared"
    )!
    private var window: NSWindow!
    private var macPopup: NSPopUpButton!
    private var windowsPopup: NSPopUpButton!
    private var statusLabel: NSTextField!
    private var hasStarted = false

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        start()
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        buildWindow()
        loadSettings()
        showMainWindow()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func applicationShouldHandleReopen(
        _ sender: NSApplication,
        hasVisibleWindows flag: Bool
    ) -> Bool {
        showMainWindow()
        return true
    }

    private func showMainWindow() {
        window.center()
        window.collectionBehavior.insert(.moveToActiveSpace)
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    private func buildWindow() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 510, height: 330),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Display Switch"
        window.center()
        window.isReleasedWhenClosed = false

        let title = NSTextField(labelWithString: "显示器输入源设置")
        title.font = .systemFont(ofSize: 22, weight: .semibold)

        let help = NSTextField(wrappingLabelWithString:
            "选择 Mac 和 Windows 各自连接的显示器输入口。设置会保存在本机，并写入导出的 Windows 安装包。")
        help.textColor = .secondaryLabelColor

        macPopup = NSPopUpButton()
        windowsPopup = NSPopUpButton()
        for source in sources {
            macPopup.addItem(withTitle: source.label)
            windowsPopup.addItem(withTitle: source.label)
        }
        macPopup.target = self
        macPopup.action = #selector(selectionChanged(_:))
        windowsPopup.target = self
        windowsPopup.action = #selector(selectionChanged(_:))

        let form = NSGridView(views: [
            [rightLabel("Mac 输入源"), macPopup],
            [rightLabel("Windows 输入源"), windowsPopup],
        ])
        form.rowSpacing = 12
        form.columnSpacing = 16
        form.column(at: 0).xPlacement = .trailing
        form.column(at: 1).width = 250

        let switchButton = NSButton(title: "切换到 Windows", target: self, action: #selector(switchToWindows))
        switchButton.bezelStyle = .rounded
        switchButton.controlSize = .large

        let exportButton = NSButton(title: "导出 Windows 安装 ZIP…", target: self, action: #selector(exportWindowsZip))
        exportButton.bezelStyle = .rounded
        exportButton.controlSize = .large
        exportButton.keyEquivalent = "\r"

        let buttons = NSStackView(views: [switchButton, exportButton])
        buttons.orientation = .horizontal
        buttons.spacing = 10

        statusLabel = NSTextField(labelWithString: "")
        statusLabel.textColor = .secondaryLabelColor
        statusLabel.alignment = .center

        let stack = NSStackView(views: [title, help, form, buttons, statusLabel])
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        help.maximumNumberOfLines = 3
        help.preferredMaxLayoutWidth = 430
        window.contentView?.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor, constant: -40),
            stack.topAnchor.constraint(equalTo: window.contentView!.topAnchor, constant: 35),
            help.widthAnchor.constraint(equalTo: stack.widthAnchor),
            statusLabel.widthAnchor.constraint(equalTo: stack.widthAnchor),
        ])
    }

    private func rightLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.alignment = .right
        return label
    }

    private func loadSettings() {
        if defaults.integer(forKey: "configurationVersion") < 2 {
            defaults.set(0x0F, forKey: "macInput")
            defaults.set(0x10, forKey: "windowsInput")
            defaults.set(2, forKey: "configurationVersion")
        }
        select(macPopup, value: defaults.object(forKey: "macInput") as? Int ?? 0x0F)
        select(windowsPopup, value: defaults.object(forKey: "windowsInput") as? Int ?? 0x10)
        updateStatus()
    }

    private func select(_ popup: NSPopUpButton, value: Int) {
        popup.selectItem(at: sources.firstIndex(where: { Int($0.value) == value }) ?? 0)
    }

    @objc private func selectionChanged(_ sender: NSPopUpButton) {
        if macPopup.indexOfSelectedItem == windowsPopup.indexOfSelectedItem {
            let otherPopup = sender === macPopup ? windowsPopup! : macPopup!
            let otherIndex = (sender.indexOfSelectedItem + 1) % sources.count
            otherPopup.selectItem(at: otherIndex)
            showAlert(title: "输入源不能相同", message: "Mac 和 Windows 必须连接到两个不同的输入源。")
        }
        saveSettings()
        updateStatus()
    }

    private func saveSettings() {
        defaults.set(Int(selectedMac.value), forKey: "macInput")
        defaults.set(Int(selectedWindows.value), forKey: "windowsInput")
    }

    private var selectedMac: InputSource { sources[macPopup.indexOfSelectedItem] }
    private var selectedWindows: InputSource { sources[windowsPopup.indexOfSelectedItem] }

    private func updateStatus(_ prefix: String? = nil) {
        let route = "Mac: \(selectedMac.name)  ·  Windows: \(selectedWindows.name)"
        statusLabel.stringValue = prefix.map { "\($0) — \(route)" } ?? route
    }

    @objc private func switchToWindows() {
        saveSettings()
        if let bundledCLI = Bundle.main.resourceURL?.appendingPathComponent("m1ddc"),
           FileManager.default.isExecutableFile(atPath: bundledCLI.path) {
            runSwitchCommand(
                executable: bundledCLI.path,
                arguments: ["set", "input", String(selectedWindows.value)]
            )
            return
        }

        let cliCandidates = [
            "/opt/homebrew/bin/betterdisplaycli",
            "/usr/local/bin/betterdisplaycli",
        ]
        guard let cli = cliCandidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) else {
            showAlert(
                title: "DDC 工具缺失",
                message: "当前 App 缺少内置 DDC 工具，请重新安装 Display Switch。"
            )
            return
        }

        runSwitchCommand(
            executable: cli,
            arguments: [
                "set", "-feature=ddc", "-vcp=0x60",
                "-value=0x\(String(format: "%02X", selectedWindows.value))",
            ]
        )
    }

    private func runSwitchCommand(executable: String, arguments: [String]) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                updateStatus("已发送切换命令")
            } else {
                throw NSError(domain: "DisplaySwitch", code: Int(process.terminationStatus))
            }
        } catch {
            showAlert(
                title: "切换失败",
                message: "请确认显示器已开启 DDC/CI，并且 Type‑C 转 DP 线支持 DDC 通信。"
            )
        }
    }

    @objc private func exportWindowsZip() {
        saveSettings()
        guard let templateURL = Bundle.main.resourceURL?.appendingPathComponent("WindowsPackage"),
              FileManager.default.fileExists(atPath: templateURL.path) else {
            showAlert(title: "安装包模板缺失", message: "请重新安装 Display Switch。")
            return
        }

        let panel = NSSavePanel()
        panel.title = "导出 Windows 安装包"
        panel.nameFieldStringValue = "Windows-To-Mac-\(selectedMac.name).zip"
        panel.allowedContentTypes = [.zip]
        guard panel.runModal() == .OK, let destination = panel.url else { return }

        let fm = FileManager.default
        let temporaryRoot = fm.temporaryDirectory
            .appendingPathComponent("DisplaySwitch-\(UUID().uuidString)", isDirectory: true)
        let packageDir = temporaryRoot.appendingPathComponent("Windows-To-Mac", isDirectory: true)

        do {
            try fm.createDirectory(at: temporaryRoot, withIntermediateDirectories: true)
            try fm.copyItem(at: templateURL, to: packageDir)
            try configureWindowsPackage(at: packageDir)

            if fm.fileExists(atPath: destination.path) {
                try fm.removeItem(at: destination)
            }
            let ditto = Process()
            ditto.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
            ditto.arguments = ["-c", "-k", "--sequesterRsrc", "--keepParent", packageDir.path, destination.path]
            try ditto.run()
            ditto.waitUntilExit()
            guard ditto.terminationStatus == 0 else {
                throw NSError(domain: "DisplaySwitch", code: Int(ditto.terminationStatus))
            }
            try? fm.removeItem(at: temporaryRoot)
            updateStatus("Windows 安装包已导出")
            NSWorkspace.shared.activateFileViewerSelecting([destination])
        } catch {
            try? fm.removeItem(at: temporaryRoot)
            showAlert(title: "导出失败", message: error.localizedDescription)
        }
    }

    private func configureWindowsPackage(at packageDir: URL) throws {
        let scriptURL = packageDir.appendingPathComponent("Switch-To-Mac.ps1")
        var script = try String(contentsOf: scriptURL, encoding: .utf8)
        let value = "0x\(String(format: "%02X", selectedMac.value))"
        script = script.replacingOccurrences(
            of: #"(?m)^\$MacInputSource = 0x[0-9A-Fa-f]+\s*$"#,
            with: "$MacInputSource = \(value)",
            options: .regularExpression
        )
        try script.write(to: scriptURL, atomically: true, encoding: .utf8)

        let config = """
        Display Switch Windows installer
        Mac input source: \(selectedMac.name) (\(value))
        Windows input source: \(selectedWindows.name) (0x\(String(format: "%02X", selectedWindows.value)))
        Generated: \(ISO8601DateFormatter().string(from: Date()))
        """
        try config.write(
            to: packageDir.appendingPathComponent("CONFIGURATION.txt"),
            atomically: true,
            encoding: .utf8
        )
    }

    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}
