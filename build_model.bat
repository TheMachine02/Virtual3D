@echo off
color 0F
:Loop

echo Converting TONYBOSS_TR2.obj...
tools\mdlconv  file\TONYBOSS_TR2.obj -T -N -S -B
tools\spasm file\TONYBOSS_TR20.inc bin\TONY0.8xv -E -S
tools\spasm file\TONYBOSS_TR21.inc bin\TONY1.8xv -E -S

echo "Converting Suzanne.obj..."
tools\mdlconv  file\Suzanne.obj -C -N -S -B
tools\spasm file\Suzanne0.inc bin\SUZAN0.8xv -E -S
tools\spasm file\Suzanne1.inc bin\SUZAN1.8xv -E -S

tools\xmlconv
pause