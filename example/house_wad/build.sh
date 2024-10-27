mkdir bin

./import  file/dataRoom0.obj -T -N -S -X -B
./import  file/dataRoom1.obj -T -N -S -X -B
./import  file/dataRoom2.obj -T -N -S -X -B
./import  file/dataRoom3.obj -T -N -S -X -B
./import  file/dataRoom4.obj -T -N -S -X -B
./import  file/dataRoom5.obj -T -N -S -X -B
./import  file/dataRoom6.obj -T -N -S -X -B

fasmg data0.inc bin/HOMEV.8xv
fasmg data1.inc bin/HOMEF.8xv
