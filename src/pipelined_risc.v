`timescale 1ns/1ps

module pipelined_risc(
input logic clk,
input logic reset
);

`include "params.vh"

// ============= Pipeline Registers =============
// IF/ID
reg [31:0] if_id_pc;
reg [31:0] if_id_inst;
reg if_id_valid;

// ID/EX
reg [31:0] id_ex_pc;
reg id_ex_regWrite;
reg id_ex_memRead;
reg id_ex_memWrite;
reg id_ex_branch;
reg id_ex_jal;
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

// EX/MEM
reg ex_mem_regWrite;
reg ex_mem_memRead;
reg ex_mem_memWrite;
reg [2:0] ex_mem_funct3;
reg [31:0] ex_mem_aluResult;
reg [31:0] ex_mem_rs2Data;
reg [4:0] ex_mem_rd;
reg ex_mem_valid;

// MEM/WB
reg mem_wb_regWrite;
reg [31:0] mem_wb_aluResult;
reg [31:0] mem_wb_memReadData;
reg [4:0] mem_wb_rd;
reg mem_wb_memRead;
reg mem_wb_valid;

// ============= Internal Wires =============
wire [31:0] pc_current;
wire [31:0] pc_next;
wire [31:0] inst_from_imem;

// Hazard control signals
wire if_stall, id_stall;
wire if_flush, id_flush, ex_flush;

// Jump/Branch resolution signals
wire branch_taken_id, jalr_taken_ex;
wire [31:0] jump_target_id, jalr_target_ex;
wire [31:0] link_addr_id, link_addr_ex;

// ============= IF Stage =============
// PC selection logic
assign pc_next = jalr_taken_ex ? jalr_target_ex :      // JALR has priority (from EX)
                 branch_taken_id ? jump_target_id :     // Branch/JAL (from ID)
                 if_stall ? pc_current :                // Stall
                 pc_current + 32'd4;                    // Normal increment

pc pcMod (
  .i_clk(clk),
  .i_reset(reset),
  .i_nextPC(pc_next),
  .o_addr(pc_current)
);

imem#(.MEM_SIZE_KB(2)) iMemMod (
  .i_pc(pc_current),
  .o_inst(inst_from_imem)
);

// IF/ID Pipeline Register
always @(posedge clk or posedge reset) begin
  if (reset || if_flush) begin
    if_id_pc <= 32'h0;
    if_id_inst <= 32'h00000013;  // NOP (addi x0, x0, 0)
    if_id_valid <= 1'b0;
  end else if (~if_stall) begin
    if_id_pc <= pc_current;
    if_id_inst <= inst_from_imem;
    if_id_valid <= 1'b1;
  end
end

// ============= ID Stage =============
// Decode signals
wire regWrite_dec, memRead_dec, memWrite_dec, auipc_dec;
wire branch_dec, jump_dec, jalr_dec, aluSrcImm_dec;
wire [2:0] funct3_dec;
wire [15:0] aluOp_dec;
wire [2:0] immType_dec;

decoder decoderMod (
  .i_inst(if_id_inst),
  .o_regWrite(regWrite_dec),
  .o_memRead(memRead_dec),
  .o_memWrite(memWrite_dec),
  .o_branch(branch_dec),
  .o_auipc(auipc_dec),
  .o_jump(jump_dec),
  .o_jalr(jalr_dec),
  .o_aluSrcImm(aluSrcImm_dec),
  .o_funct3(funct3_dec),
  .o_aluOp(aluOp_dec),
  .o_immType(immType_dec)
);

// Extract register addresses
wire [4:0] rs1_addr = if_id_inst[19:15];
wire [4:0] rs2_addr = if_id_inst[24:20];
wire [4:0] rd_addr = if_id_inst[11:7];

// Immediate generation
wire [31:0] imm_value;
immGen immGenMod (
  .i_inst(if_id_inst),
  .i_immType(immType_dec),
  .o_immOut(imm_value)
);

// Register file
wire [31:0] rs1_data, rs2_data;
wire [31:0] writeBackData = mem_wb_memRead ? mem_wb_memReadData : mem_wb_aluResult;

regFile regFileMod (
  .i_clk(clk),
  .i_regWrite(mem_wb_regWrite && mem_wb_valid),
  .i_regSelect1(rs1_addr),
  .i_regSelect2(rs2_addr),
  .i_writeRegSelect(mem_wb_rd),
  .i_dataIn(writeBackData),
  .o_dataOut1(rs1_data),
  .o_dataOut2(rs2_data)
);

