`timescale 1ns/1ps

module immGen(
  input logic [31:0] inst,
  input logic [2:0] immType,
  output logic [31:0] immOut
);

`include "params.vh"

always @(*) begin
  case (immType)
    IMM_I: immOut = {{20{inst[31]}}, inst[31:20]};
    IMM_S: immOut = {{20{inst[31]}}, inst[31:25], inst[11:7]};
    IMM_B: immOut = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
    IMM_U: immOut = {inst[31:12], 12'b0};
    IMM_J: immOut = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
    default: immOut = 32'b0;
  endcase
end

endmodule
