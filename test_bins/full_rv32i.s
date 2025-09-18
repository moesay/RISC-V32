# Comprehensive RV32I Test
# x10 = success indicator (1 = all tests passed)
# x1 = return address (preserved in all test functions)

_start:
    addi x10, x0, 0

    # -----------------------------------------------------------------
    # 1. ARITHMETIC INSTRUCTIONS
    # -----------------------------------------------------------------
    jal x1, test_arithmetic
    bne x0, x30, test_fail  # If x1 != 0, arithmetic tests failed

    # -----------------------------------------------------------------
    # 2. LOGICAL INSTRUCTIONS
    # -----------------------------------------------------------------
    jal x1, test_logical
    bne x0, x30, test_fail

    # -----------------------------------------------------------------
    # 3. SHIFT INSTRUCTIONS
    # -----------------------------------------------------------------
    jal x1, test_shift
    bne x0, x30, test_fail

    # -----------------------------------------------------------------
    # 4. COMPARE INSTRUCTIONS
    # -----------------------------------------------------------------
    jal x1, test_compare
    bne x0, x30, test_fail

    # -----------------------------------------------------------------
    # 5. LOAD/STORE INSTRUCTIONS
    # -----------------------------------------------------------------
    jal x1, test_memory
    bne x0, x30, test_fail

    # -----------------------------------------------------------------
    # 6. BRANCH INSTRUCTIONS
    # -----------------------------------------------------------------
    jal x1, test_branch
    bne x0, x30, test_fail

    # -----------------------------------------------------------------
    # 7. JUMP INSTRUCTIONS
    # -----------------------------------------------------------------
    jal x1, test_jump
    bne x0, x30, test_fail

    # -----------------------------------------------------------------
    # 8. U-TYPE INSTRUCTIONS (LUI/AUIPC)
    # -----------------------------------------------------------------
    jal x1, test_utype
    bne x0, x30, test_fail

    # All tests passed!
    addi x10, x0, 1
    j test_end

test_fail:
    addi x10, x0, 0
    j test_end

# ==================== TEST SUBROUTINES ====================
# All test functions preserve x1 (return address)
# Use x5-x15 for temporary calculations

test_arithmetic:
    addi x5, x0, 5        # x5 = 5
    addi x6, x0, 10       # x6 = 10
    add x7, x5, x6        # x7 = 15
    addi x8, x0, 15
    bne x7, x8, arith_fail

    sub x7, x6, x5        # x7 = 5
    addi x8, x0, 5
    bne x7, x8, arith_fail

    # Test negative values
    addi x5, x0, -5       # x5 = -5
    addi x6, x0, 10       # x6 = 10
    add x7, x5, x6        # x7 = 5
    addi x8, x0, 5
    bne x7, x8, arith_fail

    sub x7, x5, x6        # x7 = -15
    addi x8, x0, -15
    bne x7, x8, arith_fail

    j arith_pass

arith_fail:
    addi x30, x0, 1
    ret

arith_pass:
    addi x30, x0, 0
    ret

test_logical:
    addi x5, x0, 0x0F     # x5 = 0x0F
    addi x6, x0, 0x33     # x6 = 0x33

    andi x7, x5, 0x03     # x7 = 0x0F & 0x03 = 0x03
    addi x8, x0, 0x03
    bne x7, x8, logical_fail

    ori x7, x5, 0x30      # x7 = 0x0F | 0x30 = 0x3F
    addi x8, x0, 0x3F
    bne x7, x8, logical_fail

    xori x7, x5, 0x0F     # x7 = 0x0F ^ 0x0F = 0x00
    bne x7, x0, logical_fail

    and x7, x5, x6        # x7 = 0x0F & 0x33 = 0x03
    addi x8, x0, 0x03
    bne x7, x8, logical_fail

    or x7, x5, x6         # x7 = 0x0F | 0x33 = 0x3F
    addi x8, x0, 0x3F
    bne x7, x8, logical_fail

    xor x7, x5, x6        # x7 = 0x0F ^ 0x33 = 0x3C
    addi x8, x0, 0x3C
    bne x7, x8, logical_fail

    j logical_pass

logical_fail:
    addi x30, x0, 1
    ret

logical_pass:
    addi x30, x0, 0
    ret

test_shift:
    addi x5, x0, 0x0F     # x5 = 0x0000000F
    addi x6, x0, 4        # x6 = 4

    slli x7, x5, 4        # x7 = 0x000000F0
    addi x8, x0, 0xF0
    bne x7, x8, shift_fail

    srli x7, x7, 2        # x7 = 0x0000003C
    addi x8, x0, 0x3C
    bne x7, x8, shift_fail

    # Test arithmetic shift
    addi x5, x0, -8       # x5 = 0xFFFFFFF8
    srai x7, x5, 2        # x7 = 0xFFFFFFFE
    addi x8, x0, -2
    bne x7, x8, shift_fail

    # Test register shifts
    sll x7, x5, x6        # x7 = 0xFFFFFFF8 << 4 = 0xFFFFFF80
    addi x8, x0, -0x80    # 0xFFFFFF80
    bne x7, x8, shift_fail

    srli x7, x7, 20
    lui x8, 0x0FFFF
    lui x8, 0xFFF
    srli x8, x8, 12        # x8 = 0xFFF
    bne x7, x8, shift_fail

    sra x7, x5, x6        # x7 = 0xFFFFFFF8 >>> 4 = 0xFFFFFFFF
    addi x8, x0, -1
    bne x7, x8, shift_fail

    j shift_pass

