#!/bin/bash
g++ -o import import-src/main.cpp -fexceptions -fpie -fstack-clash-protection -Wall -Wextra -O2 -pipe -D_FORTIFY_SOURCE=2
g++ -o texconv texconv-src/main.cpp -fexceptions -fpie -fstack-clash-protection -Wall -Wextra -O2 -pipe -D_FORTIFY_SOURCE=2
# g++ -o xmlconv xmlconv-src/main.cpp -fexceptions -fpie -fstack-clash-protection -Wall -O2 -pipe -D_FORTIFY_SOURCE=2
g++ -o lut lut.cpp -fexceptions -fpie -fstack-clash-protection -Wall -Wextra -O2 -pipe -D_FORTIFY_SOURCE=2
