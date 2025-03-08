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
addi $s1,$s0,-16

# Definition : f is -4($s0)

# Algorithm
jal pathfinder # find path of next line
addi $t1,$t1,24
li $t2,0xA0000000
or $t1,$t1,$t2
addi $s1,$s1,-4
sw $t1,0($s1)
j label2 # skip function
label1:

# L is -8($s0)

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-20

# Definition : x is -12($s0)

# Getting index
# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2 = t2*4
lw $t0,-8($s0) # load pointer value
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
add $t0,$t0,$t2 # get address
lw $t1,0($t0) # get value at index
sw $t1,0($s1) # replace index on stack with value

lw $t1,0($s1) # get value
addi $t0,$s0,-12 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : y is -16($s0)

# Getting index
# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2 = t2*4
lw $t0,-8($s0) # load pointer value
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
add $t0,$t0,$t2 # get address
lw $t1,0($t0) # get value at index
sw $t1,0($s1) # replace index on stack with value

lw $t1,0($s1) # get value
addi $t0,$s0,-16 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : z is -20($s0)

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-12($t0)
sw $t1,0($s1)

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
add $t1,$t1,$t2
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-20 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# Assignment
# Getting index
# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2=t2*4
lw $t0,-8($s0) # load pointer
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
lw $t1,4($s1) # load value to be assignment
add $t0,$t0,$t2 # get address on memory location
sw $t1,0($t0) # store value to address
addi $s1,$s1,8 #clear both index and value

# getting z
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1)

# Assignment
# Getting index
# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2=t2*4
lw $t0,-8($s0) # load pointer
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
lw $t1,4($s1) # load value to be assignment
add $t0,$t0,$t2 # get address on memory location
sw $t1,0($t0) # store value to address
addi $s1,$s1,8 #clear both index and value

# getting z
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
label2: # end of function

lw $t1,0($s1) # get value
addi $t0,$s0,-4 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : F is -8($s0)

# int 2
addi $s1,$s1,-4
li $t1,2
sw $t1,0($s1)

# list
add $t0,$s5,$zero
lw $t1,0($s1)
addi $t1,$t1,1
sll $t1,$t1,2
add $s5,$s5,$t1
sw $t0,0($s1)
sw $zero,-4($s5)

lw $t1,0($s1) # get value
addi $t0,$s0,-8 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

# Assignment
# Getting index
# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2=t2*4
lw $t0,-8($s0) # load pointer
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
lw $t1,4($s1) # load value to be assignment
add $t0,$t0,$t2 # get address on memory location
sw $t1,0($t0) # store value to address
addi $s1,$s1,8 #clear both index and value

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

# Assignment
# Getting index
# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2=t2*4
lw $t0,-8($s0) # load pointer
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
lw $t1,4($s1) # load value to be assignment
add $t0,$t0,$t2 # get address on memory location
sw $t1,0($t0) # store value to address
addi $s1,$s1,8 #clear both index and value

# Definition : i is -12($s0)

# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-12 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : ret is -16($s0)

label3_start: # while 

# getting i
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-12($t0)
sw $t1,0($s1)

# int 3
addi $s1,$s1,-4
li $t1,3
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
beq $t9,$zero,label3_end

# getting f
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-4($t0)
sw $t1,0($s1)

# assert type is alg
lw $t1,0($s1)
srl $t1,$t1,29
addi $t2,$zero,5
beq $t1,$t2,label4
j error # if wrong type
label4:# type check over

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

# getting F
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

# Assignment
# getting ret
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-16($t0)
addi $s1,$s1,4

# getting i
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-12($t0)
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
# getting i
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-12($t0)
addi $s1,$s1,4



j label3_start
label3_end: # end while

# Getting index
# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2 = t2*4
lw $t0,-8($s0) # load pointer value
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
add $t0,$t0,$t2 # get address
lw $t1,0($t0) # get value at index
sw $t1,0($s1) # replace index on stack with value

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label6
beq $t1,$t3,label6
srl $t1,$t1,1
bne $t1,$t8,error
label5:addi $v0, $zero, 11 # str
lw $t1,0($t0)
beq $t1,$zero,label7
addi $a0,$t1,0
syscall
addi $t0,$t0,4
j label5 # continue printing charactters
label6:# int
addi $v0, $zero,1
add $a0,$t0,$zero
syscall
label7:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $0, 10
addi $v0, $0, 11 
syscall

# Getting index
# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2 = t2*4
lw $t0,-8($s0) # load pointer value
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
add $t0,$t0,$t2 # get address
lw $t1,0($t0) # get value at index
sw $t1,0($s1) # replace index on stack with value

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label9
beq $t1,$t3,label9
srl $t1,$t1,1
bne $t1,$t8,error
label8:addi $v0, $zero, 11 # str
lw $t1,0($t0)
beq $t1,$zero,label10
addi $a0,$t1,0
syscall
addi $t0,$t0,4
j label8 # continue printing charactters
label9:# int
addi $v0, $zero,1
add $a0,$t0,$zero
syscall
label10:# end print
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