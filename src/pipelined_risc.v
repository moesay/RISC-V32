`timescale 1ns/1ps

module pipelined_risc(
input logic clk,
input logic reset
);

`include "params.vh"

// regs for IF_ID
reg [31:0] if_id_pc;
reg [31:0] if_id_inst;

reg if_id_valid;

// regs for ID_EX
reg [31:0] id_ex_pc;
reg id_ex_regWrite;
reg id_ex_memRead;
reg id_ex_memWrite;
reg id_ex_branch;
reg id_ex_jump;
reg id_ex_jalr;
reg id_ex_aluSrcImm;
reg [2:0] id_ex_funct3;
reg [15:0] id_ex_aluOp;
reg [31:0] id_ex_rs1Data;
reg [31:0] id_ex_rs2Data;
reg [31:0] id_ex_immVal;
reg [4:0] id_ex_rd;
reg [4:0] id_ex_rs1;
reg [4:0] id_ex_rs2;
reg id_ex_valid;

// ex_mem regs
reg ex_mem_regWrite;
reg ex_mem_memRead;
reg ex_mem_memWrite;
reg [2:0] ex_mem_funct3;
reg [31:0] ex_mem_aluResult;
reg [31:0] ex_mem_rs2Data;
reg [4:0] ex_mem_rd;
reg [4:0] ex_mem_rs2;
reg em_mem_valid;

// mem_wb regs
reg mem_wb_regWrite;
reg [31:0] mem_wb_aluResult;
reg [31:0] mem_wb_memReadData;
reg [4:0] mem_wb_rd;
reg mem_wb_memRead;
reg mem_wb_valid;


// wiring
reg [31:0] pc_current;
reg [31:0] pc_plus4;
reg [31:0] inst_from_imem;

// control wires (id stage)
wire branch_taken_id;
wire [31:0] branch_target_id;
wire id_flush;
wire id_stall;
wire if_stall;

// pc new logic
assign pc_plus4 = pc_current + 32'h4;

// pc mux, excluding the increament logic out of the bu
wire [31:0] next_pc;
assign next_pc = (branch_taken_id) ? branch_target_id :
                 (if_stall) ? pc_current :
                 pc_plus4;

pc pcMod
(
  .i_clk(clk),
  .i_reset(reset),
  .i_nextPC(next_pc),
  .o_addr(pc_current)
);

// inst fetch

imem#(.MEM_SIZE_KB(2)) iMemMod
(
  .i_pc(pc_current),
  .o_inst(inst_from_imem)
);


// --- Hazard detection ---
// maybe in the furure, this will be a separate module
wire data_hazard;

assign data_hazard = 1'b0;

// if-id pipeline
always @(posedge clk or posedge reset)
begin
  if(reset)
    begin
      if_id_pc <= 32'h0;
      if_id_inst <= 32'h13; // 0x00000013 -> addi x0, x0, 0 (as a nop)
      if_id_valid <= 1'b0;
    end
  else if(id_flush) // do the same for a pipeline flushing
    begin
      if_id_pc <= 32'h0;
      if_id_inst <= 32'h13; // 0x00000013 -> addi x0, x0, 0 (as a nop)
      if_id_valid <= 1'b0;
    end

  else if(~id_stall) // if the cpu not at stall, execture normally
  begin
    if_id_pc <= pc_current;
    if_id_inst <= inst_from_imem;
    if_id_valid <= 1'b1;
  end
end

wire regWrite_dec;
wire memRead_dec;
wire memWrite_dec;
wire branch_dec;
wire jump_dec;
wire jalr_dec;
wire aluSrcImm_dec;
wire [2:0] funct3_dec;
wire [15:0] aluOp_dec;
wire [2:0] immType_dec;

// decoder wiring
decoder decoderMod
(
  .i_inst(if_id_inst),
  .o_regWrite(regWrite_dec),
  .o_memRead(memRead_dec),
  .o_memWrite(memWrite_dec),
  .o_branch(branch_dec),
  .o_jump(jump_dec),
  .o_aluSrcImm(aluSrcImm_dec),
  .o_jalr(jalr_dec),
  .o_funct3(funct3_dec),
  .o_aluOp(aluOp_dec),
  .o_immType(immType_dec)
);

wire [31:0] immVal_dec;
immGen immGenMod
(
  .i_inst(if_id_inst),
  .i_immType(immType_dec),
  .o_immOut(immVal_dec)
);

wire [4:0] rs1 = if_id_inst[19:15];
wire [4:0] rs2 = if_id_inst[24:20];
wire [4:0] rd_dec = if_id_inst[11:7];

wire [31:0] rs1Data_dec;
wire [31:0] rs2Data_dec;

// if the prev inst hasn't written back, we will have a data hazard.
// TODO: impl a hazard detection module

regFile regFileMod
(
  .i_clk(clk),
  .i_regWrite(mem_wb_regWrite),
  .i_regSelect1(rs1),
  .i_regSelect2(rs2),
  .i_writeRegSelect(mem_wb_rd),
  .i_dataIn(writeBackData), // from the writeback stage MUX
  .o_dataOut1(rs1Data_dec),
  .o_dataOut2(rs2Data_dec)
);

branchUnit_pipelined branchUnitMod (
  .i_isBranch(branch_dec),
  .i_isJal(jump_dec),
  .i_funct3(funct3_dec),
  .i_pc(if_id_pc),
  .i_rs1(rs1Data_dec),
  .i_rs2(rs2Data_dec),
  .i_imm(immVal_dec),
  .o_take(branch_taken_id),
  .o_target(branch_target_id)
);

// if the branch is taken, flush the id regs
assign id_flush = branch_taken_id;

