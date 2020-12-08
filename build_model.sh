mkdir bin

echo "Converting Tomb Raider III test models..."
./tools/mdlconv  file/CavesOfKaliyaTRIII.obj -T -N -S -B -X

spasm -I lib/ file/CavesOfKaliyaTRIII0.inc bin/KALIYAV.8xv -E -S
spasm -I lib/ file/CavesOfKaliyaTRIII1.inc bin/KALIYAF.8xv -E -S

./tools/mdlconv file/CityTRIII.obj -T -N -S -B
spasm -I lib/ file/CityTRIII0.inc bin/CITYV.8xv -E -S
spasm -I lib/ file/CityTRIII1.inc bin/CITYF.8xv -E -S

./tools/mdlconv  file/TrainRoomTRIII.obj -T -N -S -B
spasm -I lib/ file/TrainRoomTRIII0.inc bin/TRAINV.8xv -E -S
spasm -I lib/ file/TrainRoomTRIII1.inc bin/TRAINF.8xv -E -S

./tools/mdlconv  file/PoolTRIII.obj -T -N -S -B -X
spasm -I lib/ file/PoolTRIII0.inc bin/POOLV.8xv -E -S
spasm -I lib/ file/PoolTRIII1.inc bin/POOLF.8xv -E -S

./tools/mdlconv  file/room_commune.obj -T -N -S -B
spasm -I lib/ file/room_commune0.inc bin/ROOMV.8xv -E -S
spasm -I lib/ file/room_commune1.inc bin/ROOMF.8xv -E -S

spasm -I lib/ file/XML0.ez80 bin/LARAV.8xv -E -S
spasm -I lib/ file/XML1.ez80 bin/LARAF.8xv -E -S

echo "Converting Suzanne..."

./tools/mdlconv  file/Suzanne.obj -C -N -S -B
spasm -I lib/ file/Suzanne0.inc bin/SUZANV.8xv -E -S
spasm -I lib/ file/Suzanne1.inc bin/SUZANF.8xv -E -S

echo "Converting FFXII test models..."

./tools/mdlconv  file/MateusFFXII.obj -T -N -S -B
spasm -I lib/ file/MateusFFXII0.inc bin/MATEUSV.8xv -E -S
spasm -I lib/ file/MateusFFXII1.inc bin/MATEUSF.8xv -E -S

./tools/mdlconv  file/BunnyFFXII.obj -T -N -S -B
spasm -I lib/ file/BunnyFFXII0.inc bin/FLUFFYV.8xv -E -S
spasm -I lib/ file/BunnyFFXII1.inc bin/FLUFFYF.8xv -E -S

./tools/mdlconv  file/FranFFXII.obj -T -N -S -B
spasm -I lib/ file/FranFFXII0.inc bin/FRANV.8xv -E -S
spasm -I lib/ file/FranFFXII1.inc bin/FRANF.8xv -E -S

./tools/mdlconv  file/MjrnFFXII.obj -T -N -S -B
spasm -I lib/ file/MjrnFFXII0.inc bin/MJRNV.8xv -E -S
spasm -I lib/ file/MjrnFFXII1.inc bin/MJRNF.8xv -E -S

./tools/mdlconv  file/FranFFXII_LOD1.obj -T -N -S -B
spasm -I lib/ file/FranFFXII_LOD10.inc bin/FRANLV.8xv -E -S
spasm -I lib/ file/FranFFXII_LOD11.inc bin/FRANLF.8xv -E -S

./tools/mdlconv  file/VieraSceneFFXII.obj -T -N -S -B
spasm -I lib/ file/VieraSceneFFXII0.inc bin/VIERAV.8xv -E -S
spasm -I lib/ file/VieraSceneFFXII1.inc bin/VIERAF.8xv -E -S

./tools/mdlconv  file/BomboFFXII.obj -T -N -S -B
spasm -I lib/ file/BomboFFXII0.inc bin/BOMBOV.8xv -E -S
spasm -I lib/ file/BomboFFXII1.inc bin/BOMBOF.8xv -E -S

./tools/mdlconv  file/UltimaFFXII.obj -T -N -S -B
spasm -I lib/ file/UltimaFFXII0.inc bin/ULTIMAV.8xv -E -S
spasm -I lib/ file/UltimaFFXII1.inc bin/ULTIMAF.8xv -E -S

echo "Converting FFX test models..."

./tools/mdlconv  file/LuluFFX.obj -T -N -S -B
spasm -I lib/ file/LuluFFX0.inc bin/LULUV.8xv -E -S
spasm -I lib/ file/LuluFFX1.inc bin/LULUF.8xv -E -S

echo "Converting FFVIII test models..."

echo "Converting TonberryFFVIII.obj..."
./tools/mdlconv  file/TonberryFFVIII.obj -T -N -S -B
spasm -I lib/ file/TonberryFFVIII0.inc bin/TONBV.8xv -E -S
spasm -I lib/ file/TonberryFFVIII1.inc bin/TONBF.8xv -E -S

./tools/mdlconv  file/UltimeciaFFVIII.obj -T -N -S -B
spasm -I lib/ file/UltimeciaFFVIII0.inc bin/ULTIMV.8xv -E -S
spasm -I lib/ file/UltimeciaFFVIII1.inc bin/ULTIMF.8xv -E -S

