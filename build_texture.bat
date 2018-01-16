@echo off
color 0F
echo Converting...

tools\texconv -A file\fran.png
tools\texconv -D file\train.png
tools\texconv -A file\bombo.png
tools\texconv -A file\m1034.png
tools\texconv -A file\mateus.png
tools\texconv -A file\chocobo.png
tools\texconv -D file\Tonberry.png
tools\texconv -D file\Pool.png
tools\texconv -D file\LONDON.png
tools\texconv -D file\midna.png

spasm -I lib/ file\m1034.inc bin\FLUFFY3.8xv -E -S
spasm -I lib/ file\fran.inc bin\FRAN3.8xv -E -S
spasm -I lib/ file\train.inc bin\TRAIN2.8xv -E -S
spasm -I lib/ file\bombo.inc bin\BOMBO3.8xv -E -S
spasm -I lib/ file\mateus.inc bin\MATEUS2.8xv -E -S
spasm -I lib/ file\chocobo.inc bin\CHOCOBO3.8xv -E -S
spasm -I lib/ file\Tonberry.inc bin\TONB3.8xv -E -S
spasm -I lib/ file\Pool.inc bin\POOL2.8xv -E -S
spasm -I lib/ file\LONDON.inc bin\LONDON2.8xv -E -S
spasm -I lib/ file\midna.inc bin\MIDNA2.8xv -E -S