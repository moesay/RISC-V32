`timescale 1ns/1ps

module alu(
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [15:0] aluCtrl,
    output logic [31:0] result,
    output wire zero
);

`include "params.vh"

logic [63:0] mulBuffer;
wire sign_a = a[31];
wire [31:0] abs_a = sign_a ? (-a) : a;
wire [63:0] unsigned_product = abs_a * b;
assign zero = (result == 32'b0);

always @(*)
begin
    result = 32'b0;
    mulBuffer = 64'b0;
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
        ALU_MUL:
        begin
            mulBuffer = $signed(a) * $signed(b);
            result = mulBuffer[31:0];
        end
        ALU_MULH:
        begin
            mulBuffer = $signed(a) * $signed(b);
            result = mulBuffer[63:32];
        end
        ALU_MULHSU:
        begin
            mulBuffer = sign_a ? (-unsigned_product) : unsigned_product;
            result = mulBuffer[63:32];
        end
        ALU_MULHU:
        begin
            mulBuffer = $unsigned(a) * $unsigned(b);
            result = mulBuffer[63:32];
        end
        ALU_DIV:
        begin
            // MIN_INT overflow check, as per std
            if(a == 32'h80000000 && b == -1)
                result = 32'h80000000;
            else
                result = (b == 0) ? -1 : $signed(a) / $signed(b);
        end
        ALU_DIVU: result = (b == 0) ? -1 : $unsigned(a) / $unsigned(b);
        ALU_REM: result = (b == 0) ? $signed(a) : ($signed(a) % $signed(b));
        ALU_REMU: result = (b == 0) ? $unsigned(a) : ($unsigned(a) % $unsigned(b));
        ALU_A_PASSTHROUGH: result = a;
        ALU_B_PASSTHROUGH: result = b;
        default:  result = 32'b0;
    endcase
end

endmodule