shift_fail:
    addi x30, x0, 1
    ret

shift_pass:
    addi x30, x0, 0
    ret

test_compare:
    addi x5, x0, 5        # x5 = 5
    addi x6, x0, 10       # x6 = 10
    addi x7, x0, -5       # x7 = -5

    slti x8, x5, 10       # 5 < 10 = true (1)
    addi x9, x0, 1
    bne x8, x9, compare_fail

    slti x8, x6, 5        # 10 < 5 = false (0)
    bne x8, x0, compare_fail

    slti x8, x7, 0        # -5 < 0 = true (1)
    bne x8, x9, compare_fail

    # Test unsigned comparison
    sltiu x8, x7, 1       # 0xFFFFFFFB < 1 = false (0)
    bne x8, x0, compare_fail

    # Test register comparisons
    slt x8, x5, x6        # 5 < 10 = true (1)
    bne x8, x9, compare_fail

    sltu x8, x7, x5       # 0xFFFFFFFB < 5 = false (0)
    bne x8, x0, compare_fail

    j compare_pass

compare_fail:
    addi x30, x0, 1
    ret

compare_pass:
    addi x30, x0, 0
    ret

test_memory:
    addi x5, x0, 0x123    # x5 = 0x00000123
    addi x6, x0, 0x0AA    # x6 = 0x000000AA
    addi x7, x0, 0x0BB    # x7 = 0x000000BB

    # Test SW/LW
    sw x5, 0(x0)
    lw x8, 0(x0)
    bne x5, x8, memory_fail

    # Test SH/LH/LHU
    sh x7, 4(x0)
    lh x8, 4(x0)
    bne x8, x7, memory_fail

    lhu x8, 4(x0)
    bne x8, x7, memory_fail

    # Test byte sign extension
    addi x9, x0, 0x0FF    # x9 = 0x000000FF
    sb x9, 6(x0)
    lb x8, 6(x0)
    addi x7, x0, -1       # x7 = -1
    bne x8, x7, memory_fail

    lbu x8, 6(x0)
    bne x8, x9, memory_fail

    j memory_pass

memory_fail:
    addi x30, x0, 1
    ret

memory_pass:
    addi x30, x0, 0
    ret

test_branch:
    addi x5, x0, 5        # x5 = 5
    addi x6, x0, 5        # x6 = 5
    addi x7, x0, 10       # x7 = 10
    addi x8, x0, -5       # x8 = -5

    beq x5, x6, beq_ok
    j branch_fail
beq_ok:

    bne x5, x7, bne_ok
    j branch_fail
bne_ok:

    blt x5, x7, blt_ok
    j branch_fail
blt_ok:

    bge x7, x5, bge_ok
    j branch_fail
bge_ok:

    addi x9, x0, 1        # x9 = 1
    bltu x9, x8, bltu_ok  # 1 < 0xFFFFFFFB (true)
    j branch_fail
bltu_ok:

    bgeu x8, x9, bgeu_ok  # 0xFFFFFFFB >= 1 (true)
    j branch_fail
bgeu_ok:

    j branch_pass

branch_fail:
    addi x30, x0, 1
    ret

branch_pass:
    addi x30, x0, 0
    ret

test_jump:
    jal x2, jal_test      # x2 = return address
    j jump_fail

jal_test:
    # Address calculation
    addi x4, x0, 3
    auipc x4, 0
    addi x4, x4, 16
    jalr x3, x4, 0
    j jump_fail

jalr_target:
    beq x2, x0, jump_fail
    beq x3, x0, jump_fail
    j jump_pass

jump_fail:
    addi x30, x0, 1
    ret

jump_pass:
    addi x30, x0, 0
    ret

test_utype:
    lui x5, 0x12345       # x5 = 0x12345000
    lui x6, 0x12345
    lui x7, 0xFFFFF
    addi x6, x6, 0x000    # x6 = 0x12345000
    bne x5, x6, utype_fail

    # Test AUIPC with known pattern
    auipc x5, 0
    nop
    auipc x6, 0

    sub x7, x6, x5
    addi x8, x0, 8
    bne x7, x8, utype_fail

    # Test AUIPC with immediate
    auipc x5, 0x100       # x5 = PC + 0x100000
    auipc x6, 0x100       # x6 = PC + 0x100000

    sub x7, x6, x5        # Should be 4 bytes difference
    addi x8, x0, 4
    bne x7, x8, utype_fail

    j utype_pass

utype_fail:
    addi x30, x0, 1
    ret

utype_pass:
    addi x30, x0, 0
    ret

test_end:
    j test_end
