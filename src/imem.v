`timescale 1ns/1ps
module imem#(
  parameter MEM_SIZE_KB = 1
)
(
  input logic [31:0] pc,
  output wire [31:0] inst
);
logic [31:0] memory [0:(MEM_SIZE_KB*256)-1];
assign inst = memory[pc >> 2]; //since the addrs are word-aligned, ignore the first two bits

// for testing
initial begin
  `ifdef TEST_PROGRAM
    $display("Loading %s", `TEST_PROGRAM);
    $readmemh(`TEST_PROGRAM, memory);
  `else
    $display("Running with default memory");
  `endif
end
endmodule
