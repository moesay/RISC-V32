`timescale 1ns/1ps

module tb_pc();
logic i_clk, i_reset;
logic [31:0] i_nextPC;
logic [31:0] o_addr;

always #1 i_clk = ~i_clk;

pc dut (
  .i_clk(i_clk),
  .i_reset(i_reset),
  .i_nextPC(i_nextPC),
  .o_addr(o_addr)
  );

  task check(input [31:0] expected, string msg);
    if (o_addr !== expected)
      $error("%s FAILED: got %h, expected %h", msg, o_addr, expected);
    else
      $display("%s PASSED", msg);
  endtask

  initial begin
    i_clk = 0;
    i_reset = 0;
    i_nextPC = 32'h0;

    i_reset = 1;
    #10; i_reset = 0;
    check(32'h0, "i_reset check");

    i_nextPC = o_addr + 4;
    #10; check(32'h4, "Increment by 4");
    i_nextPC = o_addr + 4;
    #10; check(32'h8, "Increment again");

    i_nextPC = 32'h40;
    #10; check(32'h40, "Jump to 0x40");

    i_nextPC = o_addr + 4;
    #10; check(32'h44, "Increment after jump");

    $display("All tests finished!");
    $finish;
  end
  endmodule
