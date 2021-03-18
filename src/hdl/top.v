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
    (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 IIC SCL_I" *)
    input wire i2c_scl_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 IIC SCL_O" *)
    output wire i2c_scl_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 IIC SCL_T" *)
    output wire i2c_scl_t,
    (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 IIC SDA_I" *)
    input wire i2c_sda_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 IIC SDA_O" *)
    output wire i2c_sda_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 IIC SDA_T" *)
    output wire i2c_sda_t,


    // lrclk = fs = 48kHz
    output wire i2s_lrclk,
    // 24 bit data, stereo
    // bclk = 24*2*fs = 2.304MHz
    output wire i2s_dacdat,
    input wire i2s_adcdat,
    output wire i2s_bclk
    );

    assign speaker_mute = 1'b0;
    // 12.288MHz
    assign mclk = clk;

    // echo
    assign uart_tx = uart_rx;

    reg [7:0] i2c_counter;
    reg i2c_scl_reg;
    always @(posedge clk) begin
        if (rst) begin
            i2c_counter <= 8'b0;
            i2c_scl_reg <= 1'b0;
        end else begin
            if (i2c_counter == 8'd31) begin
                i2c_scl_reg <= ~i2c_scl_reg;
                i2c_counter <= 8'b0;
            end else begin
                i2c_counter <= i2c_counter + 8'b1;
            end
        end
    end

    assign i2c_scl_o = i2c_scl_reg;
    assign i2c_scl_t = 1'b0;
    assign i2c_sda_o = 1'b1;
    assign i2c_sda_t = 1'b1;

    assign i2s_lrclk = clk;
    assign i2s_dacdat = 1'b0;
    assign i2s_bclk = clk;
endmodule

