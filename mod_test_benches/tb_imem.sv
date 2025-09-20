`timescale 1ns/1ps
module tb_imem;
logic [31:0] i_pc;
logic [31:0] o_inst;

imem#(.MEM_SIZE_KB(1)) dut (
    .i_pc(i_pc),
    .o_inst(o_inst));

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_o_instMemory);

    i_pc = 32'h0; #1;
    $display("addr = %h o_inst = %h", i_pc, o_inst);

    i_pc = 32'h4; #1;
    $display("addr = %h o_inst = %h", i_pc, o_inst);

    i_pc = 32'h8; #1;
    $display("addr = %h o_inst = %h", i_pc, o_inst);

    $finish;
end
endmodule
