`timescale 1ns/1ps

module pc(
  input logic i_clk,
  input logic [31:0] i_nextPC,
  input logic i_reset, //active high
  output logic [31:0] o_addr
);

always @(posedge i_clk or posedge i_reset) begin
  if (i_reset)
    o_addr <= 32'h0;
  else
    o_addr <= i_nextPC;
end

endmodule
