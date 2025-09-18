_start:
    addi x1, x0, 10
    addi x2, x0, 20
    add x1, x1, x2
    jal x1, after_jmp
    addi x10, x0, 1
    j end

after_jmp:
    addi x4, x0, 10
    addi x5, x0, 15
    addi x1, x0, 0x11
    jalr x0, 0(x1)
end:
    j end
