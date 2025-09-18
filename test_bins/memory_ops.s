_start:
    addi x1, x0, 42

    sw x1, 0(x0)

    lw x2, 0(x0)

    addi x9, x0, 0xFF
    sb x9, 6(x0)
    addi x2, x2, 1
    lb x8, 6(x0)
    addi x7, x0, -1

    bne x8, x7, _start

_end:
    j _end
