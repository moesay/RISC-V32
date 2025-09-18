`timescale 1ns/1ps
module dmem#(
  parameter MEM_SIZE_KB = 1
)
(
  input logic clk,
  input logic memRead,
  input logic memWrite,
  input logic [31:0] addr,
  input logic [31:0] writeData,
  input logic [2:0] funct3,
  output logic [31:0] readData
);

logic [31:0] internalMem [0:(MEM_SIZE_KB * 256)-1];
logic [31:0] shiftedAddr;

assign shiftedAddr = addr << 2;

always @(*)
begin
  if(memRead) begin
    case(funct3)
      3'b000: begin // LB sign-ex
        case(shiftedAddr[1:0])
          2'b00: readData = {{24{internalMem[shiftedAddr][7]}}, internalMem[shiftedAddr][7:0]};
          2'b01: readData = {{24{internalMem[shiftedAddr][15]}}, internalMem[shiftedAddr][15:8]};
          2'b10: readData = {{24{internalMem[shiftedAddr][23]}}, internalMem[shiftedAddr][23:16]};
          2'b11: readData = {{24{internalMem[shiftedAddr][31]}}, internalMem[shiftedAddr][31:24]};
        endcase
      end
      3'b001: begin //LH sign-ex
        case(shiftedAddr[0])
          1'b0: readData = {{16{internalMem[shiftedAddr][15]}}, internalMem[shiftedAddr][15:0]};
          1'b1: readData = {{16{internalMem[shiftedAddr][31]}}, internalMem[shiftedAddr][31:16]};
        endcase
      end
      3'b010: begin // LW
        readData = internalMem[shiftedAddr];
      end
      3'b100: begin // LBU
        case(shiftedAddr[1:0])
          2'b00: readData = {24'b0, internalMem[shiftedAddr][7:0]};
          2'b01: readData = {24'b0, internalMem[shiftedAddr][15:8]};
          2'b10: readData = {24'b0, internalMem[shiftedAddr][23:16]};
          2'b11: readData = {24'b0, internalMem[shiftedAddr][31:24]};
        endcase
      end
      3'b101: begin //LHU
        case(shiftedAddr[0])
          1'b0: readData = {16'b0, internalMem[shiftedAddr][15:0]};
          1'b1: readData = {16'b0, internalMem[shiftedAddr][31:16]};
        endcase
      end
      default: readData = 32'b0;
    endcase
  end
  else begin
        readData = 32'b0;
  end
end

always @(posedge clk)
begin
  if(memWrite)
    internalMem[shiftedAddr] <= writeData;
  end
endmodule
