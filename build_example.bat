@echo off
color 0F
:Loop
echo -----------------------------------
echo Building example.ez80...
tools\spasm -L -T -E -A -S -I include/ example.ez80 bin/TEST.8xp
echo -----------------------------------
echo Building example1.ez80...
tools\spasm -L -T -E -A -S -I include/ example1.ez80 bin/TEST1.8xp
echo -----------------------------------
echo Building example1.ez80...
tools\spasm -L -T -E -A -S -I include/ example2.ez80 bin/TEST2.8xp
pause
goto Loop
