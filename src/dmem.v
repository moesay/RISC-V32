`timescale 1ns/1ps
module dmem#(
  parameter MEM_SIZE_KB = 1
)
(
  input logic i_clk,
  input logic i_memRead,
  input logic i_memWrite,
  input logic [31:0] i_addr,
  input logic [31:0] i_dataIn,
  input logic [2:0] i_funct3,
  output logic [31:0] o_dataOut
);

// logic [31:0] internalMem [0:(MEM_SIZE_KB * 256)-1];
logic [31:0] internalMem [0:31];
logic [31:0] shiftedAddr;

assign shiftedAddr = i_addr << 2;

always @(*)
begin
  if(i_memRead) begin
    case(i_funct3)
      3'b000: begin // LB sign-ex
        case(shiftedAddr[1:0])
          2'b00: o_dataOut = {{24{internalMem[shiftedAddr][7]}}, internalMem[shiftedAddr][7:0]};
          2'b01: o_dataOut = {{24{internalMem[shiftedAddr][15]}}, internalMem[shiftedAddr][15:8]};
          2'b10: o_dataOut = {{24{internalMem[shiftedAddr][23]}}, internalMem[shiftedAddr][23:16]};
          2'b11: o_dataOut = {{24{internalMem[shiftedAddr][31]}}, internalMem[shiftedAddr][31:24]};
        endcase
      end
      3'b001: begin //LH sign-ex
        case(shiftedAddr[0])
          1'b0: o_dataOut = {{16{internalMem[shiftedAddr][15]}}, internalMem[shiftedAddr][15:0]};
          1'b1: o_dataOut = {{16{internalMem[shiftedAddr][31]}}, internalMem[shiftedAddr][31:16]};
        endcase
      end
      3'b010: begin // LW
        o_dataOut = internalMem[shiftedAddr];
      end
      3'b100: begin // LBU
        case(shiftedAddr[1:0])
          2'b00: o_dataOut = {24'b0, internalMem[shiftedAddr][7:0]};
          2'b01: o_dataOut = {24'b0, internalMem[shiftedAddr][15:8]};
          2'b10: o_dataOut = {24'b0, internalMem[shiftedAddr][23:16]};
          2'b11: o_dataOut = {24'b0, internalMem[shiftedAddr][31:24]};
        endcase
      end
      3'b101: begin //LHU
        case(shiftedAddr[0])
          1'b0: o_dataOut = {16'b0, internalMem[shiftedAddr][15:0]};
          1'b1: o_dataOut = {16'b0, internalMem[shiftedAddr][31:16]};
        endcase
      end
      default: o_dataOut = 32'b0;
    endcase
  end
  else begin
        o_dataOut = 32'b0;
  end
end

always @(posedge i_clk)
begin
  if(i_memWrite)
    internalMem[shiftedAddr] <= i_dataIn;
  end
endmodule
