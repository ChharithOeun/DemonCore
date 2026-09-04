' AUTO-SYNC-WATCH-HIDDEN.vbs
' Launches AUTO-SYNC-WATCH.ps1 fully hidden — no console window ever appears.
' This is the entry point Task Scheduler calls instead of powershell.exe
' directly, so even the brief startup window is invisible.

Set oShell = CreateObject("WScript.Shell")
Set oFS    = CreateObject("Scripting.FileSystemObject")

' Resolve the .ps1 in the same folder as this .vbs
sScriptDir = oFS.GetParentFolderName(WScript.ScriptFullName)
sPs1       = oFS.BuildPath(sScriptDir, "AUTO-SYNC-WATCH.ps1")

' Guard: don't launch if the .ps1 is missing
If Not oFS.FileExists(sPs1) Then
    WScript.Quit 1
End If

' Run PowerShell fully hidden (0 = hide window), don't wait for return
oShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & sPs1 & """", 0, False
