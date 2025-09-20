`timescale 1ns/1ps

module regFile(
  input logic i_clk,
  input logic i_regWrite,
  input logic [4:0] i_regSelect1, i_regSelect2, i_writeRegSelect,
  input reg [31:0] i_dataIn,
  output wire [31:0] o_dataOut1, o_dataOut2
);

// cpu registers
logic [31:0] regs [31:0];

// on any attempt to read from x0, return 0
assign o_dataOut1 = (i_regSelect1 == 0) ? 32'b0 : regs[i_regSelect1];
assign o_dataOut2 = (i_regSelect2 == 0) ? 32'b0 : regs[i_regSelect2];

always @(posedge i_clk) begin
  if (i_regWrite && i_writeRegSelect != 0) begin
    regs[i_writeRegSelect] <= i_dataIn;
  end
end

endmodule
