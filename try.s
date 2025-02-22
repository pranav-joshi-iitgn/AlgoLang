.global _start

pathfinder:
add $t1,$ra,$zero
jr $ra

_start:
addi $s0,$zero,1024

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-8

# f is -4($s0)

# g is -8($s0)

# Algorithm
jal pathfinder # find path of next line
addi $t1,$t1,16
addi $s1,$s1,-4
sw $t1,0($s1)
j label3 # skip function
label2:

# x is -4($s0)
# f is -8($s0)

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-8

# getting x
addi $t0,$s0,-4
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

# int 1
addi $s1,$s1,-4
addi $t1,$zero,1
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t1,$t2,$t1
sub $t1,$t8,$t1
sw $t1,0($s1)

lw $t9,0($s1)
addi $s1,$s1,4
beq $t9,$zero,label1 # if

# int 1
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



label1: # end if

# getting f
addi $t0,$s0,-8
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

# function call
sw $ra,-4($s1)
addi $s1,$s1,-4

# Getting Arguments

# getting x
addi $t0,$s0,-4
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

# int 1
addi $s1,$s1,-4
addi $t1,$zero,1
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
sub $t1,$t1,$t2
sw $t1,0($s1)

# getting f
addi $t0,$s0,-8
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

# Making a stack frame
addi $s1,$s1,8
lw $t2,4($s1)
lw $t1,0($s1)
sw $t1,4($s1)
sw $s0,0($s1)
add $s0,$s1,$zero
addi $s1,$s1,-8
jal pathfinder
addi $ra,$t1,8
jr $t2
lw $t1,0($s1)
addi $s1,$s1,4
lw $ra,0($s1)
sw $t1,0($s1)

# getting f
addi $t0,$s0,-8
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

# function call
sw $ra,-4($s1)
addi $s1,$s1,-4

# Getting Arguments

# getting x
addi $t0,$s0,-4
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

# int 2
addi $s1,$s1,-4
addi $t1,$zero,2
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
sub $t1,$t1,$t2
sw $t1,0($s1)

# getting f
addi $t0,$s0,-8
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

# Making a stack frame
addi $s1,$s1,8
lw $t2,4($s1)
lw $t1,0($s1)
sw $t1,4($s1)
sw $s0,0($s1)
add $s0,$s1,$zero
addi $s1,$s1,-8
jal pathfinder
addi $ra,$t1,8
jr $t2
lw $t1,0($s1)
addi $s1,$s1,4
lw $ra,0($s1)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
add $t1,$t1,$t2
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
label3: # end of function

# Assignment
lw $t1,0($s1)
addi $t0,$s0,-8
sw $t1,0($t0)
addi $s1,$s1,4

# getting g
addi $t0,$s0,-8
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

# function call
sw $ra,-4($s1)
addi $s1,$s1,-4

# Getting Arguments

# int 5
addi $s1,$s1,-4
addi $t1,$zero,5
sw $t1,0($s1)

# getting g
addi $t0,$s0,-8
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

# Making a stack frame
addi $s1,$s1,8
lw $t2,4($s1)
lw $t1,0($s1)
sw $t1,4($s1)
sw $s0,0($s1)
add $s0,$s1,$zero
addi $s1,$s1,-8
jal pathfinder
addi $ra,$t1,8
jr $t2
lw $t1,0($s1)
addi $s1,$s1,4
lw $ra,0($s1)
sw $t1,0($s1)

# Print
addi $v0, $zero, 1
lw $a0, 0($s1)
syscall
addi $s1,$s1,4



# Exit
addi $v0,$zero,10
syscall