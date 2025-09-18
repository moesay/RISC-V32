`timescale 1ns/1ps

module regFile(
  input  logic clk,
  input  logic regWrite,
  input  logic [4:0] rs1, rs2, rd,
  input  reg [31:0] wd,
  output wire [31:0] rd1, rd2
);

// cpu registers
logic [31:0] regs [31:0];

// on any attempt to read from x0, return 0
assign rd1 = (rs1 == 0) ? 32'b0 : regs[rs1];
assign rd2 = (rs2 == 0) ? 32'b0 : regs[rs2];

always @(posedge clk) begin
  if (regWrite && rd != 0) begin
    regs[rd] <= wd;
  end
end

endmodule
