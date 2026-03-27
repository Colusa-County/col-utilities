@echo off
echo Scanning!
@REM Scan current computer and clone all domain profiles and their data

".\USMT\amd64\scanstate.exe" C:\Users\%USERNAME%\Desktop\store /i:MigCustom.xml /ue:*\* /ui:COLUSACOUNTY\* /o /c /v:13 /l:scan.log

pause