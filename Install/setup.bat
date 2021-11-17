@echo off
@echo.
@echo.
@echo   PLEASE WAIT ... INSTALLATION WILL START IN A FEW MINUTES ...
@echo.
@call .\uninstall.bat
@move .\installtemp .\setup.exe
@echo.
@echo   NOTE: In case of installation failure, refer to log file setup.log .
@echo.
@(call .\setup.exe)
@move .\setup.exe .\installtemp 

