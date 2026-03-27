echo Loading!
@REM load all users from migration file, pull from current user's desktop

".\USMT\amd64\loadstate.exe" C:\Users\%USERNAME%\Desktop\store /i:MigCustom.xml /mu:COLUSACOUNTY\*:COLUSACOUNTY\* /c /v:13 /l:load.log

pause