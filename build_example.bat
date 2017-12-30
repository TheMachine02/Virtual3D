@echo off
color 0F
:Loop
echo -----------------------------------
echo Building example.ez80...
tools\spasm -L -T -E -A -S -I include/ -I lib/ example.ez80 bin/TEST.8xp
echo -----------------------------------
echo Building example1.ez80...
tools\spasm -L -T -E -A -S -I include/ -I lib/ example1.ez80 bin/TEST1.8xp
echo -----------------------------------
echo Building example2.ez80...
tools\spasm -L -T -E -A -S -I include/ -I lib/ example2.ez80 bin/TEST2.8xp
echo -----------------------------------
echo Building alpha.vsl...
tools\spasm -L -T -E -A -S -I include/ -I lib/ alpha.vsl bin/PXLSHADER1.8xv
echo -----------------------------------
echo Building light.vsl...
tools\spasm -L -T -E -A -S -I include/ -I lib/ light.vsl bin/PXLSHADER0.8xv
pause
goto Loop
