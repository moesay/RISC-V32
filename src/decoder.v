// Reference
//http://cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf
`timescale 1ns/1ps
module decoder(
  input  logic [31:0] i_inst,
  output logic o_regWrite,
  output logic o_memRead,
  output logic o_memWrite,
  output logic o_branch,
  output logic o_jump,
  output logic o_aluSrcImm,
  output wire [2:0] o_funct3,
  output wire o_jalr,
  output logic [15:0] o_aluOp,
  output reg [2:0] o_immType
);

`include "params.vh"
wire [6:0] opcode;
wire [6:0] funct7;

assign opcode = i_inst[6:0];
assign o_funct3 = i_inst[14:12];
assign funct7 = i_inst[31:25];
assign o_jalr = (i_inst[6:0] == 7'b1100111);

always @(*) begin
  //init vals
  o_regWrite  = 0;
  o_memRead   = 0;
  o_memWrite  = 0;
  o_branch    = 0;
  o_jump      = 0;
  o_aluSrcImm = 0;
  o_aluOp     = ALU_NOP;
  o_immType   = IMM_NONE;

  case (opcode)

    // R type i_inst
    7'b0110011: begin
      o_regWrite  = 1;
      o_immType   = IMM_NONE;
      o_aluSrcImm = 0;
      case (o_funct3)
        3'b000:
          case(funct7)
            7'h0: o_aluOp = ALU_ADD;
            7'h1: o_aluOp = ALU_MUL;
            7'h20: o_aluOp = ALU_SUB;
            default: o_aluOp = ALU_NOP;
          endcase
        3'b001:
          case(funct7)
            7'h0: o_aluOp = ALU_SLL;
            7'h1: o_aluOp = ALU_MULH;
            default: o_aluOp = ALU_NOP;
          endcase
        3'b010:
          case(funct7)
            7'h0: o_aluOp = ALU_SLT;
            7'h1: o_aluOp = ALU_MULHSU;
            default: o_aluOp = ALU_NOP;
          endcase
        3'b011:
          case(funct7)
            7'h0: o_aluOp = ALU_SLTU;
            7'h1: o_aluOp = ALU_MULHU;
            default: o_aluOp = ALU_NOP;
          endcase
        3'b100:
            case(funct7)
                7'h0: o_aluOp = ALU_XOR;
                7'h1: o_aluOp = ALU_DIV;
                default: o_aluOp = ALU_NOP;
            endcase
        3'b101:
            case(funct7)
                7'h0: o_aluOp = ALU_SRL;
                7'h1: o_aluOp = ALU_DIVU;
                7'h20: o_aluOp = ALU_SRA;
                default: o_aluOp = ALU_NOP;
            endcase
        3'b110:
            case(funct7)
                7'h0: o_aluOp = ALU_OR;
                7'h1: o_aluOp = ALU_REM;
                default: o_aluOp = ALU_NOP;
            endcase
        3'b111:
            case(funct7)
                7'h0: o_aluOp = ALU_AND;
                7'h1: o_aluOp = ALU_REMU;
                default: o_aluOp = ALU_NOP;
            endcase
      endcase
    end

    // I type
    7'b0010011: begin
      o_regWrite  = 1;
      o_aluSrcImm = 1;
      o_immType   = IMM_I;
      case (o_funct3)
        3'b000: o_aluOp = ALU_ADD; // ADDI
        3'b010: o_aluOp = ALU_SLT; // SLTI
        3'b011: o_aluOp = ALU_SLTU;// SLTIU
        3'b100: o_aluOp = ALU_XOR; // XORI
        3'b110: o_aluOp = ALU_OR;  // ORI
        3'b111: o_aluOp = ALU_AND; // ANDI
        3'b001: o_aluOp = ALU_SLL; // SLLI
        3'b101: o_aluOp = (funct7 == 7'h20) ? ALU_SRA : ALU_SRL;
      endcase
    end

    // loads
    7'b0000011: begin
      o_regWrite  = 1;
      o_memRead   = 1;
      o_aluSrcImm = 1;
      o_immType   = IMM_I;
      o_aluOp     = ALU_ADD; // addr = base + offset
    end

    // store
    7'b0100011: begin
      o_memWrite  = 1;
      o_aluSrcImm = 1;
      o_immType   = IMM_S;
      o_aluOp     = ALU_ADD; // addr = base + offset
    end

    // o_branching
    7'b1100011: begin
      o_branch    = 1;
      o_immType   = IMM_B;
      o_aluSrcImm = 0;
      o_aluOp     = ALU_SUB; // for comparison
    end

    // o_jumps
    7'b1101111: begin // JAL
    o_jump      = 1;
    o_regWrite  = 1;
    o_immType   = IMM_J;
    end
    7'b1100111: begin // o_jalr
    o_jump      = 1;
    o_regWrite  = 1;
    o_aluSrcImm = 1;
    o_immType   = IMM_I;
    end

    // lui
    7'b0110111: begin
    o_regWrite  = 1;
    o_aluSrcImm = 1;
    o_immType   = IMM_U;
    o_aluOp     = ALU_B_PASSTHROUGH; // ie imm << 12
    end

    7'b0010111: begin // AUIPC
    o_regWrite  = 1;
    o_aluSrcImm = 1;
    o_immType   = IMM_U;
    o_aluOp     = ALU_ADD; // PC + imm
    end

    default: begin
    // Unknown opcode
    end
  endcase
end
endmodule
