@echo off
if "%1"=="-v2" (
    echo Version 2
    goto :end)

goto :skip
:end
START powershell.exe -windowstyle hidden -executionpolicy bypass -command %~d0\_TECH\Menu.ps1 -Verb runAs
    
:skip
pause
