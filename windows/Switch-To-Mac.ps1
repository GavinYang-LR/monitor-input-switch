param(
    [switch]$VerboseMode
)

$ErrorActionPreference = "Stop"

# AOC CU34G2X: VCP 0x60 = Input Select, HDMI2 = 0x12.
$InputSelectVcp = 0x60
$MacHdmi2 = 0x12
$logPath = Join-Path $PSScriptRoot "last-run.log"

Add-Type -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Threading;

public static class MonitorInputSwitcher {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct PHYSICAL_MONITOR {
        public IntPtr Handle;

        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)]
        public string Description;
    }

    private delegate bool MonitorEnumProc(
        IntPtr hMonitor,
        IntPtr hdcMonitor,
        IntPtr monitorRect,
        IntPtr data
    );

    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool EnumDisplayMonitors(
        IntPtr hdc,
        IntPtr clipRect,
        MonitorEnumProc callback,
        IntPtr data
    );

    [DllImport("dxva2.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool GetNumberOfPhysicalMonitorsFromHMONITOR(
        IntPtr hMonitor,
        out uint count
    );

    [DllImport("dxva2.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool GetPhysicalMonitorsFromHMONITOR(
        IntPtr hMonitor,
        uint count,
        [Out] PHYSICAL_MONITOR[] monitors
    );

    [DllImport("dxva2.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool GetVCPFeatureAndVCPFeatureReply(
        IntPtr monitor,
        byte vcpCode,
        IntPtr codeType,
        out uint currentValue,
        out uint maximumValue
    );

    [DllImport("dxva2.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool SetVCPFeature(
        IntPtr monitor,
        byte vcpCode,
        uint newValue
    );

    [DllImport("dxva2.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool DestroyPhysicalMonitors(
        uint count,
        PHYSICAL_MONITOR[] monitors
    );

    public static string Switch(byte vcpCode, uint newValue) {
        var messages = new List<string>();
        var success = false;
        var logicalCount = 0;
        var physicalCount = 0;

        MonitorEnumProc callback = delegate(
            IntPtr logicalMonitor,
            IntPtr hdc,
            IntPtr rect,
            IntPtr data
        ) {
            logicalCount++;
            uint count;

            if (!GetNumberOfPhysicalMonitorsFromHMONITOR(
                logicalMonitor,
                out count
            )) {
                messages.Add(
                    "Logical monitor " + logicalCount +
                    ": cannot get physical monitor count; Win32=" +
                    Marshal.GetLastWin32Error()
                );
                return true;
            }

            var monitors = new PHYSICAL_MONITOR[count];
            if (!GetPhysicalMonitorsFromHMONITOR(
                logicalMonitor,
                count,
                monitors
            )) {
                messages.Add(
                    "Logical monitor " + logicalCount +
                    ": cannot open physical monitor; Win32=" +
                    Marshal.GetLastWin32Error()
                );
                return true;
            }

            try {
                foreach (var monitor in monitors) {
                    physicalCount++;
                    uint current;
                    uint maximum;

                    if (GetVCPFeatureAndVCPFeatureReply(
                        monitor.Handle,
                        vcpCode,
                        IntPtr.Zero,
                        out current,
                        out maximum
                    )) {
                        messages.Add(
                            "Monitor " + physicalCount + " [" +
                            monitor.Description + "]: current VCP 0x60=0x" +
                            current.ToString("X2")
                        );
                    } else {
                        messages.Add(
                            "Monitor " + physicalCount + " [" +
                            monitor.Description +
                            "]: VCP read failed; Win32=" +
                            Marshal.GetLastWin32Error()
                        );
                    }

                    for (var attempt = 1; attempt <= 3; attempt++) {
                        if (SetVCPFeature(
                            monitor.Handle,
                            vcpCode,
                            newValue
                        )) {
                            messages.Add(
                                "SUCCESS: sent VCP 0x60=0x" +
                                newValue.ToString("X2") +
                                " on attempt " + attempt
                            );
                            success = true;
                            break;
                        }

                        messages.Add(
                            "Attempt " + attempt +
                            " failed; Win32=" +
                            Marshal.GetLastWin32Error()
                        );
                        Thread.Sleep(200);
                    }

                    if (success) {
                        break;
                    }
                }
            } finally {
                DestroyPhysicalMonitors(count, monitors);
            }

            return !success;
        };

        if (!EnumDisplayMonitors(
            IntPtr.Zero,
            IntPtr.Zero,
            callback,
            IntPtr.Zero
        )) {
            var error = Marshal.GetLastWin32Error();
            if (!success) {
                messages.Add("EnumDisplayMonitors failed; Win32=" + error);
            }
        }

        if (physicalCount == 0) {
            messages.Add("No physical monitors were found.");
        }

        messages.Insert(
            0,
            success ? "RESULT: SUCCESS" : "RESULT: FAILED"
        );
        return string.Join(Environment.NewLine, messages);
    }
}
"@

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$report = [MonitorInputSwitcher]::Switch(
    [byte]$InputSelectVcp,
    [uint32]$MacHdmi2
)

"$timestamp`r`n$report" | Set-Content -Path $logPath -Encoding UTF8

if ($VerboseMode) {
    Write-Host $report
    Write-Host ""
    Write-Host "Log: $logPath"
}

if ($report -notmatch "RESULT: SUCCESS") {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show(
        "Unable to switch the monitor to HDMI2.`n`n$report`n`nLog: $logPath",
        "Monitor switch failed",
        "OK",
        "Error"
    ) | Out-Null
    exit 1
}

exit 0
