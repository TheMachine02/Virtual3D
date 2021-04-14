@echo off
@cls
color 0F
mkdir bin

:Loop

echo building library ram image...
fasmg lib/bss.asm lib/bss
lz4.exe -f -l --best lib/bss lib/ram
del lib/bss

echo "building example..."
fasmg example/example.asm bin/V3DALPHA.8xp

echo "building example 1..."
fasmg example/example1.asm bin/V3DFLAT.8xp

echo "building example 2..."
fasmg example/modelviewer.asm bin/V3DVIEW.8xp

echo "building level example..."
fasmg example/lvl.asm bin/LVL.8xp

echo "building animation example..."
fasmg example/animation.asm bin/ANIMATE.8xp

pause
goto Loop
