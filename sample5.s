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
addi $s1,$s0,-24

# Definition : f is -4($s0)

# Algorithm
jal pathfinder # find path of next line
addi $t1,$t1,24
li $t2,0xA0000000
or $t1,$t1,$t2
addi $s1,$s1,-4
sw $t1,0($s1)
j label7 # skip function
label6:

# x is -8($s0)

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-12

# Definition : g is -12($s0)

# Algorithm
jal pathfinder # find path of next line
addi $t1,$t1,24
li $t2,0xA0000000
or $t1,$t1,$t2
addi $s1,$s1,-4
sw $t1,0($s1)
j label5 # skip function
label4:



addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-4

# getting x
add $t0,$s0,$zero
lw $t0,-4($t0)
addi $s1,$s1,-4
lw $t1,-8($t0)
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label2
beq $t1,$t3,label2
srl $t1,$t1,1
bne $t1,$t8,error
label1:addi $v0, $zero, 11 # str
lw $t1,0($t0)
beq $t1,$zero,label3
addi $a0,$t1,0
syscall
addi $t0,$t0,4
j label1 # continue printing charactters
label2:# int
addi $v0, $zero,1
add $a0,$t0,$zero
syscall
label3:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $0, 10
addi $v0, $0, 11 
syscall



# return whatever is on the top of stack
lw $t0,0($s0)
addi $t9,$zero,0
add $s1,$s0,$zero
add $s0,$zero,$t0
jr $ra
label5: # end of function

lw $t1,0($s1) # get value
addi $t0,$s0,-12 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# getting g
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-12($t0)
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
label7: # end of function

lw $t1,0($s1) # get value
addi $t0,$s0,-4 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : g is -8($s0)

# getting f
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-4($t0)
sw $t1,0($s1)

# assert type is alg
lw $t1,0($s1)
srl $t1,$t1,29
addi $t2,$zero,5
beq $t1,$t2,label8
j error # if wrong type
label8:# type check over

lw $t1, 0($s1)
li $t2,0x1FFFFFFF
and $t1, $t1, $t2
sw $t1, 0($s1)

# function called
sw $ra,-4($s1)
addi $s1,$s1,-4

# Getting Arguments

# first argument is the creator base, currently available in $t0
addi $s1,$s1,-4
sw $t0,0($s1)

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

# Making a stack frame
addi $s1,$s1,8
lw $t2,4($s1)
lw $t1,0($s1)
sw $t1,4($s1)
sw $s0,0($s1)
add $s0,$s1,$zero
addi $s1,$s1,-8

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
addi $t0,$s0,-8 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# getting g
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-8($t0)
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label10
beq $t1,$t3,label10
srl $t1,$t1,1
bne $t1,$t8,error
label9:addi $v0, $zero, 11 # str
lw $t1,0($t0)
beq $t1,$zero,label11
addi $a0,$t1,0
syscall
addi $t0,$t0,4
j label9 # continue printing charactters
label10:# int
addi $v0, $zero,1
add $a0,$t0,$zero
syscall
label11:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $0, 10
addi $v0, $0, 11 
syscall

# Definition : h is -12($s0)

# Algorithm
jal pathfinder # find path of next line
addi $t1,$t1,24
li $t2,0xA0000000
or $t1,$t1,$t2
addi $s1,$s1,-4
sw $t1,0($s1)
j label18 # skip function
label17:

# a is -8($s0)

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-12

# Definition : k is -12($s0)

# Algorithm
jal pathfinder # find path of next line
addi $t1,$t1,24
li $t2,0xA0000000
or $t1,$t1,$t2
addi $s1,$s1,-4
sw $t1,0($s1)
j label16 # skip function
label15:



addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-4

# getting a
add $t0,$s0,$zero
lw $t0,-4($t0)
addi $s1,$s1,-4
lw $t1,-8($t0)
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label13
beq $t1,$t3,label13
srl $t1,$t1,1
bne $t1,$t8,error
label12:addi $v0, $zero, 11 # str
lw $t1,0($t0)
beq $t1,$zero,label14
addi $a0,$t1,0
syscall
addi $t0,$t0,4
j label12 # continue printing charactters
label13:# int
addi $v0, $zero,1
add $a0,$t0,$zero
syscall
label14:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $0, 10
addi $v0, $0, 11 
syscall



# return whatever is on the top of stack
lw $t0,0($s0)
addi $t9,$zero,0
add $s1,$s0,$zero
add $s0,$zero,$t0
jr $ra
label16: # end of function

lw $t1,0($s1) # get value
addi $t0,$s0,-12 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# getting k
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-12($t0)
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
label18: # end of function

lw $t1,0($s1) # get value
addi $t0,$s0,-12 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : k is -16($s0)

# getting h
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-12($t0)
sw $t1,0($s1)

# assert type is alg
lw $t1,0($s1)
srl $t1,$t1,29
addi $t2,$zero,5
beq $t1,$t2,label19
j error # if wrong type
label19:# type check over

lw $t1, 0($s1)
li $t2,0x1FFFFFFF
and $t1, $t1, $t2
sw $t1, 0($s1)

# function called
sw $ra,-4($s1)
addi $s1,$s1,-4

# Getting Arguments

# first argument is the creator base, currently available in $t0
addi $s1,$s1,-4
sw $t0,0($s1)

# getting g
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-8($t0)
sw $t1,0($s1)

# Making a stack frame
addi $s1,$s1,8
lw $t2,4($s1)
lw $t1,0($s1)
sw $t1,4($s1)
sw $s0,0($s1)
add $s0,$s1,$zero
addi $s1,$s1,-8

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
addi $t0,$s0,-16 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# getting k
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label21
beq $t1,$t3,label21
srl $t1,$t1,1
bne $t1,$t8,error
label20:addi $v0, $zero, 11 # str
lw $t1,0($t0)
beq $t1,$zero,label22
addi $a0,$t1,0
syscall
addi $t0,$t0,4
j label20 # continue printing charactters
label21:# int
addi $v0, $zero,1
add $a0,$t0,$zero
syscall
label22:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $0, 10
addi $v0, $0, 11 
syscall

# Definition : x is -20($s0)

# int 2
addi $s1,$s1,-4
li $t1,2
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-20 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : y is -24($s0)

# getting g
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-8($t0)
sw $t1,0($s1)

# assert type is alg
lw $t1,0($s1)
srl $t1,$t1,29
addi $t2,$zero,5
beq $t1,$t2,label23
j error # if wrong type
label23:# type check over

lw $t1, 0($s1)
li $t2,0x1FFFFFFF
and $t1, $t1, $t2
sw $t1, 0($s1)

# function called
sw $ra,-4($s1)
addi $s1,$s1,-4

# Getting Arguments

# first argument is the creator base, currently available in $t0
addi $s1,$s1,-4
sw $t0,0($s1)



# Making a stack frame
addi $s1,$s1,4
lw $t2,4($s1)
lw $t1,0($s1)
sw $t1,4($s1)
sw $s0,0($s1)
add $s0,$s1,$zero
addi $s1,$s1,-4

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
addi $t0,$s0,-24 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack



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