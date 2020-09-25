`timescale 1ns/1ps

module tb_top;

logic clk = 1'b0;

top DUT (

);

always begin
    #10 clk = ~clk;
end

initial begin
    $display("Starting sim...");
    $dumpfile("tb_top.vcd");
    $dumpvars;


    #10000000;
    $display("Finishing sim");
    $finish;
end

endmodule