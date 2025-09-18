`timescale 1ns/1ps
module tb_imem;
logic [31:0] pc;
logic [31:0] inst;

imem#(.MEM_SIZE_KB(1)) dut (
    .pc(pc),
    .inst(inst));

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_instMemory);

    pc = 32'h0; #1;
    $display("addr = %h inst = %h", pc, inst);

    pc = 32'h4; #1;
    $display("addr = %h inst = %h", pc, inst);

    pc = 32'h8; #1;
    $display("addr = %h inst = %h", pc, inst);

    $finish;
end
endmodule
