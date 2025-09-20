`timescale 1ns/1ps

module risc (
  input logic clk,
  input logic reset
);


`include "params.vh"

wire [31:0] pc, nextPC;
pc pcMod
(
  .i_clk(clk),
  .i_reset(reset),
  .i_nextPC(nextPC),
  .o_addr(pc)
);

wire [31:0] inst;
wire [6:0] opcode = inst[6:0];

imem#(.MEM_SIZE_KB(2)) imemMod
(
  .i_pc(pc),
  .o_inst(inst)
);

wire regWrite, memRead, memWrite, branch, jump, aluSrcImm, jalr;
wire [2:0] funct3;
wire [15:0] aluOp;
wire [2:0] immType;

decoder decoderMod
(
  .i_inst(inst),
  .o_regWrite(regWrite),
  .o_memRead(memRead),
  .o_memWrite(memWrite),
  .o_branch(branch),
  .o_jump(jump),
  .o_aluSrcImm(aluSrcImm),
  .o_jalr(jalr),
  .o_funct3(funct3),
  .o_aluOp(aluOp),
  .o_immType(immType)
);


wire [31:0] immVal;
immGen immGenMod
(
  .i_inst(inst),
  .i_immType(immType),
  .o_immOut(immVal)
);

wire [4:0] rs1, rs2, rd;
wire [31:0] rs1Data, rs2Data;
reg [31:0] writeData;
wire [31:0] memReadData;

assign rs1 = inst[19:15];
assign rs2 = inst[24:20];
assign rd  = inst[11:7];

regFile regFileMod
(
  .i_clk(clk),
  .i_regWrite(regWrite),
  .i_regSelect1(rs1),
  .i_regSelect2(rs2),
  .i_writeRegSelect(rd),
  .i_dataIn(writeData),
  .o_dataOut1(rs1Data),
  .o_dataOut2(rs2Data)
);

wire [31:0] aluIn1, aluIn2, aluResult;
wire zero;

assign aluIn1 = (opcode == 7'b0010111) ? pc : rs1Data;
assign aluIn2 = (aluSrcImm) ? immVal : rs2Data;

alu alu0
(
  .i_a(aluIn1),
  .i_b(aluIn2),
  .i_aluCtrl(aluOp),
  .o_result(aluResult),
  .o_zero(zero)
);

dmem#(.MEM_SIZE_KB(1)) dmemMod
(
  .i_clk(clk),
  .i_memRead(memRead),
  .i_memWrite(memWrite),
  .i_addr(aluResult),
  .i_funct3(funct3),
  .i_dataIn(rs2Data),
  .o_dataOut(memReadData)
);

wire takeBranch;

branchUnit branchUnitMod
(
  .i_isBranch(branch),
  .i_isJal(jump),
  .i_isJalr(jalr),
  .i_funct3(inst[14:12]),
  .i_pc(pc),
  .i_rs1(rs1Data),
  .i_rs2(rs2Data),
  .i_immB(immVal),
  .i_immJ(immVal),
  .i_immI(immVal),
  .o_take(takeBranch),
  .o_nextPC(nextPC)
);

always @(*)
begin
  if(jump || jalr)
    writeData = pc + 32'h4;
  else if(memRead)
    writeData = memReadData;
  else
    writeData = aluResult;
end
endmodule
