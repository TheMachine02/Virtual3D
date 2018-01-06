@echo off
color 0F
:Loop
echo -----------------------------------
echo Building example.ez80...
spasm -L -T -E -A -S -I include/ -I lib/ example.ez80 bin/TEST.bin
convhex -x bin\TEST.bin
del bin\TEST.bin
echo -----------------------------------
echo Building example1.ez80...
spasm -L -T -E -A -S -I include/ -I lib/ example1.ez80 bin/TEST1.bin
convhex -x bin\TEST1.bin
del bin\TEST1.bin
echo -----------------------------------
echo Building example2.ez80...
spasm -L -T -E -A -S -I include/ -I lib/ example2.ez80 bin/TEST2.bin
convhex -x bin\TEST2.bin
del bin\TEST2.bin
echo -----------------------------------
echo Building alpha.vsl...
spasm -L -T -E -A -S -I include/ -I lib/ alpha.vsl bin/PXLSHADER1.8xv
echo -----------------------------------
echo Building light.vsl...
spasm -L -T -E -A -S -I include/ -I lib/ light.vsl bin/PXLSHADER0.8xv
pause
goto Loop
