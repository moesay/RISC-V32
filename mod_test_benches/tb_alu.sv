import types::*;
module tb_alu();

logic [31:0] a;
logic [31:0] b;
logic [31:0] result;
logic zero;
alu_op_e aluCtrl;

alu dut(
    .a(a),
    .b(b),
    .result(result),
    .aluCtrl(aluCtrl),
    .zero(zero));

task automatic check(string msg, logic [31:0] a, logic [31:0] b, alu_op_e aluCtrl);
  #0.1;
  unique case (aluCtrl)
  ENUM_ALU_ADD:
      assert(result === a + b)
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_SUB:
      assert(result === a - b)
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_AND:
      assert(result === (a & b))
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_OR:
      assert(result === (a | b))
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_XOR:
      assert(result === (a ^ b))
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_SLL:
      assert(result === (a << b[4:0]))
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_SRL:
      assert(result === (a >> b[4:0]))
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_SRA:
      assert(result === $signed(a) >>> b[4:0])
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_SLT:
      assert(result === (($signed(a) < $signed(b)) ? 32'd1 : 32'd0));
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  ENUM_ALU_SLTU:
      assert(result === ((a < b) ? 32'd1 : 32'd0))
      else $error("%s FAILED. Parameters are a = %h, b = %h", msg, a, b);
  default:  result = 32'b0;
endcase
endtask;

initial begin
  a = 25;
  b = 10;
  aluCtrl = ENUM_ALU_ADD;
  check("ADD", a, b, aluCtrl);
  aluCtrl = ENUM_ALU_SUB;
  check("SUB", a, b, aluCtrl);
  aluCtrl = ENUM_ALU_SRL;
  check("SRL", a, b, aluCtrl);
end

endmodule;
