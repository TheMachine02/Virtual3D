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
pause
goto Loop
