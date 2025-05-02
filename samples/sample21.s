# This code can be run on the Virtual Machine PyVM that comes bundled with the project

.data
.text
.globl main
j main # this is because the VM goes to the first line directly, and not to main.

pathfinder:
add $t1,$ra,$zero
jr $ra

main:
li $sp,0x60000000
addi $s0,$sp,0
addi $s5,$sp,4
addi $s1,$s0,-16

jal pathfinder
addi $t1,$t1,16
li $t2,0x80000000
or $t1,$t1,$t2
sw $t1,-8($s0)

thestart:
addi $t8,$zero,1
addi $t9,$zero,1

# Definition : f is -16($s0)

# Algorithm
add $t2,$ra,$zero # save current ra
jal pathfinder # find path of next line
add $ra,$t2,$zero # restore ra
addi $t1,$t1,28 # address to start the function
#li $t2,0x80000000 # gives 2 base instructions..bad
sll $t2,$t8,31
or $t1,$t1,$t2
addi $s1,$s1,-4
sw $t1,0($s1)
j label2 # skip function
label1:





# return
lw $t0,0($s0)
addi $t9,$zero,0
add $s1,$s0,$zero
add $s0,$zero,$t0
jr $ra
label2: # end of function

# Add this to parent pointer tree
lw $t2,-8($s0) # parent
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5
sw $t2,0($t1) # child -> parent
sw $zero,4($t1) # child has null as its copy, since it's not dead yet


lw $t1,0($s1) # get value
addi $t0,$s0,-16 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# getting f
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)
 # assert type is alg
lw $t1,0($s1)
srl $t1,$t1,29
addi $t2,$zero,4
beq $t1,$t2,label3
j error # if wrong type
label3:# type check over
 lw $t1, 0($s1)
li $t2,0x1FFFFFFF
and $t1, $t1, $t2
sw $t1, 0($s1)

# function call
sw $ra,-4($s1)
addi $s1,$s1,-4

# Getting Arguments

# first argument is the creator base, currently available in $t0
addi $s1,$s1,-4
sw $t0,0($s1)

# second is the value of this function, currently available in $t1
addi $s1,$s1,-4
sw $t1,0($s1)

# third is the stack base of fake parent, initially 0
addi $s1,$s1,-4
# lw $t2,-8($t0)
# sw $t2,0($s1)
sw $zero,0($s1)

# All other arguments
# No arguments

# Making a stack frame
addi $s1,$s1,12
lw $t2,4($s1)
lw $t1,0($s1)
sw $t1,4($s1)
sw $s0,0($s1)
add $s0,$s1,$zero
addi $s1,$s1,-12
jal pathfinder
addi $ra,$t1,8
jr $t2
addi $s1,$s1,8
lw $ra,-4($s1)




# print newline via syscall 11 to clean up
addi $a0, $0, 10
addi $v0, $0, 11 
syscall
theend:
# Exit via syscall 10
addi $v0,$zero,10
syscall #10
error:#Print ERROR
addi $v0,$zero,11
addi $a0,$zero,69 #E
syscall
addi $a0,$zero,82 #R
syscall
addi $a0,$zero,82 #R
syscall
addi $a0,$zero,79 #O
syscall
addi $a0,$zero,82 #R
syscall
addi $a0,$zero,10 # newline
syscall

# Exit via syscall 10
addi $v0,$zero,10
syscall #10
