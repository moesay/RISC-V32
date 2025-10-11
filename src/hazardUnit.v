`timescale 1ns/1ps

module hazardUnit (
  // From ID stage
  input logic [4:0] id_rs1,
  input logic [4:0] id_rs2,
  input logic id_branch,
  input logic id_jalr,

  // From ID/EX pipeline register
  input logic id_ex_memRead,
  input logic [4:0] id_ex_rd,

  // From EX/MEM pipeline register
  input logic ex_mem_memRead,
  input logic [4:0] ex_mem_rd,

  // Control flow decisions
  input logic branch_taken_id,   // Branch/JAL taken in ID
  input logic jalr_taken_ex,     // JALR taken in EX

  // Hazard outputs
  output logic o_if_stall,
  output logic o_id_stall,
  output logic o_if_flush,
  output logic o_id_flush,
  output logic o_ex_flush
);

// Load-use hazard detection
// Stall if current instruction in ID needs data from a load in EX
wire load_use_hazard = id_ex_memRead && (id_ex_rd != 0) &&
                       ((id_ex_rd == id_rs1) || (id_ex_rd == id_rs2));

// JALR data hazard - JALR needs rs1 but it's being loaded
wire jalr_load_hazard = id_jalr && id_ex_memRead && (id_ex_rd != 0) &&
                        (id_ex_rd == id_rs1);

// Branch data hazard - Branch needs comparison but data is being loaded
wire branch_load_hazard = id_branch && id_ex_memRead && (id_ex_rd != 0) &&
                          ((id_ex_rd == id_rs1) || (id_ex_rd == id_rs2));

// Stall logic
assign o_if_stall = load_use_hazard || jalr_load_hazard || branch_load_hazard;
// assign o_id_stall = load_use_hazard || jalr_load_hazard || branch_load_hazard;
assign o_id_stall = 1'b0;

// Flush logic
// When branch/JAL is taken in ID, flush IF/ID
// When JALR is taken in EX, flush both IF/ID and ID/EX
assign o_if_flush = branch_taken_id || jalr_taken_ex;
assign o_id_flush = branch_taken_id || jalr_taken_ex;
assign o_ex_flush = jalr_taken_ex;

endmodule
