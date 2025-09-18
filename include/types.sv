// Mirrored from params.vh since the testbenches are written in SV
// so why not making use of some SV fancy features?
// Not the best things to do but, anyways
package types;
typedef enum logic [2:0]
{
    ENUM_IMM_NONE,
    ENUM_IMM_I,
    ENUM_IMM_S,
    ENUM_IMM_B,
    ENUM_IMM_U,
    ENUM_IMM_J
} imm_type_e;

typedef enum logic [3:0]
{
    ENUM_ALU_ADD, ENUM_ALU_SUB, ENUM_ALU_AND, ENUM_ALU_OR, ENUM_ALU_XOR,
    ENUM_ALU_SLL, ENUM_ALU_SRL, ENUM_ALU_SRA,
    ENUM_ALU_SLT, ENUM_ALU_SLTU, ENUM_ALU_A_PASSTHROUGH,
    ENUM_ALU_B_PASSTHROUGH, ENUM_ALU_NOP = 4'hF
} alu_op_e;

endpackage
