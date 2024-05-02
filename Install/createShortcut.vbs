
Set objArgs = WScript.Arguments
application = objArgs(0)
startinfolder = ""
if objArgs.Count > 1 then
    startinfolder = objArgs(1)
end if


Set sh = CreateObject("WScript.Shell")
Set shortcut = sh.CreateShortcut(application + ".lnk")

shortcut.TargetPath = application
shortcut.WorkingDirectory = startinfolder
shortcut.Save
