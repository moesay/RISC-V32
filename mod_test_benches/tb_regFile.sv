`timescale 1ns/1ps

module tb_regFile();

    logic clk, regWrite;
    logic [4:0] rs1, rs2, rd;
    logic [31:0] wd, rd1, rd2;

    //F = 1 GHz
    always #1 clk = ~clk;

    regFile dut(
        .clk(clk),
        .regWrite(regWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_regFile);
    end

    task writeReg(input [4:0] regnum, input [31:0] value);
        begin
            rd = regnum;
            wd = value;
            regWrite = 1;
            @(posedge clk); // wait for clock edge to write
            // keep regWrite high for extra 1 ps, a setup-and-hold hack
            #0.001;
            regWrite = 0;
        end
    endtask

    task checkReg(input [4:0] regnum, input [31:0] expected);
        begin
            rs1 = regnum;
            #0.001; // a wait for the com-logic to read
            assert (rd1 == expected)
                else $error("Register x%0d mismatch: got %0d, expected %0d",
                            regnum, rd1, expected);
        end
    endtask

    initial begin
        clk = 0; regWrite = 1'bx;
        rs1 = 0; rs2 = 0; rd = 0; wd = 0;

        $display("Test 1: x0 always 0");
        checkReg(0, 0);

        $display("Test 2: Write 42 to x5");
        writeReg(5, 42);
        checkReg(5, 42);

        $display("Test 3: Writing to x0 should have no effect");
        writeReg(0, 99);
        checkReg(0, 0);

        $display("Test 4: Write 100 to x10 and 200 to x15");
        writeReg(10, 100);
        writeReg(15, 200);
        checkReg(10, 100);
        checkReg(15, 200);

        $display("All tests passed!");
        $finish;
    end

endmodule
