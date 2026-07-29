$ErrorActionPreference = "Stop"

# AOC CU34G2X: VCP 0x60 is Input Select; HDMI2 is 0x12.
$InputSelectVcp = 0x60
$MacHdmi2 = 0x12

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class MonitorDdc {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct PHYSICAL_MONITOR {
        public IntPtr hPhysicalMonitor;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)]
        public string szPhysicalMonitorDescription;
    }

    public delegate bool MonitorEnumProc(
        IntPtr hMonitor,
        IntPtr hdcMonitor,
        IntPtr lprcMonitor,
        IntPtr dwData
    );

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool EnumDisplayMonitors(
        IntPtr hdc,
        IntPtr lprcClip,
        MonitorEnumProc callback,
        IntPtr dwData
    );

    [DllImport("dxva2.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetNumberOfPhysicalMonitorsFromHMONITOR(
        IntPtr hMonitor,
        out uint numberOfPhysicalMonitors
    );

    [DllImport("dxva2.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetPhysicalMonitorsFromHMONITOR(
        IntPtr hMonitor,
        uint physicalMonitorArraySize,
        [Out] PHYSICAL_MONITOR[] physicalMonitorArray
    );

    [DllImport("dxva2.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SetVCPFeature(
        IntPtr hMonitor,
        byte vcpCode,
        uint newValue
    );

    [DllImport("dxva2.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool DestroyPhysicalMonitors(
        uint physicalMonitorArraySize,
        PHYSICAL_MONITOR[] physicalMonitorArray
    );
}
"@

$switched = $false
$errors = [System.Collections.Generic.List[string]]::new()

$callback = [MonitorDdc+MonitorEnumProc] {
    param($hMonitor, $hdcMonitor, $lprcMonitor, $dwData)

    $count = [uint32]0
    if (-not [MonitorDdc]::GetNumberOfPhysicalMonitorsFromHMONITOR($hMonitor, [ref]$count)) {
        return $true
    }

    $monitors = [MonitorDdc+PHYSICAL_MONITOR[]]::new($count)
    if (-not [MonitorDdc]::GetPhysicalMonitorsFromHMONITOR($hMonitor, $count, $monitors)) {
        return $true
    }

    try {
        foreach ($monitor in $monitors) {
            if ([MonitorDdc]::SetVCPFeature(
                $monitor.hPhysicalMonitor,
                [byte]$InputSelectVcp,
                [uint32]$MacHdmi2
            )) {
                $script:switched = $true
                return $false
            }

            $win32Error = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
            $errors.Add("$($monitor.szPhysicalMonitorDescription): Win32 error $win32Error")
        }
    }
    finally {
        [void][MonitorDdc]::DestroyPhysicalMonitors($count, $monitors)
    }

    return $true
}

[void][MonitorDdc]::EnumDisplayMonitors(
    [IntPtr]::Zero,
    [IntPtr]::Zero,
    $callback,
    [IntPtr]::Zero
)

if (-not $switched) {
    $detail = if ($errors.Count -gt 0) { $errors -join "`n" } else { "没有找到可通过 DDC/CI 控制的显示器。" }
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show(
        "无法切换到 Mac 的 HDMI2。`n`n$detail`n`n请确认 AOC 菜单 Extra → DDC/CI = Yes。",
        "显示器切换失败",
        "OK",
        "Error"
    ) | Out-Null
    exit 1
}
