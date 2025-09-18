`timescale 1ns/1ps

module risc (
  input logic clk,
  input logic reset
);


`include "params.vh"

wire [31:0] pc, nextPC;
pc pcMod
(
  .clk(clk),
  .addr(pc),
  .reset(reset),
  .nextPC(nextPC)
);

wire [31:0] inst;
wire [6:0] opcode = inst[6:0];

imem#(.MEM_SIZE_KB(2)) imemMod
(
  .pc(pc),
  .inst(inst)
);

wire regWrite, memRead, memWrite, branch, jump, aluSrcImm, jalr;
wire [2:0] funct3;
wire [3:0] aluOp;
wire [2:0] immType;

decoder decoderMod
(
  .inst(inst),
  .regWrite(regWrite),
  .memRead(memRead),
  .memWrite(memWrite),
  .branch(branch),
  .jump(jump),
  .aluSrcImm(aluSrcImm),
  .jalr(jalr),
  .funct3(funct3),
  .aluOp(aluOp),
  .immType(immType)
);


wire [31:0] immVal;
immGen immGenMod
(
  .inst(inst),
  .immType(immType),
  .immOut(immVal)
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
  .clk(clk),
  .regWrite(regWrite),
  .rs1(rs1),
  .rs2(rs2),
  .rd(rd),
  .wd(writeData),
  .rd1(rs1Data),
  .rd2(rs2Data)
);

wire [31:0] aluIn1, aluIn2, aluResult;
wire zero;

assign aluIn1 = (opcode == 7'b0010111) ? pc : rs1Data;
assign aluIn2 = (aluSrcImm) ? immVal : rs2Data;

alu alu0
(
  .a(aluIn1),
  .b(aluIn2),
  .aluCtrl(aluOp),
  .result(aluResult),
  .zero(zero)
);

dmem#(.MEM_SIZE_KB(1)) dmemMod
(
  .clk(clk),
  .memRead(memRead),
  .memWrite(memWrite),
  .addr(aluResult),
  .funct3(funct3),
  .writeData(rs2Data),
  .readData(memReadData)
);

wire takeBranch;

branchUnit branchUnitMod
(
  .isBranch(branch),
  .isJal(jump),
  .isJalr(jalr),
  .brFunct3(inst[14:12]),
  .pc(pc),
  .rs1(rs1Data),
  .rs2(rs2Data),
  .immB(immVal),
  .immJ(immVal),
  .immI(immVal),
  .take(takeBranch),
  .nextPC(nextPC)
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
