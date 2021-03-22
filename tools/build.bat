@echo off
@cls
color 0F

:Loop

g++ -o mdlconv mdlconv-src/main.cpp -fexceptions -fpie -fstack-clash-protection -Wall -O2 -pipe -D_FORTIFY_SOURCE=2
g++ -o texconv texconv-src/main.cpp -fexceptions -fpie -fstack-clash-protection -Wall -O2 -pipe -D_FORTIFY_SOURCE=2
g++ -o xmlconv xmlconv-src/main.cpp -fexceptions -fpie -fstack-clash-protection -Wall -O2 -pipe -D_FORTIFY_SOURCE=2
g++ -o lut lut.cpp -fexceptions -fpie -fstack-clash-protection -Wall -O2 -pipe -D_FORTIFY_SOURCE=2

pause
goto Loop
