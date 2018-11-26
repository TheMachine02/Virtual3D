@echo off
color 0F
echo Converting...

tools\texconv -D file\CavesOfKaliyaTRIII.png
tools\texconv -D file\CityTRIII.png
tools\texconv -D file\TrainRoomTRIII.png
tools\texconv -A file\PoolTRIII.png

tools\texconv -A file\FranFFXII.png
tools\texconv -A file\BunnyFFXII.png
tools\texconv -A file\MateusFFXII.png
tools\texconv -D file\VieraSceneFFXII.png

tools\texconv -D file\LuluFFX.png

tools\texconv -D file\TonberryFFVIII.png
tools\texconv -D file\UltimeciaFFVIII.png

tools\texconv -D file\MidnaZelda.png
tools\texconv -D file\NabooruZelda.png

spasm -I lib/ file\CavesOfKaliyaTRIII.inc bin\KALIYA2.8xv -E -S
spasm -I lib/ file\CityTRIII.inc bin\CITY2.8xv -E -S
spasm -I lib/ file\TrainRoomTRIII.inc bin\TRAIN2.8xv -E -S
spasm -I lib/ file\PoolTRIII.inc bin\POOL2.8xv -E -S

spasm -I lib/ file\FranFFXII.inc bin\FRAN2.8xv -E -S
spasm -I lib/ file\BunnyFFXII.inc bin\FLUFFY2.8xv -E -S
spasm -I lib/ file\MateusFFXII.inc bin\MATEUS2.8xv -E -S
spasm -I lib/ file\VieraSceneFFXII.inc bin\VIERA2.8xv -E -S

spasm -I lib/ file\LuluFFX.inc bin\LULU2.8xv -E -S

spasm -I lib/ file\TonberryFFVIII.inc bin\TONB2.8xv -E -S
spasm -I lib/ file\UltimeciaFFVIII.inc bin\ULTIM2.8xv -E -S

spasm -I lib/ file\MidnaZelda.inc bin\MIDNA2.8xv -E -S
spasm -I lib/ file\NabooruZelda.inc bin\NABOORU2.8xv -E -S

pause