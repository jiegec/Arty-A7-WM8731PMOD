`timescale 1ns / 1ps
module top(
    // sample rate fs = 48kHz
    // clk = 6*256*fs = 73.728MHz
    input wire clk,
    input wire rst,

    // uart
    input wire uart_rx,
    output wire uart_tx,

    output wire speaker_mute,
    // mclk = 256*fs = 12.288MHz = clk/6
    output wire mclk,

    // i2c_clk = 384kHz = clk/192
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


    // lrclk = fs = 48kHz = clk/1536
    output wire i2s_lrclk,
    // 24 bit data, stereo
    // bclk = 24*2*fs = 2.304MHz = clk/32
    output wire i2s_dacdat,
    input wire i2s_adcdat,
    output wire i2s_bclk
    );

    assign speaker_mute = 1'b0;

    // 12.288MHz
    reg [7:0] mclk_counter;
    reg mclk_reg;
    always @(posedge clk) begin
        if (rst) begin
            mclk_counter <= 8'b0;
            mclk_reg <= 1'b0;
        end else begin
            // divide by 6
            if (mclk_counter == 8'd2) begin
                mclk_reg <= ~mclk_reg;
                mclk_counter <= 8'b0;
            end else begin
                mclk_counter <= mclk_counter + 8'b1;
            end
        end
    end
    assign mclk = mclk_reg;

    // echo
    assign uart_tx = uart_rx;

    reg [7:0] i2c_scl_counter;
    reg i2c_scl_reg;
    always @(posedge clk) begin
        if (rst) begin
            i2c_scl_counter <= 8'b0;
            i2c_scl_reg <= 1'b0;
        end else begin
            // divide by 192
            if (i2c_scl_counter == 8'd95) begin
                i2c_scl_reg <= ~i2c_scl_reg;
                i2c_scl_counter <= 8'b0;
            end else begin
                i2c_scl_counter <= i2c_scl_counter + 8'b1;
            end
        end
    end
    assign i2c_scl_o = i2c_scl_reg;
    assign i2c_scl_t = 1'b0;

    assign i2c_sda_o = 1'b1;
    assign i2c_sda_t = 1'b1;

    reg [15:0] i2s_lrclk_counter;
    reg i2s_lrclk_reg;
    always @(posedge clk) begin
        if (rst) begin
            i2s_lrclk_counter <= 16'b0;
            i2s_lrclk_reg <= 1'b0;
        end else begin
            // divide by 1536
            if (i2s_lrclk_counter == 16'd767) begin
                i2s_lrclk_reg <= ~i2s_lrclk_reg;
                i2s_lrclk_counter <= 16'b0;
            end else begin
                i2s_lrclk_counter <= i2s_lrclk_counter + 16'b1;
            end
        end
    end
    assign i2s_lrclk = i2s_lrclk_reg;

    assign i2s_dacdat = 1'b0;

    reg [7:0] i2s_bclk_counter;
    reg i2s_bclk_reg;
    always @(posedge clk) begin
        if (rst) begin
            i2s_bclk_counter <= 16'b0;
            i2s_bclk_reg <= 1'b0;
        end else begin
            // divide by 32
            if (i2s_bclk_counter == 8'd15) begin
                i2s_bclk_reg <= ~i2s_bclk_reg;
                i2s_bclk_counter <= 8'b0;
            end else begin
                i2s_bclk_counter <= i2s_bclk_counter + 8'b1;
            end
        end
    end
    assign i2s_bclk = i2s_bclk_reg;
endmodule

