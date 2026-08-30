' Hermes Agent Gateway - Messaging Platform Integration
Option Explicit
Dim sh, env, existing_pp, fso, rootPath, hermExe
Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
Set env = sh.Environment("PROCESS")
rootPath = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\") - 1) & "\.."
hermExe = rootPath & "\hermes-agent\venv\Scripts\hermes.exe"
If Not fso.FileExists(hermExe) Then
  hermExe = rootPath & "\bin\hermes.exe"
End If
env.Item("HERMES_HOME") = rootPath
env.Item("PYTHONIOENCODING") = "utf-8"
env.Item("HERMES_GATEWAY_DETACHED") = "1"
existing_pp = env.Item("PYTHONPATH")
If Len(existing_pp) > 0 Then
  env.Item("PYTHONPATH") = rootPath & "\hermes-agent;" & existing_pp
Else
  env.Item("PYTHONPATH") = rootPath & "\hermes-agent"
End If
sh.CurrentDirectory = rootPath
sh.Run """" & hermExe & """ gateway run", 0, False