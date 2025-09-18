`timescale 1ns/1ps

module tb_branchUnit;

  logic isBranch, isJal, isJalr;
  logic [2:0] brFunct3;
  logic [31:0] pc, rs1, rs2, immB, immJ, immI;

  logic take;
  logic [31:0] nextPC;

  branchUnit dut (
    .isBranch(isBranch),
    .isJal(isJal),
    .isJalr(isJalr),
    .brFunct3(brFunct3),
    .pc(pc),
    .rs1(rs1),
    .rs2(rs2),
    .immB(immB),
    .immJ(immJ),
    .immI(immI),
    .take(take),
    .nextPC(nextPC)
  );

  task automatic check(
    input string name,
    input logic expected_take,
    input logic [31:0] expected_pc
  );
    if (take !== expected_take || nextPC !== expected_pc) begin
      $error("%s FAILED: got take=%0b nextPC=0x%08x, expected take=%0b nextPC=0x%08x",
             name, take, nextPC, expected_take, expected_pc);
    end else begin
      $display("[%0t] %s PASSED", $time, name);
    end
  endtask

  initial begin
    pc = 32'h1000;
    rs1 = 32'd5;
    rs2 = 32'd5;
    immB = 32'd16;   // branch offset
    immJ = 32'd128;  // JAL offset
    immI = 32'd20;   // JALR offset

    isBranch = 0; isJal = 0; isJalr = 0; brFunct3 = 3'b000;

    isBranch = 1; brFunct3 = 3'b000;
    #1 check("BEQ taken", 1, pc + immB);

    brFunct3 = 3'b001;
    #1 check("BNE not taken", 0, pc + 4);

    brFunct3 = 3'b100;
    #1 check("BLT not taken", 0, pc + 4);

    brFunct3 = 3'b101;
    #1 check("BGE taken", 1, pc + immB);

    isBranch = 0; isJal = 1; isJalr = 0;
    #1 check("JAL", 1, pc + immJ);

    isJal = 0; isJalr = 1;
    #1 check("JALR", 1, (rs1 + immI) & ~32'h1);

    $display("All branchUnit tests completed.");
    $finish;
  end

endmodule
