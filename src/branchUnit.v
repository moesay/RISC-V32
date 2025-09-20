`timescale 1ns/1ps

module branchUnit (
  input logic i_isBranch,   // opcode == 1100011
  input logic i_isJal,      // opcode == 1101111
  input logic i_isJalr,     // opcode == 1100111
  input logic [2:0] i_funct3,   // funct3 when i_isBranch=1
  input logic [31:0] i_pc,
  input logic [31:0] i_rs1,
  input logic [31:0] i_rs2,
  input logic [31:0] i_immB,
  input logic [31:0] i_immJ,
  input logic [31:0] i_immI,
  output logic o_take,       // branch/jump take?
  output logic [31:0] o_nextPC
);

// Precompute conditions
logic eq, ne, slt, sge, sltu, sgeu;

always @(*) begin
  // Default: sequential execution
  o_nextPC = i_pc + 32'd4;
  o_take   = 1'b0;

  eq = (i_rs1 == i_rs2);
  ne = ~eq;
  slt = ($signed(i_rs1) <  $signed(i_rs2));
  sge = ~slt;
  sltu = (i_rs1 < i_rs2);   // unsigned
  sgeu = ~sltu;

  // Branch instructions
  if (i_isBranch) begin
    case (i_funct3)
      3'b000: o_take = eq;
      3'b001: o_take = ne;
      3'b100: o_take = slt;
      3'b101: o_take = sge;
      3'b110: o_take = sltu;
      3'b111: o_take = sgeu;
      default: o_take = 1'b0;
    endcase

    if (o_take)
      o_nextPC = i_pc + i_immB;
  end

  // JAL (unconditional jump)
  if (i_isJal) begin
    o_take   = 1'b1;
    o_nextPC = i_pc + i_immJ;
  end

  // JALR (unconditional, indirect)
  if (i_isJalr) begin
    o_take   = 1'b1;
    o_nextPC = (i_rs1 + i_immI) & ~32'h1;  // clear bit 0 (RV32I stds)
  end
end

endmodule
