# This code can be run on the SPIM simulator. It can be installed on debian/ubuntu as :
# `sudo apt-get install spim`
# Then, you can run the code as `spim -f <filename>`

.data
.text
.globl main

pathfinder:
add $t1,$ra,$zero
jr $ra

main:
addi $s0,$sp,0
addi $s5,$sp,4

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-8

# Definition : S is -4($s0)

# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-4 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : x is -8($s0)

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-8 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

label1_start: # while 

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-8($t0)
sw $t1,0($s1)

# int 1000
addi $s1,$s1,-4
li $t1,1000
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
beq $t9,$zero,label1_end

# Condition

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-8($t0)
sw $t1,0($s1)

# int 3
addi $s1,$s1,-4
li $t1,3
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
li $t1,0
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
addi $s1,$s1,-4
lw $t1,-8($t0)
sw $t1,0($s1)

# int 5
addi $s1,$s1,-4
li $t1,5
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
li $t1,0
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

lw $t9,0($s1) #get result of condition
addi $s1,$s1,4 # delete a value
beq $t9,$zero,label2 # if

# getting S
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-4($t0)
sw $t1,0($s1)

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-8($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
add $t1,$t1,$t2
sw $t1,0($s1)

# Assignment
# getting S
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-4($t0)
addi $s1,$s1,4



addi $t9,$zero,1
label2: # end if

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-8($t0)
sw $t1,0($s1)

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
add $t1,$t1,$t2
sw $t1,0($s1)

# Assignment
# getting x
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-8($t0)
addi $s1,$s1,4



j label1_start
label1_end: # end while

# getting S
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-4($t0)
sw $t1,0($s1)

# Print
addi $v0, $zero, 1
lw $a0, 0($s1)
syscall
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $0, 10
addi $v0, $0, 11 
syscall



# print newline via syscall 11 to clean up
addi $a0, $0, 10
addi $v0, $0, 11 
syscall

# Exit via syscall 10
addi $v0,$zero,10
syscall #10