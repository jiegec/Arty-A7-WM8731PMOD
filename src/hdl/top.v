`timescale 1ns / 1ps
module top(
    // sample rate fs = 48kHz
    // clk = 6*256*fs = 73.728MHz
    input wire clk,
    // reset with polarity low: low means reset asserted
    input wire rstn,

    // uart
    input wire uart_rx,
    output wire uart_tx,

    // switches
    input wire [3:0] switches,

    // spi flash
    output wire spi_cs,
    output wire spi_dq0, // sdi
    input wire spi_dq1, // sdo
    output wire spi_dq2, // wp
    output wire spi_dq3, // hld
    output wire spi_sck,

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
    output wire i2s_bclk,

    // access block ram
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM ADDR" *)
    output wire [31:0] bram_addra,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM CLK" *)
    output wire bram_clka,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM DOUT" *)
    input wire [31:0] bram_douta,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM EN" *)
    output wire bram_ena,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM RST" *)
    output wire bram_rsta
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
    localparam NUM_I2C_ASSIGNMENTS = 9;
    reg [8+16-1:0] i2c_assignments [0:NUM_I2C_ASSIGNMENTS-1];
    localparam I2C_ADDRESS = 8'b00110100;
    initial begin
        // Power up sequence at Page 61
        // Reset device
        i2c_assignments[0] = {I2C_ADDRESS, 7'b0001111, 9'b0_0000_0000};
        // Power on required bits except OUTPD
        i2c_assignments[1] = {I2C_ADDRESS, 7'b0000110, 9'b0_0111_0000};
        // Disable mic mute and bypass, select mic input and dac, enable mic boost
        i2c_assignments[2] = {I2C_ADDRESS, 7'b0000100, 9'b0_0001_0101};
        // Disable mute for left and right line in with default volume
        i2c_assignments[3] = {I2C_ADDRESS, 7'b0000001, 9'b1_0001_0111};
        // Disable soft mute for dac
        i2c_assignments[4] = {I2C_ADDRESS, 7'b0000101, 9'b0_0000_0000};
        // Set audio format to MSB-first, left justified
        i2c_assignments[5] = {I2C_ADDRESS, 7'b0000111, 9'b0_0000_1001};
        // Set headphone out to -20dB
        i2c_assignments[6] = {I2C_ADDRESS, 7'b0000010, 9'b1_1110_0101};
        // Activate interface
        i2c_assignments[7] = {I2C_ADDRESS, 7'b0001001, 9'b0_0000_0001};
        // Power on OUTPD
        i2c_assignments[8] = {I2C_ADDRESS, 7'b0000110, 9'b0_0110_0000};
    end

    /***************************************************************************
        Quartus may miscompile the initialization code above
       	Use code below instead
	And rename this file to .sv before importing to project

        parameter bit [23:0] i2c_assignments [0:NUM_I2C_ASSIGNMENTS-1] = '{
		// Power up sequence at Page 61
		// Reset device
		i2c_assignments[0] = {I2C_ADDRESS, 7'b0001111, 9'b0_0000_0000};
		// Power on required bits except OUTPD
		i2c_assignments[1] = {I2C_ADDRESS, 7'b0000110, 9'b0_0111_0000};
		// Disable mic mute and bypass, select mic input and dac, enable mic boost
		i2c_assignments[2] = {I2C_ADDRESS, 7'b0000100, 9'b0_0001_0101};
		// Disable mute for left and right line in with default volume
		i2c_assignments[3] = {I2C_ADDRESS, 7'b0000001, 9'b1_0001_0111};
		// Disable soft mute for dac
		i2c_assignments[4] = {I2C_ADDRESS, 7'b0000101, 9'b0_0000_0000};
		// Set audio format to MSB-first, left justified
		i2c_assignments[5] = {I2C_ADDRESS, 7'b0000111, 9'b0_0000_1001};
		// Set headphone out to -20dB
		i2c_assignments[6] = {I2C_ADDRESS, 7'b0000010, 9'b1_1110_0101};
		// Activate interface
		i2c_assignments[7] = {I2C_ADDRESS, 7'b0001001, 9'b0_0000_0001};
		// Power on OUTPD
		i2c_assignments[8] = {I2C_ADDRESS, 7'b0000110, 9'b0_0110_0000};
        };
    ***************************************************************************/

    reg [7:0] i2c_assignment_index;
    // bit index in assignment(23 downto 0)
    reg [7:0] i2c_bit_index;

    reg [7:0] i2c_scl_counter;
    reg i2c_scl_reg;
    reg i2c_sda_reg;
    reg i2c_sda_reg_delay;
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
        i2c_sda_reg_delay <= i2c_sda_reg;
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
                        i2c_bit_index <= 8'd23;
                    end
                    I2C_STATE_START1: begin
                        i2c_scl_reg <= 1'b0;
                        i2c_state <= I2C_STATE_WRITE;
                        i2c_sda_reg <= i2c_assignments[i2c_assignment_index][i2c_bit_index];
                        i2c_bit_index <= i2c_bit_index - 8'b1;
                    end
                    I2C_STATE_WRITE: begin
                        if (i2c_scl_reg == 1'b1) begin
                            // scl fall
                            if (i2c_prev_state == I2C_STATE_WRITE && (i2c_bit_index == 8'd15 || i2c_bit_index == 8'd7 || i2c_bit_index == 8'hff)) begin
                                // 8 bits sent
                                i2c_state <= I2C_STATE_READ_ACK;
                                i2c_sda_t_reg <= 1'b1;
                                i2c_sda_reg <= 1'b0;
                            end else begin
                                i2c_sda_t_reg <= 1'b0;
                                i2c_sda_reg <= i2c_assignments[i2c_assignment_index][i2c_bit_index];
                                i2c_bit_index <= i2c_bit_index - 8'b1;
                            end
                        end
                        i2c_scl_reg <= ~i2c_scl_reg;
                    end
                    I2C_STATE_READ_ACK: begin
                        if (i2c_scl_reg == 1'b1) begin
                            // scl fall
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

    // delay sda by one cycle to avoid timing issue
    assign i2c_sda_o = i2c_sda_reg_delay;
    assign i2c_sda_t = i2c_sda_t_reg;

    // For Quartus
    // assign io_sda = i2c_sda_t ? 1'bZ : i2c_sda_o

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

    // bram to i2s dac
    assign bram_rsta = 1'b0;
    assign bram_ena = 1'b1;
    assign bram_clka = clk;

    reg [7:0] i2s_bclk_counter;
    reg i2s_bclk_reg;
    reg [31:0] bram_addr;
    wire [31:0] bram_addr_shift;
    reg [31:0] bram_data;

    assign spi_cs = 1'b1;
    assign spi_dq0 = 1'b0;
    assign spi_dq2 = 1'b0;
    assign spi_dq3 = 1'b0;
    assign spi_sck = 1'b0;

    // bypass or from bram
    assign i2s_dacdat = switches[0] ? i2s_adcdat : bram_data[31];

    // byte-addressed
    assign bram_addr_shift = {bram_addr[31:2], 2'b0};
    assign bram_addra = bram_addr_shift;

    initial begin
        i2s_bclk_counter = 8'b0;
        bram_addr = 32'b0;
        bram_data = 32'b0;
    end
    always @(posedge clk) begin
        if (rst) begin
            i2s_bclk_counter <= 16'b0;
            i2s_bclk_reg <= 1'b0;
            bram_addr <= 32'b0;
            bram_data <= 32'b0;
        end else begin
            // divide by 32
            if (i2s_bclk_counter == 8'd15) begin
                if (i2s_bclk_reg == 1'b1) begin
                    // fall edge
                    bram_data <= {bram_data[30:0], 1'b0};
                end

                if (i2s_lrclk_counter == 16'd767 && i2s_lrclk_reg == 1'b0) begin
                    // lrclk rise
                    bram_data <= bram_douta;
                    if (bram_addr[31:2] < 32'd30000 - 32'd1) begin
                        bram_addr <= bram_addr + 32'b1;
                    end else begin
                        bram_addr <= 32'b0;
                    end
                end else if (i2s_lrclk_counter == 16'd767 && i2s_lrclk_reg == 1'b1) begin
                    // lrclk fall
                    bram_data <= bram_douta;
                end

                i2s_bclk_reg <= ~i2s_bclk_reg;
                i2s_bclk_counter <= 8'b0;
            end else begin
                i2s_bclk_counter <= i2s_bclk_counter + 8'b1;
            end
        end
    end
    assign i2s_bclk = i2s_bclk_reg;
endmodule