echo "Converting Zelda test models..."

echo "Converting MidnaZelda.obj"
./tools/mdlconv  file/MidnaZelda.obj -T -N -S -B
spasm -I lib/ file/MidnaZelda0.inc bin/MIDNAV.8xv -E -S
spasm -I lib/ file/MidnaZelda1.inc bin/MIDNAF.8xv -E -S

echo "Converting NabooruZelda.obj"
./tools/mdlconv  file/NabooruZelda.obj -T -N -S -B
spasm -I lib/ file/NabooruZelda0.inc bin/NABOORUV.8xv -E -S
spasm -I lib/ file/NabooruZelda1.inc bin/NABOORUF.8xv -E -S

echo "Converting CavesOfKaliyaTRIII.png"
./tools/texconv -dithering -compress file/CavesOfKaliyaTRIII.png
echo "Converting CityTRIII.png"
./tools/texconv -dithering -compress file/CityTRIII.png
echo "Converting TrainRoomTRIII.png"
./tools/texconv -dithering -compress file/TrainRoomTRIII.png
echo "Converting PoolTRIII.png"
./tools/texconv -alpha -dithering -compress file/PoolTRIII.png
echo "Converting LaraTRIII.png"
./tools/texconv -alpha -dithering -compress file/LaraTRIII.png
echo "Converting texture.png"
./tools/texconv -dithering -compress file/texture.png
echo "Converting FranFFXII.png"
./tools/texconv -alpha -compress file/FranFFXII.png
echo "Converting MjrnFFXII.png"
./tools/texconv -alpha -dithering -compress file/MjrnFFXII.png
echo "Converting BunnyFFXII.png"
./tools/texconv -alpha -dithering -compress file/BunnyFFXII.png
echo "Converting MateusFFXII.png"
./tools/texconv -dithering -compress file/MateusFFXII.png
echo "Converting VieraSceneFFXII.png"
./tools/texconv -dithering -compress file/VieraSceneFFXII.png
echo "Converting LuluFFX.png"
./tools/texconv -dithering -compress file/LuluFFX.png
echo "Converting TonberryFFVIII.png"
./tools/texconv -dithering -compress file/TonberryFFVIII.png
echo "Converting UltimeciaFFVIII.png"
./tools/texconv -dithering -compress file/UltimeciaFFVIII.png
echo "Converting MidnaZelda.png"
./tools/texconv -dithering -compress file/MidnaZelda.png
echo "Converting NabooruZelda.png"
./tools/texconv -dithering -compress file/NabooruZelda.png
echo "Converting Background.png"
./tools/texconv -dithering file/Background.png
echo "Converting BackgroundJungle.png"
./tools/texconv -dithering file/BackgroundJungle.png
echo "Converting BackgroundPacific.png"
./tools/texconv -dithering file/BackgroundPacific.png
echo "Converting BackgroundPacific.png"
./tools/texconv -dithering file/BackgroundNevada.png
echo "Converting BomboFFXII.png"
./tools/texconv -alpha -dithering -compress file/BomboFFXII.png
echo "Converting UltimaFFXII.png"
./tools/texconv -dithering -compress file/UltimaFFXII.png

spasm -I lib/ file/CavesOfKaliyaTRIII.inc bin/KALIYAT.8xv -E -S
spasm -I lib/ file/CityTRIII.inc bin/CITYT.8xv -E -S
spasm -I lib/ file/TrainRoomTRIII.inc bin/TRAINT.8xv -E -S
spasm -I lib/ file/PoolTRIII.inc bin/POOLT.8xv -E -S
spasm -I lib/ file/LaraTRIII.inc bin/LARAT.8xv -E -S
spasm -I lib/ file/texture.inc bin/ROOMT.8xv -E -S
spasm -I lib/ file/FranFFXII.inc bin/FRANT.8xv -E -S
spasm -I lib/ file/MjrnFFXII.inc bin/MJRNT.8xv -E -S
spasm -I lib/ file/BunnyFFXII.inc bin/FLUFFYT.8xv -E -S
spasm -I lib/ file/MateusFFXII.inc bin/MATEUST.8xv -E -S
spasm -I lib/ file/VieraSceneFFXII.inc bin/VIERAT.8xv -E -S
spasm -I lib/ file/LuluFFX.inc bin/LULUT.8xv -E -S
spasm -I lib/ file/TonberryFFVIII.inc bin/TONBT.8xv -E -S
spasm -I lib/ file/UltimeciaFFVIII.inc bin/ULTIMT.8xv -E -S
spasm -I lib/ file/MidnaZelda.inc bin/MIDNAT.8xv -E -S
spasm -I lib/ file/NabooruZelda.inc bin/NABOORUT.8xv -E -S
spasm -I lib/ file/Background.inc bin/SKYBOX0.8xv -E -S
spasm -I lib/ file/BackgroundJungle.inc bin/SKYBOX1.8xv -E -S
spasm -I lib/ file/BackgroundPacific.inc bin/SKYBOX2.8xv -E -S
spasm -I lib/ file/BackgroundNevada.inc bin/SKYBOX3.8xv -E -S
spasm -I lib/ file/BomboFFXII.inc bin/BOMBOT.8xv -E -S
spasm -I lib/ file/UltimaFFXII.inc bin/ULTIMAT.8xv -E -S
