@echo off
color 0F
:Loop

echo Converting Tomb Raider III test models...
tools\mdlconv  file\CavesOfKaliyaTRIII.obj -T -N -S -B
spasm -I lib/ file\CavesOfKaliyaTRIII0.inc bin\KALIYA0.8xv -E -S
spasm -I lib/ file\CavesOfKaliyaTRIII1.inc bin\KALIYA1.8xv -E -S

tools\mdlconv file\CityTRIII.obj -T -N -S -B
spasm -I lib/ file\CityTRIII0.inc bin\CITY0.8xv -E -S
spasm -I lib/ file\CityTRIII1.inc bin\CITY1.8xv -E -S

tools\mdlconv  file\TrainRoomTRIII.obj -T -N -S -B
spasm -I lib/ file\TrainRoomTRIII0.inc bin\TRAIN0.8xv -E -S
spasm -I lib/ file\TrainRoomTRIII1.inc bin\TRAIN1.8xv -E -S

tools\mdlconv  file\PoolTRIII.obj -T -N -S -B
spasm -I lib/ file\PoolTRIII0.inc bin\POOL0.8xv -E -S
spasm -I lib/ file\PoolTRIII1.inc bin\POOL1.8xv -E -S

echo Converting Suzanne...

tools\mdlconv  file\Suzanne.obj -C -N -S -B
spasm -I lib/ file\Suzanne0.inc bin\SUZAN0.8xv -E -S
spasm -I lib/ file\Suzanne1.inc bin\SUZAN1.8xv -E -S

echo Converting FFXII test models...

tools\mdlconv  file\MateusFFXII.obj -T -N -S -B
spasm -I lib/ file\MateusFFXII0.inc bin\MATEUS0.8xv -E -S
spasm -I lib/ file\MateusFFXII1.inc bin\MATEUS1.8xv -E -S

tools\mdlconv  file\BunnyFFXII.obj -T -N -S -B
spasm -I lib/ file\BunnyFFXII0.inc bin\FLUFFY0.8xv -E -S
spasm -I lib/ file\BunnyFFXII1.inc bin\FLUFFY1.8xv -E -S

tools\mdlconv  file\FranFFXII.obj -T -N -S -B
spasm -I lib/ file\FranFFXII0.inc bin\FRAN0.8xv -E -S
spasm -I lib/ file\FranFFXII1.inc bin\FRAN1.8xv -E -S

tools\mdlconv  file\VieraSceneFFXII.obj -T -N -S -B
spasm -I lib/ file\VieraSceneFFXII0.inc bin\VIERA0.8xv -E -S
spasm -I lib/ file\VieraSceneFFXII1.inc bin\VIERA1.8xv -E -S

echo Converting FFX test models...

tools\mdlconv  file\LuluFFX.obj -T -N -S -B
spasm -I lib/ file\LuluFFX0.inc bin\LULU0.8xv -E -S
spasm -I lib/ file\LuluFFX1.inc bin\LULU1.8xv -E -S

echo Converting FFVIII test models...

echo Converting TonberryFFVIII.obj...
tools\mdlconv  file\TonberryFFVIII.obj -T -N -S -B
spasm -I lib/ file\TonberryFFVIII0.inc bin\TONB0.8xv -E -S
spasm -I lib/ file\TonberryFFVIII1.inc bin\TONB1.8xv -E -S

tools\mdlconv  file\UltimeciaFFVIII.obj -T -N -S -B
spasm -I lib/ file\UltimeciaFFVIII0.inc bin\ULTIM0.8xv -E -S
spasm -I lib/ file\UltimeciaFFVIII1.inc bin\ULTIM1.8xv -E -S

echo Converting Zelda test models...

echo Converting MidnaZelda.obj
tools\mdlconv  file\MidnaZelda.obj -T -N -S -B
spasm -I lib/ file\MidnaZelda0.inc bin\MIDNA0.8xv -E -S
spasm -I lib/ file\MidnaZelda1.inc bin\MIDNA1.8xv -E -S

echo Converting NabooruZelda.obj
tools\mdlconv  file\NabooruZelda.obj -T -N -S -B
spasm -I lib/ file\NabooruZelda0.inc bin\NABOORU0.8xv -E -S
spasm -I lib/ file\NabooruZelda1.inc bin\NABOORU1.8xv -E -S

pause