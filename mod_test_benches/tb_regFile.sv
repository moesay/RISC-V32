`timescale 1ns/1ps

module tb_regFile();

    logic i_clk, i_regWrite;
    logic [4:0] i_regSelect1, i_regSelect2, i_writeRegSelect;
    logic [31:0] i_dataIn, o_dataOut1, o_dataOut2;

    //F = 1 GHz
    always #1 i_clk = ~i_clk;

    regFile dut(
        .i_clk(i_clk),
        .i_regWrite(i_regWrite),
        .i_regSelect1(i_regSelect1),
        .i_regSelect2(i_regSelect2),
        .i_writeRegSelect(i_writeRegSelect),
        .i_dataIn(i_dataIn),
        .o_dataOut1(o_dataOut1),
        .o_dataOut2(o_dataOut2)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_regFile);
    end

    task writeReg(input [4:0] regnum, input [31:0] value);
        begin
            i_writeRegSelect = regnum;
            i_dataIn = value;
            i_regWrite = 1;
            @(posedge i_clk); // wait for clock edge to write
            // keep i_regWrite high for extra 1 ps, a setup-and-hold hack
            #0.001;
            i_regWrite = 0;
        end
    endtask

    task checkReg(input [4:0] regnum, input [31:0] expected);
        begin
            i_regSelect1 = regnum;
            #0.001; // a wait for the com-logic to read
            assert (o_dataOut1 == expected)
                else $error("Register x%0d mismatch: got %0d, expected %0d",
                            regnum, o_dataOut1, expected);
        end
    endtask

    initial begin
        i_clk = 0; i_regWrite = 1'bx;
        i_regSelect1 = 0; i_regSelect2 = 0; i_writeRegSelect = 0; i_dataIn = 0;

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
