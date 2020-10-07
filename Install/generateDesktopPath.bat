@SET DESKTOP_REG_ENTRY="HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
@SET DESKTOP_REG_KEY="Desktop"
@SET DESKTOP_DIR=
@FOR /F "tokens=1,2*" %%a IN ('REG QUERY %DESKTOP_REG_ENTRY% /v %DESKTOP_REG_KEY% ^| FINDSTR "REG_SZ"') DO (
    @set DESKTOP_DIR="%%c"
)
echo %DESKTOP_DIR% > .\desktopPath.txt
