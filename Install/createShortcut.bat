
@echo ====================================
@echo Inside createShortcut.bat %1 %2 

@SET DESKTOP_REG_ENTRY="HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
@SET DESKTOP_REG_KEY="Desktop"
@SET DESKTOP_DIR=
@FOR /F "tokens=1,2*" %%a IN ('REG QUERY %DESKTOP_REG_ENTRY% /v %DESKTOP_REG_KEY% ^| FINDSTR "REG_SZ"') DO (
    @set DESKTOP_DIR="%%c"
)
@echo Desktop dir: %DESKTOP_DIR%

@echo set dirnameSrc=%cd%
@set dirnameSrc=%cd%

@echo IF EXIST "%DESKTOP_DIR%"\%2.lnk (del /Q "%DESKTOP_DIR%"\%2.lnk)
@IF EXIST "%DESKTOP_DIR%"\%2.lnk (del /Q "%DESKTOP_DIR%"\%2.lnk)

@echo cscript "%dirnameSrc%"\createShortcut.vbs %1\%2
@cscript "%dirnameSrc%"\createShortcut.vbs %1\%2

@echo IF EXIST %1\%2.lnk (move %1\%2.lnk "%DESKTOP_DIR%"\%2.lnk)
@IF EXIST %1\%2.lnk (move %1\%2.lnk "%DESKTOP_DIR%"\%2.lnk)

@echo DONE WITH SHORTCUT %2
@echo.
