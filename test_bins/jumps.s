_start:
    addi x10, x0, 0
    addi x11, x0, 0

    jal x1, function_a
    addi x11, x11, 1      # Increment test counter if we return

    jal x2, function_b
    addi x11, x11, 1

    addi a0, x0, 5
    jal x3, function_with_param
    addi x11, x11, 1

    # all tests completed successfully if x11 == 3
    addi x10, x0, 1
    j test_end

function_a:
    jalr x0, x1, 0

function_b:
    jal x4, function_c
    jalr x0, x2, 0

function_c:
    jalr x0, x4, 0

function_with_param:
    addi a0, a0, 10
    jalr x0, x3, 0

test_fail:
    addi x10, x0, 0

test_end:
    j test_end
