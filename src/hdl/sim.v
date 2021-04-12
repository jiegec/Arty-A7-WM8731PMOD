`timescale 1ns / 1ps
module sim(

    );

    reg clk;
    reg rst;

    initial begin
        rst = 1'b1;
        repeat (10) @ (posedge clk);
        rst = 1'b0;
    end

    initial begin
        clk = 1'b0;
    end

    always clk = #5 ~clk;

    wire [31:0] bram_addra;
    reg [31:0] bram_douta;

    always @(posedge clk) begin
        bram_douta <= bram_addra * bram_addra * bram_addra * bram_addra;
    end

    top dut(
        .clk(clk),
        .rstn(~rst),
        .bram_addra(bram_addra),
        .bram_douta(bram_douta)
    );
endmodule
