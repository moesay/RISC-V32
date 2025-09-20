`timescale 1ns/1ps
import types::*;

module tb_decoder;

    logic [31:0] i_inst;

    logic o_regWrite;
    logic o_memRead;
    logic o_memWrite;
    logic o_branch;
    logic o_jump;
    logic o_aluSrcImm;
    logic o_jalr;
    logic [2:0] o_i_funct3;
    alu_op_e o_aluOp;
    imm_type_e o_immType;

    decoder dut (
        .i_inst(i_inst),
        .o_regWrite(o_regWrite),
        .o_memRead(o_memRead),
        .o_memWrite(o_memWrite),
        .o_branch(o_branch),
        .o_jump(o_jump),
        .o_jalr(o_jalr),
        .o_i_funct3(o_i_funct3),
        .o_aluSrcImm(o_aluSrcImm),
        .o_aluOp(o_aluOp),
        .o_immType(o_immType)
    );

    initial begin
        $display("=== Decoder Testbench Start ===");

        // ADDI x1, x0, 5
        i_inst = 32'h00500093;
        #1;
        $display("ADDI: o_regWrite=%0d o_aluSrcImm=%0d o_aluOp=%0d o_immType=%0d",
                  o_regWrite, o_aluSrcImm, o_aluOp, o_immType);

        // ADD x3, x1, x2
        i_inst = 32'h002081B3;
        #1;
        $display("ADD:  o_regWrite=%0d o_aluSrcImm=%0d o_aluOp=%0d o_immType=%0d",
                  o_regWrite, o_aluSrcImm, o_aluOp, o_immType);

        // SW x2, 8(x3)
        i_inst = 32'h0021A423;
        #1;
        $display("SW:   o_memWrite=%0d o_aluSrcImm=%0d o_aluOp=%0d o_immType=%0d",
                  o_memWrite, o_aluSrcImm, o_aluOp, o_immType);

        // BEQ x1, x2, +16
        i_inst = 32'h00208663;
        #1;
        $display("BEQ:  o_branch=%0d o_aluOp=%0d o_immType=%0d",
                  o_branch, o_aluOp, o_immType);

        // JAL x1, +32
        i_inst = 32'h020000EF;
        #1;
        $display("JAL:  o_jump=%0d o_regWrite=%0d o_immType=%0d",
                  o_jump, o_regWrite, o_immType);

        // LUI x5, 0x12345
        i_inst = 32'h123450B7;
        #1;
        $display("LUI:  o_regWrite=%0d o_aluSrcImm=%0d o_immType=%0d",
                  o_regWrite, o_aluSrcImm, o_immType);

        $display("=== Decoder Testbench Done ===");
        $finish;
    end

endmodule
