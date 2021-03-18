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

    top dut(
        .clk(clk),
        .rstn(~rst)
    );
endmodule
