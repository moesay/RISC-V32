`timescale 1ns/1ps

module hazardUnit (
  // from id stage
  input logic [4:0] id_rs1,
  input logic [4:0] id_rs2,
  input logic id_branch,
  input logic id_jalr,

  // from id/ex pipeline register
  input logic id_ex_memRead,
  input logic id_ex_regWrite,
  input logic [4:0] id_ex_rd,

  // from ex/mem pipeline register
  input logic ex_mem_memRead,
  input logic [4:0] ex_mem_rd,

  // control flow
  input logic branch_taken_id,   // branch/jal taken in id
  input logic jalr_taken_ex,     // jalr taken in ex

  output logic o_if_stall,
  output logic o_id_stall,
  output logic o_if_flush,
  output logic o_id_flush,
  output logic o_ex_flush
);

// load-use hazard detection for id/ex
// stall if current inst in id needs data from a load inst in ex
wire load_use_hazard_ex = id_ex_memRead && (id_ex_rd != 0) &&
                          ((id_ex_rd == id_rs1) || (id_ex_rd == id_rs2));


// jalr data hazard - jalr needs rs1 but its being loaded
wire jalr_load_hazard_ex = id_jalr && id_ex_memRead && (id_ex_rd != 0) &&
                           (id_ex_rd == id_rs1);

// branch data hazard - branch needs comparison but data is being loaded
wire branch_load_hazard_ex = id_branch && id_ex_memRead && (id_ex_rd != 0) &&
                             ((id_ex_rd == id_rs1) || (id_ex_rd == id_rs2));

wire branch_data_hazard_id_ex = (id_branch || id_jalr) &&
                                 id_ex_regWrite && (id_ex_rd != 0) &&
                                 ((id_ex_rd == id_rs1) || (id_ex_rd == id_rs2));

// stall logic - only stall when load is in EX stage
assign o_if_stall = load_use_hazard_ex ||
                    jalr_load_hazard_ex ||
                    branch_load_hazard_ex ||
                    branch_data_hazard_id_ex;

// disable if stalling for now
assign o_id_stall = 1'b0;

// flush logic:
// when branch/jal is taken in id, flush if/id
// when jalr is taken in ex, flush both if/id and id/ex

assign o_if_flush = branch_taken_id || jalr_taken_ex;
assign o_id_flush = branch_taken_id || jalr_taken_ex;
assign o_ex_flush = jalr_taken_ex;

endmodule
