_start:
    addi x10, x0, 0

    # -----------------------------------------------------------------
    # 1. BASIC MULTIPLICATION (MUL)
    # -----------------------------------------------------------------
    jal x1, test_mul_basic
    bne x0, x11, test_fail

    # -----------------------------------------------------------------
    # 2. SIGNED MULTIPLICATION HIGH (MULH)
    # -----------------------------------------------------------------
    jal x1, test_mulh
    bne x0, x11, test_fail

    # -----------------------------------------------------------------
    # 3. UNSIGNED MULTIPLICATION HIGH (MULHU)
    # -----------------------------------------------------------------
    jal x1, test_mulhu
    bne x0, x11, test_fail

    # -----------------------------------------------------------------
    # 4. SIGNED-UNSIGNED MULTIPLICATION HIGH (MULHSU)
    # -----------------------------------------------------------------
    jal x1, test_mulhsu
    bne x0, x11, test_fail

    # -----------------------------------------------------------------
    # 5. EDGE CASES AND OVERFLOW
    # -----------------------------------------------------------------
    jal x1, test_mul_edge_cases
    bne x0, x11, test_fail

    addi x10, x0, 1
    j test_end

test_fail:
    addi x10, x0, 0
    j test_end

# ==================== MULTIPLICATION TEST SUBROUTINES ====================

test_mul_basic:
    # Test MUL with basic values
    addi x5, x0, 5        # x5 = 5
    addi x6, x0, 6        # x6 = 6
    mul x7, x5, x6        # x7 = 5 * 6 = 30
    addi x8, x0, 30
    bne x7, x8, mul_fail

    # Test negative multiplication
    addi x5, x0, -4       # x5 = -4
    addi x6, x0, 7        # x6 = 7
    mul x7, x5, x6        # x7 = -4 * 7 = -28
    addi x8, x0, -28
    bne x7, x8, mul_fail

    # Test two negatives
    addi x5, x0, -3       # x5 = -3
    addi x6, x0, -5       # x6 = -5
    mul x7, x5, x6        # x7 = -3 * -5 = 15
    addi x8, x0, 15
    bne x7, x8, mul_fail

    j mul_pass

test_mulh:
    # Test MULH (signed × signed, return high bits)
    lui x5, 0x12345       # x5 = 0x12345000
    lui x6, 0x6789A       # x6 = 0x6789A000
    mulh x7, x5, x6       # High bits of signed multiplication

    beq x7, x0, mul_fail

    # Test with negative values
    addi x5, x0, -1000    # x5 = -1000
    addi x6, x0, 1000     # x6 = 1000
    mulh x7, x5, x6       # x7 = (-1000 * 1000) >> 32 = -1 (0xFFFFFFFF)
    addi x8, x0, -1
    bne x7, x8, mul_fail

    j mul_pass

test_mulhu:
    # Test MULHU (unsigned × unsigned, return high bits)
    lui x5, 0xFFFFF       # x5 = 0xFFFFF000 (large unsigned)
    lui x6, 0x2           # x6 = 0x2000
    mulhu x7, x5, x6      # High bits of unsigned multiplication

    # Expected: (0xFFFFF000 * 0x2000) >> 32 ≈ 0x1FFFF
    lui x8, 0x2           # x8 = 0x2000
    addi x8, x8, -1       # x8 = 0x1FFF

    lui x9, 0x2           # Upper bound
    lui x10, 0x1FF0
    srli x10, x10, 12
    blt x7, x10, mul_fail
    bge x7, x9, mul_fail

    j mul_pass

test_mulhsu:
    # Test MULHSU (signed × unsigned, return high bits)
    addi x5, x0, -1000    # x5 = -1000 (signed)
    lui x6, 0x1           # x6 = 0x1000 (unsigned)
    mulhsu x7, x5, x6     # High bits of signed-unsigned multiplication

    # Expected: (-1000 * 0x1000) >> 32 = -1 (0xFFFFFFFF)
    addi x8, x0, -1
    bne x7, x8, mul_fail

    # Test with positive signed
    addi x5, x0, 1000     # x5 = 1000 (signed)
    lui x6, 0x1           # x6 = 0x1000 (unsigned)
    mulhsu x7, x5, x6     # High bits should be 0
    bne x7, x0, mul_fail

    j mul_pass

test_mul_edge_cases:
    # Test multiplication by zero
    lui x5, 12345
    addi x6, x0, 0
    mul x7, x5, x6        # x7 = 0
    bne x7, x0, mul_fail

    mulh x7, x5, x6       # x7 = 0
    bne x7, x0, mul_fail

    # Test multiplication by one
    lui x5, 12345
    addi x6, x0, 1
    mul x7, x5, x6        # x7 = 12345
    lui x8, 12345
    bne x7, x8, mul_fail

    # Test maximum values
    addi x5, x0, -1       # x5 = 0xFFFFFFFF
    addi x6, x0, -1       # x6 = 0xFFFFFFFF
    mul x7, x5, x6        # x7 = (-1 × -1) = 1
    addi x8, x0, 1
    bne x7, x8, mul_fail

    # MULH of -1 × -1 should be 0
    mulh x7, x5, x6
    bne x7, x0, mul_fail

    j mul_pass

mul_fail:
    addi x11, x0, 1
    ret

mul_pass:
    addi x11, x0, 0
    ret

test_end:
    j test_end
