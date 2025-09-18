`timescale 1ns/1ps
import types::*;

module tb_immGen;
logic [31:0] inst;
imm_type_e   immType;
logic [31:0] immOut;

immGen dut (
  .inst (inst),
  .immType (immType),
  .immOut (immOut)
  );

  // I-type: imm[11:0] -> inst[31:20]
  function automatic [31:0] make_I (int signed val);
    logic [31:0] i = '0;
    logic signed [11:0] imm12 = val[11:0];
    i[31:20] = imm12;
    return i;
  endfunction

  // S-type: imm[11:5]->[31:25], imm[4:0]->[11:7]
  function automatic [31:0] make_S (int signed val);
    logic [31:0] i = '0;
    logic signed [11:0] imm12 = val[11:0];
    i[31:25] = imm12[11:5];
    i[11:7]  = imm12[4:0];
    return i;
  endfunction

  // B-type (even offsets): {imm[12],[10:5],[4:1],0} -> { [31],[30:25],[11:8],0 } with imm[11]->[7]
  function automatic [31:0] make_B (int signed val);
    logic [31:0] i = '0;
    logic signed [12:0] imm13 = val[12:0]; // LSB must be 0
    i[31]    = imm13[12];
    i[7]     = imm13[11];
    i[30:25] = imm13[10:5];
    i[11:8]  = imm13[4:1];
    return i;
  endfunction

  // U-type: imm[31:12] << 12 -> inst[31:12]
  function automatic [31:0] make_U (logic [31:0] val);
    logic [31:0] i = '0;
    i[31:12] = val[31:12]; // low 12 should be zero in 'val'
    return i;
  endfunction

  // J-type (even offsets): {imm[20],[10:1],imm[11],[19:12],0} -> {[31],[30:21],[20],[19:12],0}
  function automatic [31:0] make_J (int signed val);
    logic [31:0] i = '0;
    logic signed [20:0] imm21 = val[20:0]; // LSB must be 0
    i[31]    = imm21[20];
    i[19:12] = imm21[19:12];
    i[20]    = imm21[11];
    i[30:21] = imm21[10:1];
    return i;
  endfunction

  task automatic check(input logic [31:0] expected, input string name);
    #0.1; // wait for comb. logic
    assert (immOut === expected)
    else $error("[%0t] %s FAILED: got %h, expected %h", $time, name, immOut, expected);
    $display("[%0t] %s PASSED (immOut=%h)", $time, name, immOut);
  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_immGen);
  end

  initial begin
    inst = make_I( 5);
    immType = ENUM_IMM_I;
    check(32'h5, "I +5");

    inst = make_I(-8);
    immType = ENUM_IMM_I;
    check(32'hFFFF_FFF8, "I -8");

    inst = make_S( 20);
    immType = ENUM_IMM_S;
    check(32'h14, "S +20");

    inst = make_S(-16);
    immType = ENUM_IMM_S;
    check(32'hFFFF_FFF0, "S -16");

    inst = make_B( 16);
    immType = ENUM_IMM_B;
    check(32'h10, "B +16");

    inst = make_B( -4);
    immType = ENUM_IMM_B;
    check(32'hFFFF_FFFC, "B -4");

    inst = make_U(32'h1234_5000);
    immType = ENUM_IMM_U;
    check(32'h1234_5000, "U 0x12345000");

    inst = make_J( 2048);
    immType = ENUM_IMM_J;
    check(32'h800, "J +2048");

    inst = make_J(-2048);
    immType = ENUM_IMM_J;
    check(32'hFFFF_F800, "J -2048");

    inst = 32'hDEAD_BEEF;
    immType = ENUM_IMM_NONE;
    check(32'h0, "NONE -> 0");

    $display("All tests completed");
    $finish;
  end
  endmodule
