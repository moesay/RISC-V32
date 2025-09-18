`timescale 1ns/1ps

module pc(
  input logic clk,
  input logic [31:0] nextPC,
  input logic reset, //active high
  output logic [31:0] addr
);

always @(posedge clk or posedge reset) begin
  if (reset)
    addr <= 32'h0;
  else
    addr <= nextPC;
end

endmodule
