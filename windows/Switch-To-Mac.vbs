Option Explicit

Dim shell
Dim fileSystem
Dim scriptDirectory
Dim powerShellScript
Dim command

Set shell = CreateObject("WScript.Shell")
Set fileSystem = CreateObject("Scripting.FileSystemObject")

scriptDirectory = fileSystem.GetParentFolderName(WScript.ScriptFullName)
powerShellScript = fileSystem.BuildPath(scriptDirectory, "Switch-To-Mac.ps1")

command = "powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File " _
    & Chr(34) & powerShellScript & Chr(34)

' Window style 0 keeps the PowerShell/CMD window completely hidden.
shell.Run command, 0, False
