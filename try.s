.global _start

pathfinder:
add $t1,$ra,$zero
jr $ra

_start:
addi $s0,$zero,1024

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-8

# y is -4($s0)

# x is -8($s0)

# Algorithm
jal pathfinder # find path of next line
addi $t1,$t1,16
addi $s1,$s1,-4
sw $t1,0($s1)
j label2 # skip function
label1:

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-8

# int 11
addi $s1,$s1,-4
addi $t1,$zero,11
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

# Assignment
lw $t1,0($s1)
addi $t0,$s0,-4
sw $t1,0($t0)
addi $s1,$s1,4

# getting y
addi $t0,$s0,-4
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

# function call
add $t2,$t1,$zero
sw $ra,-4($s1)
sw $s0,-8($s1)
addi $s0,$s1,-8
jal pathfinder
addi $ra,$t1,8
jr $t2
lw $t1,0($s1)
addi $s1,$s1,8
lw $ra,-4($s1)
sw $t1,0($s1)

# Assignment
lw $t1,0($s1)
addi $t0,$s0,-8
sw $t1,0($t0)
addi $s1,$s1,4



syscall 10