`timescale 1ns/1ps

module branchUnit_pipelined (
  input logic i_isBranch,
  input logic i_isJal,
  input logic [2:0] i_funct3,
  input logic [31:0] i_pc,
  input logic [31:0] i_rs1,
  input logic [31:0] i_rs2,
  input logic [31:0] i_imm,
  output logic o_take,
  output logic [31:0] o_target
);

logic eq, ne, lt, ge, ltu, geu;

assign eq  = (i_rs1 == i_rs2);
assign ne  = ~eq;
assign lt  = ($signed(i_rs1) <  $signed(i_rs2));
assign ge  = ~lt;
assign ltu = (i_rs1 < i_rs2);
assign geu = ~ltu;

always @(*) begin
  o_take = 1'b0;
  o_target = i_pc + 32'd4;

  if (i_isBranch) begin
    case (i_funct3)
      3'b000: o_take = eq;
      3'b001: o_take = ne;
      3'b100: o_take = lt;
      3'b101: o_take = ge;
      3'b110: o_take = ltu;
      3'b111: o_take = geu;
      default: o_take = 1'b0;
    endcase
    if (o_take) begin
      o_target = i_pc + i_imm;
    end
  end

  if (i_isJal) begin
    o_take = 1'b1;
    o_target = i_pc + i_imm;
  end

  // JALR will handled separately as uts target is rs1 + imm
  // It is more complex and might requires its own logic/stall.
end

endmodule
