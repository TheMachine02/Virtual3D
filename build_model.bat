@echo off
color 0F
:Loop

echo Converting TONYBOSS_TR2.obj...
tools\mdlconv  file\TONYBOSS_TR2.obj -T -N -S -B
tools\spasm -I lib/ file\TONYBOSS_TR20.inc bin\TONY0.8xv -E -S
tools\spasm -I lib/ file\TONYBOSS_TR21.inc bin\TONY1.8xv -E -S

echo Converting Suzanne.obj...
tools\mdlconv  file\Suzanne.obj -C -N -S -B
tools\spasm -I lib/ file\Suzanne0.inc bin\SUZAN0.8xv -E -S
tools\spasm -I lib/ file\Suzanne1.inc bin\SUZAN1.8xv -E -S

echo Converting Mateus.obj...
tools\mdlconv  file\Mateus.obj -T -N -S -B
tools\spasm -I lib/ file\Mateus0.inc bin\MATEUS0.8xv -E -S
tools\spasm -I lib/ file\Mateus1.inc bin\MATEUS1.8xv -E -S

echo Converting Tonberry.obj...
tools\mdlconv  file\Tonberry.obj -T -N -S -B
tools\spasm -I lib/ file\Tonberry0.inc bin\TONB0.8xv -E -S
tools\spasm -I lib/ file\Tonberry1.inc bin\TONB1.8xv -E -S

echo Converting London.obj
tools\mdlconv  file\London.obj -T -N -S -B
tools\spasm -I lib/ file\London0.inc bin\LONDON0.8xv -E -S
tools\spasm -I lib/ file\London1.inc bin\LONDON1.8xv -E -S

tools\xmlconv
pause