@echo off
color 0F
:Loop
tools\spasm -L -T -E -A -S -I include/ example.ez80 bin/TEST.8xp
pause
goto Loop
