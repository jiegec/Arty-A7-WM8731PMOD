`timescale 1ns / 1ps
module top_tb ();

    reg clk;
    reg rst;

    wire i2c_scl_i;
    wire i2c_scl_o;
    wire i2c_scl_t;

    wire i2c_scl = i2c_scl_t ? 1'bz : i2c_scl_o;

    wire i2c_sda_i;
    wire i2c_sda_o;
    wire i2c_sda_t;

    wire i2c_sda = i2c_sda_t ? 1'bz : i2c_sda_o;

    initial begin
	$dumpfile("dump.vcd");
	$dumpvars(0, top_tb);
        rst = 1'b1;
        repeat (10) @ (posedge clk);
        rst = 1'b0;

	#1000000;
	$finish;
    end

    initial begin
        clk = 1'b0;
    end

    always clk = #5 ~clk;

    top dut(
        .clk(clk),
        .rstn(~rst),

	.i2c_scl_i(i2c_scl_i),
	.i2c_scl_o(i2c_scl_o),
	.i2c_scl_t(i2c_scl_t),

	.i2c_sda_i(i2c_sda_i),
	.i2c_sda_o(i2c_sda_o),
	.i2c_sda_t(i2c_sda_t)
    );
endmodule