// Forwarding for ID stage (for early branch resolution)
wire [31:0] rs1_forwarded_id, rs2_forwarded_id;
assign rs1_forwarded_id = (id_ex_regWrite && id_ex_rd != 0 && id_ex_rd == rs1_addr) ?
                          id_ex_aluOp == ALU_ADD ? (id_ex_rs1Data + id_ex_immVal) : 32'h0 :  // Simple forward
                          (ex_mem_regWrite && ex_mem_rd != 0 && ex_mem_rd == rs1_addr) ? ex_mem_aluResult :
                          (mem_wb_regWrite && mem_wb_rd != 0 && mem_wb_rd == rs1_addr) ? writeBackData :
                          rs1_data;

assign rs2_forwarded_id = (id_ex_regWrite && id_ex_rd != 0 && id_ex_rd == rs2_addr) ?
                          id_ex_aluOp == ALU_ADD ? (id_ex_rs1Data + id_ex_immVal) : 32'h0 :  // Simple forward
                          (ex_mem_regWrite && ex_mem_rd != 0 && ex_mem_rd == rs2_addr) ? ex_mem_aluResult :
                          (mem_wb_regWrite && mem_wb_rd != 0 && mem_wb_rd == rs2_addr) ? writeBackData :
                          rs2_data;

// Jump/Branch unit for ID stage (handles branches and JAL only)
jumpBranchUnit jbuID (
  .i_isBranch(branch_dec),
  .i_isJal(jump_dec && ~jalr_dec),  // JAL only, not JALR
  .i_isJalr(1'b0),                  // JALR handled in EX
  .i_funct3(funct3_dec),
  .i_pc(if_id_pc),
  .i_rs1(rs1_forwarded_id),
  .i_rs2(rs2_forwarded_id),
  .i_imm(imm_value),
  .o_take(branch_taken_id),
  .o_target(jump_target_id),
  .o_linkAddr(link_addr_id)
);

// ID/EX Pipeline Register
always @(posedge clk or posedge reset) begin
  if (reset || id_flush) begin
    id_ex_pc <= 32'h0;
    id_ex_regWrite <= 1'b0;
    id_ex_memRead <= 1'b0;
    id_ex_memWrite <= 1'b0;
    id_ex_branch <= 1'b0;
    id_ex_jal <= 1'b0;
    id_ex_jalr <= 1'b0;
    id_ex_aluSrcImm <= 1'b0;
    id_ex_funct3 <= 3'b0;
    id_ex_aluOp <= ALU_NOP;
    id_ex_rs1Data <= 32'b0;
    id_ex_rs2Data <= 32'b0;
    id_ex_immVal <= 32'b0;
    id_ex_rd <= 5'b0;
    id_ex_rs1 <= 5'b0;
    id_ex_rs2 <= 5'b0;
    id_ex_valid <= 1'b0;
  end else if (~id_stall) begin
    id_ex_pc <= if_id_pc;
    id_ex_regWrite <= regWrite_dec;
    id_ex_memRead <= memRead_dec;
    id_ex_memWrite <= memWrite_dec;
    id_ex_branch <= branch_dec;
    id_ex_jal <= jump_dec && ~jalr_dec;
    id_ex_jalr <= jalr_dec;
    id_ex_aluSrcImm <= aluSrcImm_dec;
    id_ex_funct3 <= funct3_dec;
    id_ex_aluOp <= aluOp_dec;
    id_ex_rs1Data <= rs1_data;
    id_ex_rs2Data <= rs2_data;
    id_ex_immVal <= imm_value;
    id_ex_rd <= rd_addr;
    id_ex_rs1 <= rs1_addr;
    id_ex_rs2 <= rs2_addr;
    id_ex_valid <= if_id_valid;
  end
end

// ============= EX Stage =============
// Forwarding logic for EX stage
wire [31:0] rs1_forwarded_ex, rs2_forwarded_ex;
assign rs1_forwarded_ex = (ex_mem_regWrite && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs1) ? ex_mem_aluResult :
                          (mem_wb_regWrite && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs1) ? writeBackData :
                          id_ex_rs1Data;

assign rs2_forwarded_ex = (ex_mem_regWrite && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs2) ? ex_mem_aluResult :
                          (mem_wb_regWrite && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs2) ? writeBackData :
                          id_ex_rs2Data;

// JALR handling in EX stage (needs forwarded rs1)
jumpBranchUnit jbuEX (
  .i_isBranch(1'b0),
  .i_isJal(1'b0),
  .i_isJalr(id_ex_jalr),
  .i_funct3(id_ex_funct3),
  .i_pc(id_ex_pc),
  .i_rs1(rs1_forwarded_ex),
  .i_rs2(32'h0),  // Not used for JALR
  .i_imm(id_ex_immVal),
  .o_take(jalr_taken_ex),
  .o_target(jalr_target_ex),
  .o_linkAddr(link_addr_ex)
);

// ALU operation
wire [31:0] alu_in1, alu_in2, alu_result;
wire alu_zero;

// ALU input selection
assign alu_in1 = (id_ex_jal || id_ex_jalr) ? id_ex_pc :           // PC for link address
                 (id_ex_aluOp == ALU_ADD && id_ex_aluSrcImm &&
                  id_ex_rd != 0 && ~id_ex_memRead && ~id_ex_memWrite && auipc_dec) ? id_ex_pc :  // AUIPC
                 rs1_forwarded_ex;

assign alu_in2 = (id_ex_jal || id_ex_jalr) ? 32'd4 :              // +4 for link address
                 id_ex_aluSrcImm ? id_ex_immVal :
                 rs2_forwarded_ex;

alu aluMod (
  .i_a(alu_in1),
  .i_b(alu_in2),
  .i_aluCtrl(id_ex_aluOp),
  .o_result(alu_result),
  .o_zero(alu_zero)
);

// EX/MEM Pipeline Register
always @(posedge clk or posedge reset) begin
  if (reset || ex_flush) begin
    ex_mem_regWrite <= 1'b0;
    ex_mem_memRead <= 1'b0;
    ex_mem_memWrite <= 1'b0;
    ex_mem_funct3 <= 3'b0;
    ex_mem_aluResult <= 32'b0;
    ex_mem_rs2Data <= 32'b0;
    ex_mem_rd <= 5'b0;
    ex_mem_valid <= 1'b0;
  end else begin
    ex_mem_regWrite <= id_ex_regWrite;
    ex_mem_memRead <= id_ex_memRead;
    ex_mem_memWrite <= id_ex_memWrite;
    ex_mem_funct3 <= id_ex_funct3;
    ex_mem_aluResult <= alu_result;
    ex_mem_rs2Data <= rs2_forwarded_ex;  // Forward for store data
    ex_mem_rd <= id_ex_rd;
    ex_mem_valid <= id_ex_valid;
  end
end

// ============= MEM Stage =============
wire [31:0] mem_read_data;
dmem#(.MEM_SIZE_KB(1)) dmemMod (
  .i_clk(clk),
  .i_memRead(ex_mem_memRead),
  .i_memWrite(ex_mem_memWrite),
  .i_addr(ex_mem_aluResult),
  .i_funct3(ex_mem_funct3),
  .i_dataIn(ex_mem_rs2Data),
  .o_dataOut(mem_read_data)
);

// MEM/WB Pipeline Register
always @(posedge clk or posedge reset) begin
  if (reset) begin
    mem_wb_regWrite <= 1'b0;
    mem_wb_aluResult <= 32'b0;
    mem_wb_memReadData <= 32'b0;
    mem_wb_memRead <= 1'b0;
    mem_wb_rd <= 5'b0;
    mem_wb_valid <= 1'b0;
  end else begin
    mem_wb_regWrite <= ex_mem_regWrite;
    mem_wb_aluResult <= ex_mem_aluResult;
    mem_wb_memReadData <= mem_read_data;
    mem_wb_rd <= ex_mem_rd;
    mem_wb_memRead <= ex_mem_memRead;
    mem_wb_valid <= ex_mem_valid;
  end
end

// ============= Hazard Detection =============
hazardUnit hazardMod (
  // From ID stage
  .id_rs1(rs1_addr),
  .id_rs2(rs2_addr),
  .id_branch(branch_dec),
  .id_jalr(jalr_dec),

  // From pipeline registers
  .id_ex_memRead(id_ex_memRead),
  .id_ex_rd(id_ex_rd),
  .ex_mem_memRead(ex_mem_memRead),
  .ex_mem_rd(ex_mem_rd),

  // Control decisions
  .branch_taken_id(branch_taken_id),
  .jalr_taken_ex(jalr_taken_ex),

  // Hazard outputs
  .o_if_stall(if_stall),
  .o_id_stall(id_stall),
  .o_if_flush(if_flush),
  .o_id_flush(id_flush),
  .o_ex_flush(ex_flush)
);

endmodule
