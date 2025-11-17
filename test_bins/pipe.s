addi x5, x0, 1
addi x6, x0, 2
add x7, x5, x6

addi x8, x0, 10

jal x1, jmp_target

sw   x7, 0(x0)
lw x8, 0(x0)

jmp_target:
addi x5, x0, 2
addi x6, x0, 2
add x7, x5, x6
