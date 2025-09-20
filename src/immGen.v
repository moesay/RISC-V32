`timescale 1ns/1ps

module immGen(
  input logic [31:0] i_inst,
  input logic [2:0] i_immType,
  output logic [31:0] o_immOut
);

`include "params.vh"

always @(*) begin
  case (i_immType)
    IMM_I: o_immOut = {{20{i_inst[31]}}, i_inst[31:20]};
    IMM_S: o_immOut = {{20{i_inst[31]}}, i_inst[31:25], i_inst[11:7]};
    IMM_B: o_immOut = {{19{i_inst[31]}}, i_inst[31], i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0};
    IMM_U: o_immOut = {i_inst[31:12], 12'b0};
    IMM_J: o_immOut = {{11{i_inst[31]}}, i_inst[31], i_inst[19:12], i_inst[20], i_inst[30:21], 1'b0};
    default: o_immOut = 32'b0;
  endcase
end

endmodule
