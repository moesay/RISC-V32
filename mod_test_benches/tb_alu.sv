import types::*;
module tb_alu();

logic [31:0] i_a;
logic [31:0] i_b;
logic [31:0] o_result;
logic o_zero;
alu_op_e i_aluCtrl;

alu dut(
    .i_a(i_a),
    .i_b(i_b),
    .o_result(o_result),
    .i_aluCtrl(i_aluCtrl),
    .o_zero(o_zero));

task automatic check(string msg, logic [31:0] a, logic [31:0] b, alu_op_e i_aluCtrl);
  #0.1;
  unique case (i_aluCtrl)
  ENUM_ALU_ADD:
      assert(o_result === a + b)
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_SUB:
      assert(o_result === a - b)
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_AND:
      assert(o_result === (a & b))
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_OR:
      assert(o_result === (a | b))
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_XOR:
      assert(o_result === (a ^ b))
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_SLL:
      assert(o_result === (a << b[4:0]))
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_SRL:
      assert(o_result === (a >> b[4:0]))
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_SRA:
      assert(o_result === $signed(a) >>> b[4:0])
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_SLT:
      assert(o_result === (($signed(a) < $signed(b)) ? 32'd1 : 32'd0));
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_SLTU:
      assert(o_result === ((a < b) ? 32'd1 : 32'd0))
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  default:  o_result = 32'b0;
endcase
endtask;

initial begin
  i_a = 25;
  i_b = 10;
  i_aluCtrl = ENUM_ALU_ADD;
  check("ADD", i_a, i_b, i_aluCtrl);
  i_aluCtrl = ENUM_ALU_SUB;
  check("SUB", i_a, i_b, i_aluCtrl);
  i_aluCtrl = ENUM_ALU_SRL;
  check("SRL", i_a, i_b, i_aluCtrl);
end

endmodule;
