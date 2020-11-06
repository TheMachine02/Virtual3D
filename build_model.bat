@echo off
color 0F
:Loop

echo Converting Tomb Raider III test models...
tools\mdlconv  file\CavesOfKaliyaTRIII.obj -T -N -S -B
spasm -I lib/ file\CavesOfKaliyaTRIII0.inc bin\KALIYAV.8xv -E -S
spasm -I lib/ file\CavesOfKaliyaTRIII1.inc bin\KALIYAF.8xv -E -S

tools\mdlconv file\CityTRIII.obj -T -N -S -B
spasm -I lib/ file\CityTRIII0.inc bin\CITYV.8xv -E -S
spasm -I lib/ file\CityTRIII1.inc bin\CITYF.8xv -E -S

tools\mdlconv  file\TrainRoomTRIII.obj -T -N -S -B
spasm -I lib/ file\TrainRoomTRIII0.inc bin\TRAINV.8xv -E -S
spasm -I lib/ file\TrainRoomTRIII1.inc bin\TRAINF.8xv -E -S

tools\mdlconv  file\PoolTRIII.obj -T -N -S -B
spasm -I lib/ file\PoolTRIII0.inc bin\POOLV.8xv -E -S
spasm -I lib/ file\PoolTRIII1.inc bin\POOLF.8xv -E -S

tools\mdlconv  file\room_commune.obj -T -N -S -B
spasm -I lib/ file\room_commune0.inc bin\GYMV.8xv -E -S
spasm -I lib/ file\room_commune1.inc bin\GYMF.8xv -E -S

spasm -I lib/ file\XML0.ez80 bin\LARAV.8xv -E -S
spasm -I lib/ file\XML1.ez80 bin\LARAF.8xv -E -S

echo Converting Suzanne...

tools\mdlconv  file\Suzanne.obj -C -N -S -B
spasm -I lib/ file\Suzanne0.inc bin\SUZANV.8xv -E -S
spasm -I lib/ file\Suzanne1.inc bin\SUZANF.8xv -E -S

echo Converting FFXII test models...

tools\mdlconv  file\MateusFFXII.obj -T -N -S -B
spasm -I lib/ file\MateusFFXII0.inc bin\MATEUSV.8xv -E -S
spasm -I lib/ file\MateusFFXII1.inc bin\MATEUSF.8xv -E -S

tools\mdlconv  file\BunnyFFXII.obj -T -N -S -B
spasm -I lib/ file\BunnyFFXII0.inc bin\FLUFFYV.8xv -E -S
spasm -I lib/ file\BunnyFFXII1.inc bin\FLUFFYF.8xv -E -S

tools\mdlconv  file\FranFFXII.obj -T -N -S -B
spasm -I lib/ file\FranFFXII0.inc bin\FRANV.8xv -E -S
spasm -I lib/ file\FranFFXII1.inc bin\FRANF.8xv -E -S

tools\mdlconv  file\MjrnFFXII.obj -T -N -S -B
spasm -I lib/ file\MjrnFFXII0.inc bin\MJRNV.8xv -E -S
spasm -I lib/ file\MjrnFFXII1.inc bin\MJRNF.8xv -E -S

tools\mdlconv  file\FranFFXII_LOD1.obj -T -N -S -B
spasm -I lib/ file\FranFFXII_LOD10.inc bin\FRANLV.8xv -E -S
spasm -I lib/ file\FranFFXII_LOD11.inc bin\FRANLF.8xv -E -S

tools\mdlconv  file\VieraSceneFFXII.obj -T -N -S -B
spasm -I lib/ file\VieraSceneFFXII0.inc bin\VIERAV.8xv -E -S
spasm -I lib/ file\VieraSceneFFXII1.inc bin\VIERAF.8xv -E -S

echo Converting FFX test models...

tools\mdlconv  file\LuluFFX.obj -T -N -S -B
spasm -I lib/ file\LuluFFX0.inc bin\LULUV.8xv -E -S
spasm -I lib/ file\LuluFFX1.inc bin\LULUF.8xv -E -S

echo Converting FFVIII test models...

echo Converting TonberryFFVIII.obj...
tools\mdlconv  file\TonberryFFVIII.obj -T -N -S -B
spasm -I lib/ file\TonberryFFVIII0.inc bin\TONBV.8xv -E -S
spasm -I lib/ file\TonberryFFVIII1.inc bin\TONBF.8xv -E -S

tools\mdlconv  file\UltimeciaFFVIII.obj -T -N -S -B
spasm -I lib/ file\UltimeciaFFVIII0.inc bin\ULTIMV.8xv -E -S
spasm -I lib/ file\UltimeciaFFVIII1.inc bin\ULTIMF.8xv -E -S

echo Converting Zelda test models...

echo Converting MidnaZelda.obj
tools\mdlconv  file\MidnaZelda.obj -T -N -S -B
spasm -I lib/ file\MidnaZelda0.inc bin\MIDNAV.8xv -E -S
spasm -I lib/ file\MidnaZelda1.inc bin\MIDNAF.8xv -E -S

echo Converting NabooruZelda.obj
tools\mdlconv  file\NabooruZelda.obj -T -N -S -B
spasm -I lib/ file\NabooruZelda0.inc bin\NABOORUV.8xv -E -S
spasm -I lib/ file\NabooruZelda1.inc bin\NABOORUF.8xv -E -S

pause
