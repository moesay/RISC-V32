`timescale 1ns/1ps

module alu(
    input logic [31:0] i_a,
    input logic [31:0] i_b,
    input logic [15:0] i_aluCtrl,
    output logic [31:0] o_result,
    output wire o_zero
);

`include "params.vh"

logic [63:0] mulBuffer;
wire sign_a = i_a[31];
wire [31:0] abs_a = sign_a ? (-i_a) : i_a;
wire [63:0] unsigned_product = abs_a * i_b;
assign o_zero = (o_result == 32'b0);

always @(*)
begin
    o_result = 32'b0;
    mulBuffer = 64'b0;
    case (i_aluCtrl)
        ALU_ADD: o_result = i_a + i_b;
        ALU_SUB: o_result = i_a - i_b;
        ALU_AND: o_result = i_a & i_b;
        ALU_OR: o_result = i_a | i_b;
        ALU_XOR: o_result = i_a ^ i_b;
        ALU_SLL: o_result = i_a << i_b[4:0];
        ALU_SRL: o_result = i_a >> i_b[4:0];
        ALU_SRA: o_result = $signed(i_a) >>> i_b[4:0];
        ALU_SLT: o_result = ($signed(i_a) < $signed(i_b)) ? 32'd1 : 32'd0;
        ALU_SLTU: o_result = (i_a < i_b) ? 32'd1 : 32'd0;
        ALU_MUL:
        begin
            mulBuffer = $signed(i_a) * $signed(i_b);
            o_result = mulBuffer[31:0];
        end
        ALU_MULH:
        begin
            mulBuffer = $signed(i_a) * $signed(i_b);
            o_result = mulBuffer[63:32];
        end
        ALU_MULHSU:
        begin
            mulBuffer = sign_a ? (-unsigned_product) : unsigned_product;
            o_result = mulBuffer[63:32];
        end
        ALU_MULHU:
        begin
            mulBuffer = $unsigned(i_a) * $unsigned(i_b);
            o_result = mulBuffer[63:32];
        end
        ALU_DIV:
        begin
            // MIN_INT overflow check, as per std
            if(i_a == 32'h80000000 && i_b == -1)
                o_result = 32'h80000000;
            else
                o_result = (i_b == 0) ? -1 : $signed(i_a) / $signed(i_b);
        end
        ALU_DIVU: o_result = (i_b == 0) ? -1 : $unsigned(i_a) / $unsigned(i_b);
        ALU_REM: o_result = (i_b == 0) ? $signed(i_a) : ($signed(i_a) % $signed(i_b));
        ALU_REMU: o_result = (i_b == 0) ? $unsigned(i_a) : ($unsigned(i_a) % $unsigned(i_b));
        ALU_A_PASSTHROUGH: o_result = i_a;
        ALU_B_PASSTHROUGH: o_result = i_b;
        default:  o_result = 32'b0;
    endcase
end

endmodule
