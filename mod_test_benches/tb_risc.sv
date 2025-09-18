`timescale 1ns/1ps

module tb_risc;
logic clk, reset;

risc dut (
  .clk(clk),
  .reset(reset)
  );

  always #1 clk = ~clk;

  initial begin
    clk = 0;
    reset = 1;

    #10 reset = 0;

    #1000;

    $display("Final Register Values:");
    $display("======================");
    for (int i = 0; i < 32; i++) begin
      $display("x%0d = %0d (0x%08x)", i, dut.regFileMod.regs[i], dut.regFileMod.regs[i]);
    end

    $display("======================");
    $finish;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_risc);
  end
  endmodule
