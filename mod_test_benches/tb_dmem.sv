`timescale 1ns/1ps
module tb_dmem();

logic clk;
logic memRead;
logic memWrite;
logic [31:0] addr;
logic [31:0] writeData;
logic [31:0] readData;
logic [2:0] funct3;


always #1 assign clk = ~clk;

dmem#(.MEM_SIZE_KB(1)) dut
(
    .clk(clk),
    .memRead(memRead),
    .memWrite(memWrite),
    .addr(addr),
    .funct3(funct3),
    .writeData(writeData),
    .readData(readData)
);

task automatic writeToMemory(logic [31:0] pAddr, logic[31:0] pData);
begin
    addr = pAddr;
    funct3 = 3'h2;
    writeData = pData;
    memWrite = 1;
    @(posedge clk)
    #0.001;
    memWrite = 0;
end
endtask

task automatic memCheck(logic [31:0] pAddr, logic[31:0] pExcpData);
begin
    addr = pAddr;
    memRead = 1;
    #0.001;
    memRead = 0;
    assert(pExcpData == readData)
    else
        $error("Error reading from %h, expected %h, got %h", pAddr, pExcpData, readData);
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
