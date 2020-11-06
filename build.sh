mkdir bin
echo "-----------------------------------"
echo "Building example.ez80..."
spasm -L -T -E -A -S -I include/ -I lib/ example.ez80 bin/TEST.8xp
echo "-----------------------------------"
echo "Building example1.ez80..."
spasm -L -T -E -A -S -I include/ -I lib/ example1.ez80 bin/TEST1.8xp
echo "-----------------------------------"
echo "Building example2.ez80..."
spasm -L -T -E -A -S -I include/ -I lib/ example2.ez80 bin/TEST2.8xp
echo "-----------------------------------"
echo "Building lvl.ez80..."
spasm -L -T -E -A -S -I include/ -I lib/ lvl.ez80 bin/TESTLVL.8xp
