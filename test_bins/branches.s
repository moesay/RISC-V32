_start:
    addi x1, x0, 5
    addi x2, x0, 5
    addi x3, x0, 10
    addi x4, x0, 3

    addi x5, x0, -5       # x5 = -5 (0xFFFFFFFB)
    addi x6, x0, 5

    # success indicator
    addi x10, x0, 0

    beq x1, x2, test_beq_pass
    j test_fail
test_beq_pass:
    bne x1, x2, test_fail  # x1 == x2, so should NOT branch

    bne x1, x3, test_bne_pass  # x1 != x3, so should branch
    j test_fail
test_bne_pass:
    blt x4, x1, test_blt_pass
    j test_fail
test_blt_pass:
    blt x1, x4, test_fail

    bge x1, x2, test_bge_pass
    j test_fail
test_bge_pass:
    bge x3, x1, test_bge2_pass
    j test_fail
test_bge2_pass:
    bge x4, x1, test_fail

    bltu x6, x5, test_bltu_pass  # 5 < 0xFFFFFFFB (unsigned), should branch
    j test_fail
test_bltu_pass:
    bltu x5, x6, test_fail     # 0xFFFFFFFB is not < 5 (unsigned), should not branch

    bgeu x5, x6, test_bgeu_pass  # 0xFFFFFFFB >= 5 (unsigned), so should branch
    j test_fail
test_bgeu_pass:
    bgeu x6, x5, test_fail

    # all tests passed
    # set success indicator
    addi x10, x0, 1
    j test_end

test_fail:
    # any test failed
    addi x10, x0, 0       # Set failure indicator
    j test_end

test_end:
    j test_end
