#!/bin/bash
# convert to pcm
ffmpeg -y -i "Ludwig van Beethoven - symphony no. 5 in c minor, op. 67 - i. allegro con brio.ogg" -acodec pcm_s32be -f s32be -ac 1 -t 2.5 -ar 12000 music.pcm
# dump coe
echo 'memory_initialization_radix = 16;' > music.coe
echo 'memory_initialization_vector = ' >> music.coe
xxd -p music.pcm | tr -d '\n' | fold -w8 >> music.coe
# upsampling by 4
python3 repeat.py
# convert back for verification
sox -t raw -c 1 -e signed-integer -b 32 --endian big -r 12000 music.pcm music.wav
sox -t raw -c 1 -e signed-integer -b 32 --endian big -r 48000 music4.pcm music4.wav