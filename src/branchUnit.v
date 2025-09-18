`timescale 1ns/1ps

module branchUnit (
  input logic isBranch,   // opcode == 1100011
  input logic isJal,      // opcode == 1101111
  input logic isJalr,     // opcode == 1100111
  input logic [2:0] brFunct3,   // funct3 when isBranch=1
  input logic [31:0] pc,
  input logic [31:0] rs1,
  input logic [31:0] rs2,
  input logic [31:0] immB,
  input logic [31:0] immJ,
  input logic [31:0] immI,
  output logic take,       // branch/jump taken?
  output logic [31:0] nextPC
);

// Precompute conditions
logic eq, ne, slt, sge, sltu, sgeu;

always @(*) begin
  // Default: sequential execution
  nextPC = pc + 32'd4;
  take   = 1'b0;

  eq = (rs1 == rs2);
  ne = ~eq;
  slt = ($signed(rs1) <  $signed(rs2));
  sge = ~slt;
  sltu = (rs1 < rs2);   // unsigned
  sgeu = ~sltu;

  // Branch instructions
  if (isBranch) begin
    case (brFunct3)
      3'b000: take = eq;
      3'b001: take = ne;
      3'b100: take = slt;
      3'b101: take = sge;
      3'b110: take = sltu;
      3'b111: take = sgeu;
      default: take = 1'b0;
    endcase

    if (take)
      nextPC = pc + immB;
  end

  // JAL (unconditional jump)
  if (isJal) begin
    take   = 1'b1;
    nextPC = pc + immJ;
  end

  // JALR (unconditional, indirect)
  if (isJalr) begin
    take   = 1'b1;
    nextPC = (rs1 + immI) & ~32'h1;  // clear bit 0 (RV32I stds)
  end
end

endmodule
