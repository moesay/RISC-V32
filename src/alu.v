`timescale 1ns/1ps

module alu(
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [3:0] aluCtrl,
    output logic [31:0] result,
    output wire zero
);

`include "params.vh"

assign zero = (result == 32'b0);

always @(*)
begin
    result = 32'b0;
    case (aluCtrl)
    ALU_ADD: result = a + b;
    ALU_SUB: result = a - b;
    ALU_AND: result = a & b;
    ALU_OR: result = a | b;
    ALU_XOR: result = a ^ b;
    ALU_SLL: result = a << b[4:0];
    ALU_SRL: result = a >> b[4:0];
    ALU_SRA: result = $signed(a) >>> b[4:0];
    ALU_SLT: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
    ALU_SLTU: result = (a < b) ? 32'd1 : 32'd0;
    ALU_A_PASSTHROUGH: result = a;
    ALU_B_PASSTHROUGH: result = b;
    default:  result = 32'b0;
endcase
end

endmodule
