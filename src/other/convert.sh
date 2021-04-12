#!/bin/bash
ffmpeg -y -i "Ludwig van Beethoven - symphony no. 5 in c minor, op. 67 - i. allegro con brio.ogg" -acodec pcm_s32be -f s32be -ac 1 -t 2.5 -ar 12000 music.pcm
echo 'memory_initialization_radix = 16;' > music.coe
echo 'memory_initialization_vector = ' >> music.coe
xxd -p music.pcm | tr -d '\n' | fold -w8 >> music.coe