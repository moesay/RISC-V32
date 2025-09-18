`timescale 1ns/1ps

module tb_pc();
logic clk, reset;
logic [31:0] nextPC;
logic [31:0] addr;

always #1 clk = ~clk;

pc dut (
  .clk(clk),
  .reset(reset),
  .nextPC(nextPC),
  .addr(addr)
  );

  task check(input [31:0] expected, string msg);
    if (addr !== expected)
      $error("%s FAILED: got %h, expected %h", msg, addr, expected);
    else
      $display("%s PASSED", msg);
  endtask

  initial begin
    clk = 0;
    reset = 0;
    nextPC = 32'h0;

    reset = 1;
    #10; reset = 0;
    check(32'h0, "Reset check");

    nextPC = addr + 4;
    #10; check(32'h4, "Increment by 4");
    nextPC = addr + 4;
    #10; check(32'h8, "Increment again");

    nextPC = 32'h40;
    #10; check(32'h40, "Jump to 0x40");

    nextPC = addr + 4;
    #10; check(32'h44, "Increment after jump");

    $display("All tests finished!");
    $finish;
  end
  endmodule
