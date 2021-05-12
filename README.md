# Arty-A7-WM8731PMOD

Sound is downloaded from [Wikimedia](https://commons.wikimedia.org/wiki/File:Ludwig_van_Beethoven_-_symphony_no._5_in_c_minor,_op._67_-_i._allegro_con_brio.ogg), which is public domain.

The design plays the first 2.5s of Beethovn Symphony No. 5 in C Minor Op. 67 repeatedly. Verified on WM8731PMOD 2021-03-09.

## Design

Main logic is in `src/hdl/top.v`. It contains logic for:

1. Generate clocks: LRCLK, MCLK, BCLK, I2C_SCL etc
2. Configure registers via i2c bus
3. Read pcm data from block ram
4. Output audio via i2s interface