.global _start
_start:
addi $s0,$zero,1024

addi $t8,$zero,1

addi $t9,$zero,1

addi $s1,$s0,-8

# y is -4($s0)

# x is -8($s0)

j label2 # skip function
label1:

addi $t8,$zero,1

addi $t9,$zero,1

addi $s1,$s0,-8

addi $s1,$s1,-4
addi $t1,$zero,1
sw $t1,0($s1)
# return
lw $t0,0($s0)
lw $t1,0($s1)
sw $t1,0($s0)
add $s1,$s0,$zero
add $s0,$zero,$t0
jr $ra



lw $t0,0($s0)
lw $t1,0($s1)
sw $t1,0($s0)
add $s1,$s0,$zero
add $s0,$zero,$t0
jr $ra
label2: # end of function

sw $ra,-4($s1)
sw $s0,-8($s1)
addi $s0,$s1,-8
jal label1
lw $t1,0($s1)
addi $s1,$s1,4
lw $ra,0($s1)
sw $t1,0($s1)

lw $t1,0($s1)
addi $t0,$s0,-8
sw $t1,0($t0)
addi $s1,$s1,4



syscall 10