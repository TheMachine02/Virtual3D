@echo off
color 0F
:Loop

tools\mdlconv  file\TONYBOSS_TR2.obj -T -N -S -B
tools\spasm file\TONYBOSS_TR20.inc bin\TONY0.8xv -E -S
tools\spasm file\TONYBOSS_TR21.inc bin\TONY1.8xv -E -S
pause

tools\xmlconv
pause