`timescale 1ns/1ps
import types::*;

module tb_decoder;

    logic [31:0] inst;

    logic regWrite;
    logic memRead;
    logic memWrite;
    logic branch;
    logic jump;
    logic aluSrcImm;
    logic jalr;
    logic [2:0] funct3;
    alu_op_e aluOp;
    imm_type_e immType;

    decoder dut (
        .inst(inst),
        .regWrite(regWrite),
        .memRead(memRead),
        .memWrite(memWrite),
        .branch(branch),
        .jump(jump),
        .jalr(jalr),
        .funct3(funct3),
        .aluSrcImm(aluSrcImm),
        .aluOp(aluOp),
        .immType(immType)
    );

    initial begin
        $display("=== Decoder Testbench Start ===");

        // ADDI x1, x0, 5
        inst = 32'h00500093;
        #1;
        $display("ADDI: regWrite=%0d aluSrcImm=%0d aluOp=%0d immType=%0d",
                  regWrite, aluSrcImm, aluOp, immType);

        // ADD x3, x1, x2
        inst = 32'h002081B3;
        #1;
        $display("ADD:  regWrite=%0d aluSrcImm=%0d aluOp=%0d immType=%0d",
                  regWrite, aluSrcImm, aluOp, immType);

        // SW x2, 8(x3)
        inst = 32'h0021A423;
        #1;
        $display("SW:   memWrite=%0d aluSrcImm=%0d aluOp=%0d immType=%0d",
                  memWrite, aluSrcImm, aluOp, immType);

        // BEQ x1, x2, +16
        inst = 32'h00208663;
        #1;
        $display("BEQ:  branch=%0d aluOp=%0d immType=%0d",
                  branch, aluOp, immType);

        // JAL x1, +32
        inst = 32'h020000EF;
        #1;
        $display("JAL:  jump=%0d regWrite=%0d immType=%0d",
                  jump, regWrite, immType);

        // LUI x5, 0x12345
        inst = 32'h123450B7;
        #1;
        $display("LUI:  regWrite=%0d aluSrcImm=%0d immType=%0d",
                  regWrite, aluSrcImm, immType);

        $display("=== Decoder Testbench Done ===");
        $finish;
    end

endmodule
