// Reference
//http://cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf
`timescale 1ns/1ps
module decoder(
  input  logic [31:0] inst,
  output logic regWrite,
  output logic memRead,
  output logic memWrite,
  output logic branch,
  output logic jump,
  output logic aluSrcImm,
  output wire [2:0] funct3,
  output wire jalr,
  output logic [15:0] aluOp,
  output reg [2:0] immType
);

`include "params.vh"
wire [6:0] opcode;
wire [6:0] funct7;

assign opcode = inst[6:0];
assign funct3 = inst[14:12];
assign funct7 = inst[31:25];
assign jalr = (inst[6:0] == 7'b1100111);

always @(*) begin
  //init vals
  regWrite  = 0;
  memRead   = 0;
  memWrite  = 0;
  branch    = 0;
  jump      = 0;
  aluSrcImm = 0;
  aluOp     = ALU_NOP;
  immType   = IMM_NONE;

  case (opcode)

    // R type inst
    7'b0110011: begin
      regWrite  = 1;
      immType   = IMM_NONE;
      aluSrcImm = 0;
      case (funct3)
        3'b000:
          case(funct7)
            7'h0: aluOp = ALU_ADD;
            7'h1: aluOp = ALU_MUL;
            7'h20: aluOp = ALU_SUB;
            default: aluOp = ALU_NOP;
          endcase
        3'b001:
          case(funct7)
            7'h0: aluOp = ALU_SLL;
            7'h1: aluOp = ALU_MULH;
            default: aluOp = ALU_NOP;
          endcase
        3'b010:
          case(funct7)
            7'h0: aluOp = ALU_SLT;
            7'h1: aluOp = ALU_MULHSU;
            default: aluOp = ALU_NOP;
          endcase
        3'b011:
          case(funct7)
            7'h0: aluOp = ALU_SLTU;
            7'h1: aluOp = ALU_MULHU;
            default: aluOp = ALU_NOP;
          endcase
        3'b100:
            case(funct7)
                7'h0: aluOp = ALU_XOR;
                7'h1: aluOp = ALU_DIV;
                default: aluOp = ALU_NOP;
            endcase
        3'b101:
            case(funct7)
                7'h0: aluOp = ALU_SRL;
                7'h1: aluOp = ALU_DIVU;
                7'h20: aluOp = ALU_SRA;
                default: aluOp = ALU_NOP;
            endcase
        3'b110:
            case(funct7)
                7'h0: aluOp = ALU_OR;
                7'h1: aluOp = ALU_REM;
                default: aluOp = ALU_NOP;
            endcase
        3'b111:
            case(funct7)
                7'h0: aluOp = ALU_AND;
                7'h1: aluOp = ALU_REMU;
                default: aluOp = ALU_NOP;
            endcase
      endcase
    end

    // I type
    7'b0010011: begin
      regWrite  = 1;
      aluSrcImm = 1;
      immType   = IMM_I;
      case (funct3)
        3'b000: aluOp = ALU_ADD; // ADDI
        3'b010: aluOp = ALU_SLT; // SLTI
        3'b011: aluOp = ALU_SLTU;// SLTIU
        3'b100: aluOp = ALU_XOR; // XORI
        3'b110: aluOp = ALU_OR;  // ORI
        3'b111: aluOp = ALU_AND; // ANDI
        3'b001: aluOp = ALU_SLL; // SLLI
        3'b101: aluOp = (funct7 == 7'h20) ? ALU_SRA : ALU_SRL;
      endcase
    end

    // loads
    7'b0000011: begin
      regWrite  = 1;
      memRead   = 1;
      aluSrcImm = 1;
      immType   = IMM_I;
      aluOp     = ALU_ADD; // addr = base + offset
    end

    // store
    7'b0100011: begin
      memWrite  = 1;
      aluSrcImm = 1;
      immType   = IMM_S;
      aluOp     = ALU_ADD; // addr = base + offset
    end

    // branching
    7'b1100011: begin
      branch    = 1;
      immType   = IMM_B;
      aluSrcImm = 0;
      aluOp     = ALU_SUB; // for comparison
    end

    // jumps
    7'b1101111: begin // JAL
    jump      = 1;
    regWrite  = 1;
    immType   = IMM_J;
    end
    7'b1100111: begin // JALR
    jump      = 1;
    regWrite  = 1;
    aluSrcImm = 1;
    immType   = IMM_I;
    end

    // lui
    7'b0110111: begin
    regWrite  = 1;
    aluSrcImm = 1;
    immType   = IMM_U;
    aluOp     = ALU_B_PASSTHROUGH; // ie imm << 12
    end

    7'b0010111: begin // AUIPC
    regWrite  = 1;
    aluSrcImm = 1;
    immType   = IMM_U;
    aluOp     = ALU_ADD; // PC + imm
    end

    default: begin
    // Unknown opcode
    end
  endcase
end
endmodule
