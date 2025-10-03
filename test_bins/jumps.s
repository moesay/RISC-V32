_start:

addi x3, x0, 10
addi x4, x0, 10

bne x3, x4, will_j
addi x30, x30, 1

will_j:

addi x5, x0, 5
beq x3, x5, willnot_j
jal stop

willnot_j:
addi x7, x0, 1

stop:

