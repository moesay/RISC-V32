_start:
    addi x10, x0, 0

    # -----------------------------------------------------------------
    # 1. DIV (signed division)
    # -----------------------------------------------------------------
    jal x1, test_div
    bne x0, x5, test_fail

    # -----------------------------------------------------------------
    # 2. DIVU (unsigned division)
    # -----------------------------------------------------------------
    jal x1, test_divu
    bne x0, x5, test_fail

    # -----------------------------------------------------------------
    # 3. REM (signed remainder)
    # -----------------------------------------------------------------
    jal x1, test_rem
    bne x0, x5, test_fail

    # -----------------------------------------------------------------
    # 4. REMU (unsigned remainder)
    # -----------------------------------------------------------------
    jal x1, test_remu
    bne x0, x5, test_fail

    # -----------------------------------------------------------------
    # 5. EDGE CASES (division by zero, overflow)
    # -----------------------------------------------------------------
    jal x1, test_div_edge_cases
    bne x0, x5, test_fail

    addi x10, x0, 1
    j test_end

test_fail:
    addi x10, x0, 0
    j test_end

# ==================== DIVISION TEST SUBROUTINES ====================

test_div:
    addi x6, x0, 20       # x6 = 20
    addi x7, x0, 3        # x7 = 3
    div x8, x6, x7        # x8 = 20 / 3 = 6
    addi x9, x0, 6
    bne x8, x9, div_fail

    # Test negative division
    addi x6, x0, -20      # x6 = -20
    div x8, x6, x7        # x8 = -20 / 3 = -6
    addi x9, x0, -6
    bne x8, x9, div_fail

    # Test negative divisor
    addi x6, x0, 20       # x6 = 20
    addi x7, x0, -3       # x7 = -3
    div x8, x6, x7        # x8 = 20 / -3 = -6
    addi x9, x0, -6
    bne x8, x9, div_fail

    # Test two negatives
    addi x6, x0, -20      # x6 = -20
    addi x7, x0, -3       # x7 = -3
    div x8, x6, x7        # x8 = -20 / -3 = 6
    addi x9, x0, 6
    bne x8, x9, div_fail

    j div_pass

test_divu:
    # Test DIVU with basic values
    addi x6, x0, 20       # x6 = 20
    addi x7, x0, 3        # x7 = 3
    divu x8, x6, x7       # x8 = 20 / 3 = 6
    addi x9, x0, 6
    bne x8, x9, div_fail

    # Test DIVU with large unsigned values
    lui x6, 0x12345       # x6 = 0x12345000
    lui x7, 1
    divu x8, x6, x7       # x8 = 0x12345000 / 4096 = 0x12345
    lui x9, 0x12345
    srli x9, x9, 12
    bne x8, x9, div_fail

    j div_pass

test_rem:
    # Test REM with basic values
    addi x6, x0, 20       # x6 = 20
    addi x7, x0, 3        # x7 = 3
    rem x8, x6, x7        # x8 = 20 % 3 = 2
    addi x9, x0, 2
    bne x8, x9, div_fail

    # Test negative remainder
    addi x6, x0, -20      # x6 = -20
    rem x8, x6, x7        # x8 = -20 % 3 = -2
    addi x9, x0, -2
    bne x8, x9, div_fail

    # Test negative divisor
    addi x6, x0, 20       # x6 = 20
    addi x7, x0, -3       # x7 = -3
    rem x8, x6, x7        # x8 = 20 % -3 = 2
    addi x9, x0, 2
    bne x8, x9, div_fail

    # Test two negatives
    addi x6, x0, -20      # x6 = -20
    addi x7, x0, -3       # x7 = -3
    rem x8, x6, x7        # x8 = -20 % -3 = -2
    addi x9, x0, -2
    bne x8, x9, div_fail

    j div_pass

test_remu:
    # Test REMU with basic values
    addi x6, x0, 20       # x6 = 20
    addi x7, x0, 3        # x7 = 3
    remu x8, x6, x7       # x8 = 20 % 3 = 2
    addi x9, x0, 2
    bne x8, x9, div_fail

    # Test REMU with large values
    lui x6, 0x12345       # x6 = 0x12345000
    # addi x7, x0, 0x1000   # x7 = 4096
    lui x7, 1
    remu x8, x6, x7       # x8 = 0x12345000 % 4096 = 0
    bne x8, x0, div_fail

    # Test REMU with non-zero remainder
    lui x6, 0x12345       # x6 = 0x12345000
    addi x6, x6, 0x123    # x6 = 0x12345123
    remu x8, x6, x7       # x8 = 0x12345123 % 4096 = 0x123
    addi x9, x0, 0x123
    bne x8, x9, div_fail

    j div_pass

test_div_edge_cases:
    # Test division by zero
    # addi x6, x0, 12345
    lui x6, 12345
    srli x6, x6, 12
    addi x7, x0, 0        # x7 = 0

    div x8, x6, x7        # Should return -1 (0xFFFFFFFF)
    addi x9, x0, -1
    bne x8, x9, div_fail

    divu x8, x6, x7       # Should return -1 (0xFFFFFFFF)
    bne x8, x9, div_fail

    # Test remainder by zero
    rem x8, x6, x7        # Should return dividend (12345)
    # addi x9, x0, 12345
    lui x9, 12345
    srli x9, x9, 12
    bne x8, x9, div_fail

    remu x8, x6, x7       # Should return dividend (12345)
    bne x8, x9, div_fail

    # Test division of minimum value by -1
    addi x6, x0, 1        # x6 = 1
    slli x6, x6, 31       # x6 = 0x80000000
    addi x7, x0, -1       # x7 = -1

    div x8, x6, x7        # Should return dividend (0x80000000) for overflow
    lui x9, 0x80000
    bne x8, x9, div_fail

    j div_pass

div_fail:
    addi x5, x0, 1        # Return failure
    ret

div_pass:
    addi x5, x0, 0
    ret

test_end:
    j test_end