// id-ex registers updating
always @(posedge clk or posedge reset)
begin
  if (reset || id_flush) begin
    // Reset all id/ex registers to zero (NOP)
    id_ex_regWrite <= 1'b0;
    id_ex_memRead <= 1'b0;
    id_ex_memWrite <= 1'b0;
    id_ex_aluSrcImm <= 1'b0;
    id_ex_funct3 <= 3'b0;
    id_ex_aluOp <= ALU_NOP;
    id_ex_rs1Data <= 32'b0;
    id_ex_rs2Data <= 32'b0;
    id_ex_immVal <= 32'b0;
    id_ex_rd <= 5'b0;
    id_ex_pc <= 32'b0;
    id_ex_rs1 <= 5'b0;
    id_ex_rs2 <= 5'b0;
  end else if (~id_stall) begin // only update if not stalled
    id_ex_regWrite <= regWrite_dec;
    id_ex_memRead <= memRead_dec;
    id_ex_memWrite <= memWrite_dec;
    id_ex_aluSrcImm <= aluSrcImm_dec;
    id_ex_funct3 <= funct3_dec;
    id_ex_aluOp <= aluOp_dec;
    id_ex_rs1Data <= rs1Data_dec;
    id_ex_rs2Data <= rs2Data_dec;
    id_ex_immVal <= immVal_dec;
    id_ex_rd <= rd_dec;
    id_ex_pc <= if_id_pc;
    id_ex_rs1 <= rs1;
    id_ex_rs2 <= rs2;
  end
end

// WAR hazard handeling
// https://stackoverflow.com/questions/60065175/how-does-data-forwarding-for-data-hazards-work-in-pipeline-diagrams
wire [1:0] forwardA, forwardB, forwardStoreData;
assign forwardA = (ex_mem_regWrite && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs1) ? 2'h2 :
                  (mem_wb_regWrite && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs1) ? 2'h1 : 2'h0;

assign forwardB = (ex_mem_regWrite && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs2) ? 2'h2 :
                  (mem_wb_regWrite && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs2) ? 2'h1 : 2'h0;

assign forwardStoreData = (ex_mem_regWrite && ex_mem_rd != 0 && ex_mem_rd == ex_mem_rs2) ? 2'h2 :
                          (mem_wb_regWrite && mem_wb_rd != 0 && mem_wb_rd == ex_mem_rs2) ? 2'h1 : 2'h0;

wire [31:0] aluIn1, aluIn2, aluResult, forwardedStoreData;

assign aluIn1 = (forwardA == 2'h2) ? ex_mem_aluResult :
                (forwardA == 2'h1) ? writeBackData : id_ex_rs1Data;

assign aluIn2 = (id_ex_aluSrcImm) ? id_ex_immVal :
                (forwardB == 2'h2) ? ex_mem_aluResult :
                (forwardB == 2'h1) ? writeBackData :
                (id_ex_aluSrcImm) ? id_ex_immVal : id_ex_rs2Data;

assign forwardedStoreData = (forwardStoreData == 2'h2) ? ex_mem_aluResult :
                            (forwardStoreData == 2'h1) ? writeBackData :
                            ex_mem_rs2Data;

wire zero;
alu alu0
(
  .i_a(aluIn1),
  .i_b(aluIn2),
  .i_aluCtrl(id_ex_aluOp),
  .o_result(aluResult),
  .o_zero(zero)
);

// ex/mem pipeline regs
always @(posedge clk or posedge reset)
begin
  if(reset) begin
    ex_mem_regWrite <= 1'b0;
    ex_mem_memRead <= 1'b0;
    ex_mem_memWrite <= 1'b0;
    ex_mem_funct3 <= 3'b0;
    ex_mem_aluResult <= 32'b0;
    ex_mem_rs2Data <= 32'b0;
    ex_mem_rd <= 5'b0;
    ex_mem_rs2 <= 5'b0;
  end else begin
    ex_mem_regWrite <= id_ex_regWrite;
    ex_mem_memRead <= id_ex_memRead;
    ex_mem_memWrite <= id_ex_memWrite;
    ex_mem_funct3 <= id_ex_funct3;
    ex_mem_aluResult <= aluResult;
    ex_mem_rs2Data <= id_ex_rs2Data; // data in
    ex_mem_rd <= id_ex_rd;
    ex_mem_rs2 <= id_ex_rs2;
  end
end

// memory section
wire [31:0] mem_read_data;
dmem#(.MEM_SIZE_KB(1)) dmemMod
(
  .i_clk(clk),
  .i_memRead(ex_mem_memRead),
  .i_memWrite(ex_mem_memWrite),
  .i_addr(ex_mem_aluResult),
  .i_funct3(ex_mem_funct3),
  .i_dataIn(forwardedStoreData), // maybe i will mux this
  .o_dataOut(mem_read_data)
);

// mem/wb registers
always @(posedge clk or posedge reset)
begin
  if(reset) begin
    mem_wb_regWrite <= 1'b0;
    mem_wb_aluResult <= 32'b0;
    mem_wb_memReadData <= 32'b0;
    mem_wb_memRead <= 1'b0;
    mem_wb_rd <= 5'b0;
  end else begin
    mem_wb_regWrite <= ex_mem_regWrite;
    mem_wb_aluResult <= ex_mem_aluResult;
    mem_wb_memReadData <= mem_read_data;
    mem_wb_rd <= ex_mem_rd;
    mem_wb_memRead <= ex_mem_memRead;
  end
end

// writeback
wire [31:0] writeBackData;
assign writeBackData = (mem_wb_memRead ? mem_wb_memReadData : mem_wb_aluResult);

// will be enabled later after implementing the hazard detection
assign if_stall = data_hazard;
assign id_stall = data_hazard;
endmodule
