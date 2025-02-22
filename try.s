.global _start

pathfinder:
add $t1,$ra,$zero
jr $ra

_start:
li $s0,0x40000000
li $s5,0x40000004

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-8

# S is -4($s0)

# x is -8($s0)

# int 0
addi $s1,$s1,-4
addi $t1,$zero,0
sw $t1,0($s1)

# Assignment
lw $t1,0($s1)
addi $t0,$s0,-4
sw $t1,0($t0)
addi $s1,$s1,4

# int 1
addi $s1,$s1,-4
addi $t1,$zero,1
sw $t1,0($s1)

# Assignment
lw $t1,0($s1)
addi $t0,$s0,-8
sw $t1,0($t0)
addi $s1,$s1,4

label1: # while 

# getting x
add $t0,$s0,$zero
addi $t0,$t0,-8
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

# int 1000
addi $s1,$s1,-4
addi $t1,$zero,1000
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t1,$t1,$t2
sw $t1,0($s1)
lw $t9,0($s1)
addi $s1,$s1,4
slt $t1,$zero,$t9
slt $t9,$t9,$zero
or $t9,$t9,$t1
beq $t9,$zero,label2

# getting x
add $t0,$s0,$zero
addi $t0,$t0,-8
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

# int 3
addi $s1,$s1,-4
addi $t1,$zero,3
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
div $t1,$t2
mflo $t2
mfhi $t1
sw $t1,0($s1)

# int 0
addi $s1,$s1,-4
addi $t1,$zero,0
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t3,$t1,$t2
slt $t2,$t2,$t1
or $t1,$t3,$t2
sub $t1,$t8,$t1
sw $t1,0($s1)

# getting x
add $t0,$s0,$zero
addi $t0,$t0,-8
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

# int 5
addi $s1,$s1,-4
addi $t1,$zero,5
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
div $t1,$t2
mflo $t2
mfhi $t1
sw $t1,0($s1)

# int 0
addi $s1,$s1,-4
addi $t1,$zero,0
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t3,$t1,$t2
slt $t2,$t2,$t1
or $t1,$t3,$t2
sub $t1,$t8,$t1
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
or $t1,$t1,$t2
sw $t1,0($s1)

lw $t9,0($s1)
addi $s1,$s1,4
beq $t9,$zero,label3 # if

# getting S
add $t0,$s0,$zero
addi $t0,$t0,-4
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

# getting x
add $t0,$s0,$zero
addi $t0,$t0,-8
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
add $t1,$t1,$t2
sw $t1,0($s1)

# Assignment
lw $t1,0($s1)
addi $t0,$s0,-4
sw $t1,0($t0)
addi $s1,$s1,4



label3: # end if

# getting x
add $t0,$s0,$zero
addi $t0,$t0,-8
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
add $t1,$t1,$t2
sw $t1,0($s1)

# Assignment
lw $t1,0($s1)
addi $t0,$s0,-8
sw $t1,0($t0)
addi $s1,$s1,4



j label1
label2: # end while

# getting S
add $t0,$s0,$zero
addi $t0,$t0,-4
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

# Print
addi $v0, $zero, 1
lw $a0, 0($s1)
syscall
addi $s1,$s1,4



# Exit
addi $v0,$zero,10
syscall