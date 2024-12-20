#!/bin/bash
mkdir bin

echo "building library ram image..."
fasmg lib/bss.asm lib/bss
lz4 -f -l --best lib/bss lib/ram
rm lib/bss

echo "building example..."
#spasm -L -T -E -A -S -I include/ -I lib/ example/example.ez80 bin/TEST.8xp
fasmg example/example.asm bin/V3DALPHA.8xp

# echo "building example 1..."
# #spasm -L -T -E -A -S -I include/ -I lib/ example/example1.ez80 bin/TEST1.8xp
# fasmg example/example1.asm bin/V3DFLAT.8xp

echo "building example 2..."
fasmg example/modelviewer.asm bin/V3DVIEW.8xp
#spasm -L -T -E -A -S -I include/ -I lib/ example/example2.ez80 bin/TEST2.8xp

echo "building render..."
fasmg example/render.asm bin/RENDER.8xp
#spasm -L -T -E -A -S -I include/ -I lib/ example/example2.ez80 bin/TEST2.8xp

#echo "building level example..."
#spasm -L -T -E -A -S -I include/ -I lib/ example/lvl.ez80 bin/TESTLVL.8xp
#fasmg example/lvl.asm bin/LVL.8xp

#echo "building animation example..."
#spasm -L -T -E -A -S -I include/ -I lib/ example/lvl.ez80 bin/TESTLVL.8xp
#fasmg example/animation.asm bin/ANIMATE.8xp
