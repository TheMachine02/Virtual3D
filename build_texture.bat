@echo off
color 0F

tools\TextureConvert -A file\fran.png
tools\TextureConvert -D file\train.png
tools\TextureConvert -A file\bombo.png
tools\TextureConvert -A file\m1034.png
tools\TextureConvert -A file\mateus.png
tools\TextureConvert -A file\chocobo.png

tools\spasm -I lib/ file\m1034.inc bin\FLUFFY3.8xv -E -S
tools\spasm -I lib/ file\fran.inc bin\FRAN3.8xv -E -S
tools\spasm -I lib/ file\train.inc bin\TRAIN2.8xv -E -S
tools\spasm -I lib/ file\bombo.inc bin\BOMBO3.8xv -E -S
tools\spasm -I lib/ file\mateus.inc bin\MATEUS2.8xv -E -S
tools\spasm -I lib/ file\chocobo.inc bin\CHOCOBO3.8xv -E -S