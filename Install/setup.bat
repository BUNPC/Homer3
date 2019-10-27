@echo off
@echo.
@echo.
@echo   PLEASE WAIT ... INSTALLTION WILL START IN A FEW MINUTES ...
@echo.
@move .\installtemp .\setup.exe
@call .\setup.exe
@move .\setup.exe .\installtemp 

