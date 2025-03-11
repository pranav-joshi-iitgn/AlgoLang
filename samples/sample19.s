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
li $sp,0x60000000
addi $s0,$sp,0
addi $s5,$sp,4
addi $s1,$s0,-28

jal pathfinder
addi $t1,$t1,16
li $t2,0x80000000
or $t1,$t1,$t2
sw $t1,-8($s0)

thestart:
addi $t8,$zero,1
addi $t9,$zero,1

# Definition : a is -16($s0)

# int 10
addi $s1,$s1,-4
li $t1,10
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-16 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : b is -20($s0)

# int 2
addi $s1,$s1,-4
li $t1,2
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-20 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : f is -24($s0)

# Algorithm
add $t2,$ra,$zero # save current ra
jal pathfinder # find path of next line
addi $t1,$t1,28 # address to start the function
add $ra,$t2,$zero # restore ra
li $t2,0x80000000
or $t1,$t1,$t2
addi $s1,$s1,-4
sw $t1,0($s1)
j label9 # skip function
label8:

# x is -16($s0)

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-20

# Definition : g is -20($s0)

# Algorithm
add $t2,$ra,$zero # save current ra
jal pathfinder # find path of next line
addi $t1,$t1,28 # address to start the function
add $ra,$t2,$zero # restore ra
li $t2,0x80000000
or $t1,$t1,$t2
addi $s1,$s1,-4
sw $t1,0($s1)
j label7 # skip function
label6:



addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-12

# getting x
add $t0,$s0,$zero
li $t5,0x7F000000
li $t6,0x1FFFFFFF
lw $t1,-8($t0) # self
and $t1,$t1,$t6
or $t1,$t1,$t5
lw $t2,0($t1) # parent
lw $t0,-4($t0)
lw $t3,-8($t0) # self_new
beq $t3,$t2,label1
#Print parent dead
addi $v0,$zero,11
addi $a0,$zero,112 #p
syscall
addi $a0,$zero,97 #a
syscall
addi $a0,$zero,114 #r
syscall
addi $a0,$zero,101 #e
syscall
addi $a0,$zero,110 #n
syscall
addi $a0,$zero,116 #t
syscall
addi $a0,$zero,32 # 
syscall
addi $a0,$zero,100 #d
syscall
addi $a0,$zero,101 #e
syscall
addi $a0,$zero,97 #a
syscall
addi $a0,$zero,100 #d
syscall
addi $a0,$zero,10 # newline
syscall

j error
label1:# creator is still alive
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label4 # 000 -> int
beq $t1,$t3,label4 # 111 -> int
addi $t3,$zero,3
bne $t1,$t3,label3 # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label2: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label5 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label2 # continue printing characters

label3:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label5

label4:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label5:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $zero, 10
addi $v0, $zero, 11 
syscall




# return whatever is on the top of stack
lw $t0,0($s0)
addi $t9,$zero,0
add $s1,$s0,$zero
add $s0,$zero,$t0
jr $ra
label7: # end of function

# Add this to parent pointer tree
lw $t2,-8($s0) # parent
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5
sw $t2,0($t1) # child -> parent


lw $t1,0($s1) # get value
addi $t0,$s0,-20 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# getting g
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1)
# return
lw $t0,0($s0)
lw $t1,0($s1)
sw $t1,0($s0)
addi $t9,$zero,1
add $s1,$s0,$zero
add $s0,$zero,$t0
jr $ra



# return whatever is on the top of stack
lw $t0,0($s0)
addi $t9,$zero,0
add $s1,$s0,$zero
add $s0,$zero,$t0
jr $ra
label9: # end of function

# Add this to parent pointer tree
lw $t2,-8($s0) # parent
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5
sw $t2,0($t1) # child -> parent


lw $t1,0($s1) # get value
addi $t0,$s0,-24 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : G is -28($s0)

# getting f
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-24($t0)
sw $t1,0($s1) 
# assert type is alg
lw $t1,0($s1)
srl $t1,$t1,29
addi $t2,$zero,4
beq $t1,$t2,label10
j error # if wrong type
label10:# type check over 

lw $t1, 0($s1)
li $t2,0x1FFFFFFF
and $t3, $t1, $t2
sw $t3, 0($s1)

# function called
sw $ra,-4($s1)
addi $s1,$s1,-4

# Getting Arguments

# first argument is the creator base, currently available in $t0
addi $s1,$s1,-4
sw $t0,0($s1)

# second is the value of this function, currently available in $t1
addi $s1,$s1,-4
sw $t1,0($s1)

# third is the value of the parent, available at -8($t0)
addi $s1,$s1,-4
lw $t2,-8($t0)
sw $t2,0($s1)

# All other arguments
# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

# Making a stack frame
addi $s1,$s1,16
lw $t2,4($s1)
lw $t1,0($s1)
sw $t1,4($s1)
sw $s0,0($s1)
add $s0,$s1,$zero
addi $s1,$s1,-16

# jumping to the function
jal pathfinder
addi $ra,$t1,8 # $ra points to the next to next instruction
jr $t2

# getting the return value
lw $t1,0($s1)
addi $s1,$s1,4
lw $ra,0($s1)
sw $t1,0($s1)


lw $t1,0($s1) # get value
addi $t0,$s0,-28 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# getting G
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-28($t0)
sw $t1,0($s1)
 # assert type is alg
lw $t1,0($s1)
srl $t1,$t1,29
addi $t2,$zero,4
beq $t1,$t2,label11
j error # if wrong type
label11:# type check over
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

# third is the value of the parent, available at -8($t0)
addi $s1,$s1,-4
lw $t2,-8($t0)
sw $t2,0($s1)

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
