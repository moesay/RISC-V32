// RV32I
parameter ALU_ADD = 16'h0;
parameter ALU_SUB = 16'h1;
parameter ALU_AND = 16'h2;
parameter ALU_OR = 16'h3;
parameter ALU_XOR = 16'h4;
parameter ALU_SLL = 16'h5;
parameter ALU_SRL = 16'h6;
parameter ALU_SRA = 16'h7;
parameter ALU_SLT = 16'h8;
parameter ALU_SLTU = 16'h9;

// RV32M
parameter ALU_MUL = 16'hA;
parameter ALU_MULH = 16'hB;
parameter ALU_MULHSU = 16'hC;
parameter ALU_MULHU = 16'hD;
parameter ALU_DIV = 16'hE;
parameter ALU_DIVU = 16'hF;
parameter ALU_REM = 16'h10;
parameter ALU_REMU = 16'h11;


// MISC
parameter ALU_A_PASSTHROUGH = 16'hFD;
parameter ALU_B_PASSTHROUGH = 16'hFE;

parameter ALU_NOP = 16'hFF;


parameter IMM_NONE = 3'h0;
parameter IMM_I = 3'h1;
parameter IMM_S = 3'h2;
parameter IMM_B = 3'h3;
parameter IMM_U = 3'h4;
parameter IMM_J = 3'h5;
