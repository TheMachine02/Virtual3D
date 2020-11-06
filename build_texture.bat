@echo off
color 0F
echo Converting...

tools\texconv -D file\CavesOfKaliyaTRIII.png
tools\texconv -D file\CityTRIII.png
tools\texconv -D file\TrainRoomTRIII.png
tools\texconv -A file\PoolTRIII.png
tools\texconv -D file\LaraTRIII.png
tools\texconv -D file\texture.png

tools\texconv -A file\FranFFXII.png
tools\texconv -A file\MjrnFFXII.png
tools\texconv -A file\BunnyFFXII.png
tools\texconv -A file\MateusFFXII.png
tools\texconv -D file\VieraSceneFFXII.png

tools\texconv -D file\LuluFFX.png

tools\texconv -D file\TonberryFFVIII.png
tools\texconv -D file\UltimeciaFFVIII.png

tools\texconv -D file\MidnaZelda.png
tools\texconv -D file\NabooruZelda.png

spasm -I lib/ file\CavesOfKaliyaTRIII.inc bin\KALIYAT.8xv -E -S
spasm -I lib/ file\CityTRIII.inc bin\CITYT.8xv -E -S
spasm -I lib/ file\TrainRoomTRIII.inc bin\TRAINT.8xv -E -S
spasm -I lib/ file\PoolTRIII.inc bin\POOLT.8xv -E -S
spasm -I lib/ file\LaraTRIII.inc bin\LARAT.8xv -E -S
spasm -I lib/ file\texture.inc bin\GYMT.8xv -E -S

spasm -I lib/ file\FranFFXII.inc bin\FRANT.8xv -E -S
spasm -I lib/ file\MjrnFFXII.inc bin\MJRNT.8xv -E -S
spasm -I lib/ file\BunnyFFXII.inc bin\FLUFFYT.8xv -E -S
spasm -I lib/ file\MateusFFXII.inc bin\MATEUST.8xv -E -S
spasm -I lib/ file\VieraSceneFFXII.inc bin\VIERAT.8xv -E -S

spasm -I lib/ file\LuluFFX.inc bin\LULUT.8xv -E -S

spasm -I lib/ file\TonberryFFVIII.inc bin\TONBT.8xv -E -S
spasm -I lib/ file\UltimeciaFFVIII.inc bin\ULTIMT.8xv -E -S

spasm -I lib/ file\MidnaZelda.inc bin\MIDNAT.8xv -E -S
spasm -I lib/ file\NabooruZelda.inc bin\NABOORUT.8xv -E -S

pause
