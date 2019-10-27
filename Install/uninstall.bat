
set dirnameSrc=%cd%
set dirnameDst=c:\users\public

IF EXIST %userprofile%\desktop\Homer3.exe.lnk (del /Q /F %userprofile%\desktop\Homer3.exe.lnk)
IF EXIST %dirnameDst%\homer3 (del /F /Q %dirnameDst%\homer3\*)
IF EXIST %dirnameDst%\homer3 (rmdir /S /Q %dirnameDst%\homer3)

