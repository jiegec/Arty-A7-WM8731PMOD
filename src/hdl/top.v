`timescale 1ns / 1ps
module top(
    // sample rate fs = 48kHz
    // clk = 6*256*fs = 73.728MHz
    input wire clk,
    input wire rstn,

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

    wire rst;
    assign rst = ~rstn;

    assign speaker_mute = 1'b0;

    // 12.288MHz
    reg [7:0] mclk_counter;
    reg mclk_reg;

    initial begin
        mclk_reg = 8'b0;
    end
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

    // I2C registers to write
    // 8 bit i2c address + 7 bit reg addres + 9 bit data
    localparam NUM_I2C_ASSIGNMENTS = 5;
    reg [8+16-1:0] i2c_assignments [0:NUM_I2C_ASSIGNMENTS-1];
    localparam I2C_ADDRESS = 8'b00110100;
    initial begin
        // Reset device
        i2c_assignments[0] = {I2C_ADDRESS, 7'b0001111, 9'b00000000};
        // Power on everything
        i2c_assignments[1] = {I2C_ADDRESS, 7'b0000110, 9'b00000000};
        // Activate interface
        i2c_assignments[2] = {I2C_ADDRESS, 7'b0001001, 9'b00000001};
        // Input from mic
        i2c_assignments[3] = {I2C_ADDRESS, 7'b0000100, 9'b00001000};
        // Disable mute for left and right with default volume
        i2c_assignments[4] = {I2C_ADDRESS, 7'b0000001, 9'b110010111};
    end

    reg [7:0] i2c_assignment_index;
    // bit index in assignment(23 downto 0)
    reg [7:0] i2c_bit_index;

    reg [7:0] i2c_scl_counter;
    reg i2c_scl_reg;
    reg i2c_sda_reg;
    reg i2c_sda_t_reg;
    localparam I2C_STATE_RESET = 4'd0;
    localparam I2C_STATE_START1 = 4'd1;
    localparam I2C_STATE_WRITE = 4'd2;
    localparam I2C_STATE_READ_ACK = 4'd3;
    localparam I2C_STATE_STOP1 = 4'd4;
    localparam I2C_STATE_STOP2 = 4'd5;
    reg [3:0] i2c_state;
    reg [3:0] i2c_prev_state;
    reg [3:0] i2c_stop_counter;

    initial begin
        i2c_scl_counter = 8'b0;
        i2c_scl_reg = 1'b1;
        i2c_sda_reg = 1'b1;
        i2c_sda_t_reg = 1'b0;
        i2c_state = I2C_STATE_RESET;
        i2c_prev_state = I2C_STATE_RESET;
    end
    always @(posedge clk) begin
        if (rst) begin
            i2c_scl_counter <= 8'b0;
            i2c_scl_reg <= 1'b1;
            i2c_sda_reg <= 1'b1;
            i2c_sda_t_reg <= 1'b0;
            i2c_state <= I2C_STATE_RESET;
            i2c_prev_state <= I2C_STATE_RESET;
            i2c_assignment_index <= 8'b0;
        end else begin
            // divide by 192
            if (i2c_scl_counter == 8'd95) begin
                i2c_scl_counter <= 8'b0;

                case (i2c_state)
                    I2C_STATE_RESET: begin
                        i2c_sda_reg <= 1'b0;
                        i2c_state <= I2C_STATE_START1;
                    end
                    I2C_STATE_START1: begin
                        i2c_scl_reg <= 1'b0;
                        i2c_state <= I2C_STATE_WRITE;
                        i2c_bit_index <= 8'd23;
                    end
                    I2C_STATE_WRITE: begin
                        if (i2c_scl_reg == 1'b0) begin
                            // scl rise
                            i2c_sda_t_reg <= 1'b0;
                            if (i2c_prev_state == I2C_STATE_WRITE && (i2c_bit_index == 8'd15 || i2c_bit_index == 8'd7 || i2c_bit_index == 8'hff)) begin
                                // 8 bits sent
                                i2c_state <= I2C_STATE_READ_ACK;
                                i2c_sda_t_reg <= 1'b1;
                                i2c_sda_reg <= 1'b0;
                            end else begin
                                i2c_sda_reg <= i2c_assignments[i2c_assignment_index][i2c_bit_index];
                                i2c_bit_index <= i2c_bit_index - 8'b1;
                            end
                        end
                        i2c_scl_reg <= ~i2c_scl_reg;
                    end
                    I2C_STATE_READ_ACK: begin
                        if (i2c_scl_reg == 1'b0) begin
                            // scl rise
                            if (i2c_bit_index == 8'hff) begin
                                // last bit
                                i2c_state <= I2C_STATE_STOP1;
                                i2c_sda_t_reg <= 1'b0;
                            end else begin
                                // continue to next 8 bits
                                i2c_state <= I2C_STATE_WRITE;
                                i2c_sda_t_reg <= 1'b0;
                                i2c_sda_reg <= i2c_assignments[i2c_assignment_index][i2c_bit_index];
                                i2c_bit_index <= i2c_bit_index - 8'b1;
                            end
                        end else begin
                            // scl fall
                        end
                        i2c_scl_reg <= ~i2c_scl_reg;
                    end
                    I2C_STATE_STOP1: begin
                        i2c_scl_reg <= 1'b1;
                        i2c_state <= I2C_STATE_STOP2;
                        i2c_stop_counter <= 4'b0;
                    end
                    I2C_STATE_STOP2: begin
                        i2c_sda_reg <= 1'b1;
                        if (i2c_stop_counter == 4'hf) begin
                            // scl rise
                            if (i2c_assignment_index != NUM_I2C_ASSIGNMENTS - 1) begin
                                // next assignment
                                i2c_assignment_index <= i2c_assignment_index + 8'b1;
                                i2c_state <= I2C_STATE_RESET;
                            end
                        end else begin
                            i2c_stop_counter <= i2c_stop_counter + 4'b1;
                        end
                    end
                    default: begin
                        
                    end
                endcase

                if (i2c_scl_reg == 1'b0) begin
                    // scl rise
                    i2c_prev_state <= i2c_state;
                end
            end else begin
                i2c_scl_counter <= i2c_scl_counter + 8'b1;
            end
        end
    end
    assign i2c_scl_o = i2c_scl_reg;
    assign i2c_scl_t = 1'b0;

    assign i2c_sda_o = i2c_sda_reg;
    assign i2c_sda_t = i2c_sda_t_reg;

    reg [15:0] i2s_lrclk_counter;
    reg i2s_lrclk_reg;

    initial begin
        i2s_lrclk_counter = 16'b0;
    end
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

    initial begin
        i2s_bclk_counter = 8'b0;
    end
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

