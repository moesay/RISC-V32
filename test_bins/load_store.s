_start:
    addi x10, x0, 0       # success indicator

    lui x1, 0x12345       # x1 = 0x12345000
    addi x1, x1, 0x678    # x1 = 0x12345678

    lui x2, 0xAABBD       # x2 = 0xAABBD000
    addi x2, x2, -0x400   # x2 = 0xAABBD000 - 0x400 = 0xAABBCC00

    addi x3, x0, 0x0FF    # x3 = 0x000000FF

    addi x4, x0, -1       # x4 = 0xFFFFFFFF
    slli x4, x4, 16       # x4 = 0xFFFF0000
    srli x4, x4, 16       # x4 = 0x0000FFFF

    # test store/load operations
    sw x1, 0(x0)          # store 0x12345678 at address 0
    lw x5, 0(x0)          # soad back
    bne x1, x5, test_fail

    sw x2, 4(x0)          # store 0xAABBCC00 at address 4
    lw x6, 4(x0)          # soad back
    bne x2, x6, test_fail

    # test byte operations
    sb x3, 8(x0)          # store byte 0xFF
    lb x7, 8(x0)          # load byte signed
    addi x8, x0, -1       # x8 = -1 (0xFFFFFFFF)
    bne x7, x8, test_fail

    lbu x7, 8(x0)
    bne x7, x3, test_fail

    addi x10, x0, 1
    j test_end

test_fail:
    addi x10, x0, 0

test_end:
    j test_end
