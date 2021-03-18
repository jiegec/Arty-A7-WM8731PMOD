`timescale 1ns / 1ps
module top(
	input wire clk,
	input wire rst,

	output wire speaker_mute,
	output wire mclk,

	output wire i2c_scl,
	output wire i2c_sda,

	output wire i2s_lrclk,
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

