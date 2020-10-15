@echo off
@echo.
@echo.
@echo   PLEASE WAIT ... INSTALLTION WILL START IN A FEW MINUTES ...
@echo.
@move .\installtemp .\setup.exe
@call .\setup.exe  1> setup.log 2>&1   
@move .\setup.exe .\installtemp 

