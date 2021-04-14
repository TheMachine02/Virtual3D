@echo off
@cls
color 0F

:Loop

g++ -o import.exe import-src/main.cpp -fexceptions -fpie -fstack-clash-protection -Wall -O2 -pipe -D_FORTIFY_SOURCE=2
g++ -o texconv.exe texconv-src/main.cpp -fexceptions -fpie -fstack-clash-protection -Wall -O2 -pipe -D_FORTIFY_SOURCE=2
g++ -o xmlconv.exe xmlconv-src/main.cpp -fexceptions -fpie -fstack-clash-protection -Wall -O2 -pipe -D_FORTIFY_SOURCE=2
g++ -o lut.exe lut.cpp -fexceptions -fpie -fstack-clash-protection -Wall -O2 -pipe -D_FORTIFY_SOURCE=2

pause
goto Loop
