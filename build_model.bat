@echo off
color 0F
:Loop

echo Converting TONYBOSS_TR2.obj...
tools\mdlconv  file\TONYBOSS_TR2.obj -T -N -S -B
spasm -I lib/ file\TONYBOSS_TR20.inc bin\TONY0.8xv -E -S
spasm -I lib/ file\TONYBOSS_TR21.inc bin\TONY1.8xv -E -S

echo Converting Suzanne.obj...
tools\mdlconv  file\Suzanne.obj -C -N -S -B
spasm -I lib/ file\Suzanne0.inc bin\SUZAN0.8xv -E -S
spasm -I lib/ file\Suzanne1.inc bin\SUZAN1.8xv -E -S

echo Converting mateus.obj...
tools\mdlconv  file\mateus.obj -T -N -S -B
spasm -I lib/ file\mateus0.inc bin\MATEUS0.8xv -E -S
spasm -I lib/ file\mateus1.inc bin\MATEUS1.8xv -E -S

echo Converting Tonberry.obj...
tools\mdlconv  file\Tonberry.obj -T -N -S -B
spasm -I lib/ file\Tonberry0.inc bin\TONB0.8xv -E -S
spasm -I lib/ file\Tonberry1.inc bin\TONB1.8xv -E -S

echo Converting London.obj
tools\mdlconv  file\London.obj -T -N -S -B
spasm -I lib/ file\London0.inc bin\LONDON0.8xv -E -S
spasm -I lib/ file\London1.inc bin\LONDON1.8xv -E -S

echo Converting Train.obj
tools\mdlconv  file\Train.obj -T -N -S -B
spasm -I lib/ file\Train0.inc bin\TRAIN0.8xv -E -S
spasm -I lib/ file\Train1.inc bin\TRAIN1.8xv -E -S

echo Converting m1034.obj
tools\mdlconv  file\m1034.obj -T -N -S -B
spasm -I lib/ file\m10340.inc bin\FLUFFY0.8xv -E -S
spasm -I lib/ file\m10341.inc bin\FLUFFY1.8xv -E -S

echo Converting fran.obj
tools\mdlconv  file\fran.obj -T -N -S -B
spasm -I lib/ file\fran0.inc bin\FRAN0.8xv -E -S
spasm -I lib/ file\fran1.inc bin\FRAN1.8xv -E -S

echo Converting Pool.obj
tools\mdlconv  file\Pool.obj -T -N -S -B
spasm -I lib/ file\Pool0.inc bin\POOL0.8xv -E -S
spasm -I lib/ file\Pool1.inc bin\POOL1.8xv -E -S

echo Converting midna.obj
tools\mdlconv  file\midna.obj -T -N -S -B
spasm -I lib/ file\midna0.inc bin\MIDNA0.8xv -E -S
spasm -I lib/ file\midna1.inc bin\MIDNA1.8xv -E -S

tools\xmlconv
pause