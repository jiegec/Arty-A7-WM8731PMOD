`timescale 1ns / 1ps
module top(
	// sample rate fs = 48kHz
	// clk = 256*fs = 12.288MHz
	input wire clk,
	input wire rst,

	// uart
	input wire uart_rx,
	output wire uart_tx,

	output wire speaker_mute,
	// mclk = clk = 12.288MHz
	output wire mclk,

	// i2c_clk = 384kHz = clk/32
	output wire i2c_scl,
	output wire i2c_sda,

	// lrclk = fs = 48kHz
	output wire i2s_lrclk,
	// 24 bit data, stereo
	// bclk = 24*2*fs = 2.304MHz
	output wire i2s_dacdat,
	input wire i2s_adcdat,
	output wire i2s_bclk
    );

    assign speaker_mute = 1'b0;
    assign mclk = clk;
    assign i2c_scl = 1'b0;
    assign i2c_sda = 1'b0;
    assign i2s_lrclk = clk;
    assign i2s_dacdat = 1'b0;
    assign i2s_bclk = clk;
endmodule

