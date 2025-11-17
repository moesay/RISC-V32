`timescale 1ns/1ps

module jumpBranchUnit (
  // Control signals
  input logic i_isBranch,
  input logic i_isJal,
  input logic i_isJalr,
  input logic [2:0] i_funct3,

  // Data inputs
  input logic [31:0] i_pc,
  input logic [31:0] i_rs1,
  input logic [31:0] i_rs2,
  input logic [31:0] i_imm,

  // Outputs
  output logic o_take,
  output logic [31:0] o_target,
  output logic [31:0] o_linkAddr  // PC+4 for JAL/JALR
);

// Calculate link address (return address)
assign o_linkAddr = i_pc + 32'd4;

// Branch comparison logic
logic eq, ne, lt, ge, ltu, geu;
assign eq  = (i_rs1 == i_rs2);
assign ne  = ~eq;
assign lt  = ($signed(i_rs1) < $signed(i_rs2));
assign ge  = ~lt;
assign ltu = (i_rs1 < i_rs2);
assign geu = ~ltu;

// Branch decision
logic branch_taken;
always @(*) begin
  branch_taken = 1'b0;
  if (i_isBranch) begin
    case (i_funct3)
      3'b000: branch_taken = eq;   // BEQ
      3'b001: branch_taken = ne;   // BNE
      3'b100: branch_taken = lt;   // BLT
      3'b101: branch_taken = ge;   // BGE
      3'b110: branch_taken = ltu;  // BLTU
      3'b111: branch_taken = geu;  // BGEU
      default: branch_taken = 1'b0;
    endcase
  end
end

// Target calculation and control decision
always @(*) begin
  o_take = 1'b0;
  o_target = i_pc + 32'd4;  // Default: next instruction

  if (i_isJal) begin
    // JAL: unconditional jump to PC + immediate
    o_take = 1'b1;
    o_target = i_pc + i_imm;
  end
  else if (i_isJalr) begin
    // JALR: unconditional jump to (rs1 + immediate) & ~1
    o_take = 1'b1;
    o_target = (i_rs1 + i_imm) & ~32'h1;  // Clear LSB per RISC-V spec
  end
  else if (i_isBranch && branch_taken) begin
    // Conditional branch
    o_take = 1'b1;
    o_target = i_pc + i_imm;
  end
end

endmodule
