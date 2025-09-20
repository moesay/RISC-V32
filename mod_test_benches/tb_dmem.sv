`timescale 1ns/1ps
module tb_dmem();

logic i_clk;
logic i_memRead;
logic i_memWrite;
logic [31:0] i_addr;
logic [31:0] i_dataIn;
logic [31:0] o_dataOut;
logic [2:0] i_funct3;


always #1 assign i_clk = ~i_clk;

dmem#(.MEM_SIZE_KB(1)) dut
(
    .i_clk(i_clk),
    .i_memRead(i_memRead),
    .i_memWrite(i_memWrite),
    .i_addr(i_addr),
    .i_funct3(i_funct3),
    .i_dataIn(i_dataIn),
    .o_dataOut(o_dataOut)
);

task automatic writeToMemory(logic [31:0] pi_addr, logic[31:0] pData);
begin
    i_addr = pi_addr;
    i_funct3 = 3'h2;
    i_dataIn = pData;
    i_memWrite = 1;
    @(posedge i_clk)
    #0.001;
    i_memWrite = 0;
end
endtask

task automatic memCheck(logic [31:0] pi_addr, logic[31:0] pExcpData);
begin
    i_addr = pi_addr;
    i_memRead = 1;
    #0.001;
    i_memRead = 0;
    assert(pExcpData == o_dataOut)
    else
        $error("Error reading from %h, expected %h, got %h", pi_addr, pExcpData, o_dataOut);
end
endtask

initial begin
    writeToMemory(32'h8, 10);
    memCheck(32'h8, 10);

    writeToMemory(32'hC, 102);
    memCheck(32'hC, 102);

    writeToMemory(32'h33242344, 233);
    memCheck(32'h33242344, 233);

    writeToMemory(32'h100, 113);
    memCheck(32'h100, 113);

    writeToMemory(32'h1212, 443);
    memCheck(32'h1212, 443);

    $finish;
end
endmodule;
