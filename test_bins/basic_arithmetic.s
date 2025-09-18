_start:
    addi x1, x0, 5
    addi x2, x0, 10
    add x3, x1, x2
    sw x3, 0(x0)
    lw x4, 0(x0)
    beq x4, x3, _pass
    j _fail

_pass:
    addi x10, x0, 1
    j _pass

_fail:
    addi x10, x0, 0
    j _fail
