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
addi $s1,$s0,-4

# Definition : L is -4($s0)

# get the elements of list, from left to right
# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

# int 2
addi $s1,$s1,-4
li $t1,2
sw $t1,0($s1)

# int 3
addi $s1,$s1,-4
li $t1,3
sw $t1,0($s1)

addi $s5, 12 # make space for 3 elements on heap
# store element at index 2
lw $t1,0($s1)
sw $t1,-4($s5)
# store element at index 1
lw $t1,4($s1)
sw $t1,-8($s5)
# store element at index 0
lw $t1,8($s1)
sw $t1,-12($s5)
addi $s1,8 # pop stack 2 times
addi $t0,$s5,-12 # old $s5 value
sw $t0,0($s1) # store pointer on heap

lw $t1,0($s1) # get value
addi $t0,$s0,-4 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Getting index
# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2 = t2*4
lw $t0,-4($s0) # load pointer value
srl $t1,$t0,30 # a lil bit of type checking
addi $t3,$zero,1 # code for list
bne $t1,$t3,error # type check over
add $t0,$t0,$t2 # get address
lw $t1,0($t0) # get value at index
sw $t1,0($s1) # replace index on stack with value

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
theend:
# Exit via syscall 10
addi $v0,$zero,10
syscall #10
error:
addi $a0, $zero, -1
addi $v0, $zero, 1
syscall
# Exit via syscall 10
addi $v0,$zero,10
syscall #10