`timescale 1ns/1ps

module tb_branchUnit;

  logic i_isBranch, i_isJal, i_isJalr;
  logic [2:0] i_i_funct3;
  logic [31:0] i_pc, i_rs1, i_rs2, i_immB, i_immJ, i_immI;

  logic o_take;
  logic [31:0] o_nextPC;

  branchUnit dut (
    .i_isBranch(i_isBranch),
    .i_isJal(i_isJal),
    .i_isJalr(i_isJalr),
    .i_i_funct3(i_i_funct3),
    .i_pc(i_pc),
    .i_rs1(i_rs1),
    .i_rs2(i_rs2),
    .i_immB(i_immB),
    .i_immJ(i_immJ),
    .i_immI(i_immI),
    .o_take(o_take),
    .o_nextPC(o_nextPC)
  );

  task automatic check(
    input string name,
    input logic expected_o_take,
    input logic [31:0] expected_i_pc
  );
    if (o_take !== expected_o_take || o_nextPC !== expected_i_pc) begin
      $error("%s FAILED: got o_take=%0b o_nextPC=0x%08x, expected o_take=%0b o_nextPC=0x%08x",
             name, o_take, o_nextPC, expected_o_take, expected_i_pc);
    end else begin
      $display("[%0t] %s PASSED", $time, name);
    end
  endtask

  initial begin
    i_pc = 32'h1000;
    i_rs1 = 32'd5;
    i_rs2 = 32'd5;
    i_immB = 32'd16;   // branch offset
    i_immJ = 32'd128;  // JAL offset
    i_immI = 32'd20;   // JALR offset

    i_isBranch = 0; i_isJal = 0; i_isJalr = 0; i_i_funct3 = 3'b000;

    i_isBranch = 1; i_i_funct3 = 3'b000;
    #1 check("BEQ o_taken", 1, i_pc + i_immB);

    i_i_funct3 = 3'b001;
    #1 check("BNE not o_taken", 0, i_pc + 4);

    i_i_funct3 = 3'b100;
    #1 check("BLT not o_taken", 0, i_pc + 4);

    i_i_funct3 = 3'b101;
    #1 check("BGE o_taken", 1, i_pc + i_immB);

    i_isBranch = 0; i_isJal = 1; i_isJalr = 0;
    #1 check("JAL", 1, i_pc + i_immJ);

    i_isJal = 0; i_isJalr = 1;
    #1 check("JALR", 1, (i_rs1 + i_immI) & ~32'h1);

    $display("All branchUnit tests completed.");
    $finish;
  end

endmodule
