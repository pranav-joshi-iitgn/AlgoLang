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

# Definition : f is -16($s0)

# Algorithm
add $t2,$ra,$zero # save current ra
jal pathfinder # find path of next line
addi $t1,$t1,28 # address to start the function
add $ra,$t2,$zero # restore ra
li $t2,0x80000000
or $t1,$t1,$t2
addi $s1,$s1,-4
sw $t1,0($s1)
j label6 # skip function
label5:

# L is -16($s0)

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-28

# Definition : x is -20($s0)

# Getting index
# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2 = t2*4
lw $t0,-16($s0) # load pointer value
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
add $t0,$t2,$t0 # get address
addi $t0,$t0,4 # still getting address..
lw $t1,0($t0) # get value at index
sw $t1,0($s1) # replace index on stack with valu


lw $t1,0($s1) # get value
addi $t0,$s0,-20 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : y is -24($s0)

# Getting index
# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2 = t2*4
lw $t0,-16($s0) # load pointer value
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
add $t0,$t2,$t0 # get address
addi $t0,$t0,4 # still getting address..
lw $t1,0($t0) # get value at index
sw $t1,0($s1) # replace index on stack with valu


lw $t1,0($s1) # get value
addi $t0,$s0,-24 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : z is -28($s0)

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1)

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-24($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
# if t1 is a list or t2 is a list, then jump
addi $t4,$zero,3
srl $t3,$t2,29
beq $t3,$t4,label3
srl $t3,$t1,29
beq $t3,$t4,label3

# assume both types are int
add $t7,$zero,$zero # assume t1 is not a float
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label1
beq $t3,$zero,label1
addi $t7,$zero,1 # we know now that t1 is a float

label1: # t1 is int
srl $t3,$t2,29
beq $t3,$t4,label2
beq $t3,$zero,label2
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float2 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float2 # j to float addition

label2: # t2 is int
bne $t7,$zero,label_float_conv2 # if t1 was a float, jump to conversion

label_int2: # int addition
add $t1,$t1,$t2
j label4 # finish

label_float_conv2: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float2: # float addition
add.s $f1,$f1,$f2
mfc1 $t1,$f1
j label4 #finish


label3: # list
# concatenate lists
lw $t3,0($t1) # 4*n1
lw $t4,0($t2) # 4*n2
add $t5,$t3,$t4 # 4*(n1+n2)
add $t0,$s5,$zero # our new thing to return
add $s5,$s5,$t5 # s5 += 4*(n1+n2)
addi $s5,$s5,4 # s5 += 4
sw $t5,0($t0) # store size first
add $t6,$t0,$zero
# Add stuff from first list to new allocated space
label_t1_4:
slt $t7,$zero,$t3 # t3 > 0
beq $t7,$zero,label_t2_4 # done adding
addi $t6,$t6,4
addi $t1,$t1,4
lw $t7,0($t1)
sw $t7,0($t6)
addi $t3,$t3,-4
j label_t1_4
label_t2_4: # add struff from second list
slt $t7,$zero,$t4 # t3 > 0
beq $t7,$zero,label_t2_end_4 # done adding
addi $t6,$t6,4
addi $t2,$t2,4
lw $t7,0($t2)
sw $t7,0($t6)
addi $t4,$t4,-4
j label_t2_4
label_t2_end_4: # end adding from 2nd list
add $t1,$t0,$zero

label4: # finish

sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-28 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-24($t0)
sw $t1,0($s1)

# Assignment
# Getting index
# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2=t2*4
lw $t0,-16($s0) # load pointer
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
lw $t1,4($s1) # load value to be assignment
add $t0,$t2,$t0 # get address on memory location
addi $t0,$t0,4 # still getting address..
sw $t1,0($t0) # store value to address
addi $s1,$s1,8 #clear both index and value

# getting z
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-28($t0)
sw $t1,0($s1)

# Assignment
# Getting index
# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2=t2*4
lw $t0,-16($s0) # load pointer
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
lw $t1,4($s1) # load value to be assignment
add $t0,$t2,$t0 # get address on memory location
addi $t0,$t0,4 # still getting address..
sw $t1,0($t0) # store value to address
addi $s1,$s1,8 #clear both index and value

# getting z
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-28($t0)
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
label6: # end of function

# Add this to parent pointer tree
lw $t2,-8($s0) # parent
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5
sw $t2,0($t1) # child -> parent


lw $t1,0($s1) # get value
addi $t0,$s0,-16 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : F is -20($s0)

# int 2
addi $s1,$s1,-4
li $t1,2
sw $t1,0($s1)

# list
add $t0,$s5,$zero
lw $t1,0($s1) # n
sll $t1,$t1,2 # 4n
addi $t2,$t1,4 # 4n+4
add $s5,$s5,$t2 # inc $s5 by 4n+4
sw $t0,0($s1) # store pointer on stack
sw $t1,0($t0) # store 4n as first thing

lw $t1,0($s1) # get value
addi $t0,$s0,-20 # load variable address
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
lw $t0,-20($s0) # load pointer
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
lw $t1,4($s1) # load value to be assignment
add $t0,$t2,$t0 # get address on memory location
addi $t0,$t0,4 # still getting address..
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
lw $t0,-20($s0) # load pointer
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
lw $t1,4($s1) # load value to be assignment
add $t0,$t2,$t0 # get address on memory location
addi $t0,$t0,4 # still getting address..
sw $t1,0($t0) # store value to address
addi $s1,$s1,8 #clear both index and value

# Definition : i is -24($s0)

# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-24 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : ret is -28($s0)

# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-28 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

label7_start: # while 

# getting i
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-24($t0)
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
beq $t9,$zero,label7_end

# getting f
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1) 
# assert type is alg
lw $t1,0($s1)
srl $t1,$t1,29
addi $t2,$zero,4
beq $t1,$t2,label8
j error # if wrong type
label8:# type check over 

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
# getting F
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
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


# Assignment
# getting ret
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-28($t0)
addi $s1,$s1,4

# getting i
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-24($t0)
sw $t1,0($s1)

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
# if t1 is a list or t2 is a list, then jump
addi $t4,$zero,3
srl $t3,$t2,29
beq $t3,$t4,label11
srl $t3,$t1,29
beq $t3,$t4,label11

# assume both types are int
add $t7,$zero,$zero # assume t1 is not a float
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label9
beq $t3,$zero,label9
addi $t7,$zero,1 # we know now that t1 is a float

label9: # t1 is int
srl $t3,$t2,29
beq $t3,$t4,label10
beq $t3,$zero,label10
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float10 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float10 # j to float addition

label10: # t2 is int
bne $t7,$zero,label_float_conv10 # if t1 was a float, jump to conversion

label_int10: # int addition
add $t1,$t1,$t2
j label12 # finish

label_float_conv10: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float10: # float addition
add.s $f1,$f1,$f2
mfc1 $t1,$f1
j label12 #finish


label11: # list
# concatenate lists
lw $t3,0($t1) # 4*n1
lw $t4,0($t2) # 4*n2
add $t5,$t3,$t4 # 4*(n1+n2)
add $t0,$s5,$zero # our new thing to return
add $s5,$s5,$t5 # s5 += 4*(n1+n2)
addi $s5,$s5,4 # s5 += 4
sw $t5,0($t0) # store size first
add $t6,$t0,$zero
# Add stuff from first list to new allocated space
label_t1_12:
slt $t7,$zero,$t3 # t3 > 0
beq $t7,$zero,label_t2_12 # done adding
addi $t6,$t6,4
addi $t1,$t1,4
lw $t7,0($t1)
sw $t7,0($t6)
addi $t3,$t3,-4
j label_t1_12
label_t2_12: # add struff from second list
slt $t7,$zero,$t4 # t3 > 0
beq $t7,$zero,label_t2_end_12 # done adding
addi $t6,$t6,4
addi $t2,$t2,4
lw $t7,0($t2)
sw $t7,0($t6)
addi $t4,$t4,-4
j label_t2_12
label_t2_end_12: # end adding from 2nd list
add $t1,$t0,$zero

label12: # finish

sw $t1,0($s1)

# Assignment
# getting i
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-24($t0)
addi $s1,$s1,4



j label7_start
label7_end: # end while

# Getting index
# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2 = t2*4
lw $t0,-20($s0) # load pointer value
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
add $t0,$t2,$t0 # get address
addi $t0,$t0,4 # still getting address..
lw $t1,0($t0) # get value at index
sw $t1,0($s1) # replace index on stack with valu


# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label15 # 000 -> int
beq $t1,$t3,label15 # 111 -> int
addi $t3,$zero,3
bne $t1,$t3,label14 # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label13: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label16 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label13 # continue printing characters

label14:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label16

label15:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label16:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $zero, 10
addi $v0, $zero, 11 
syscall


# Getting index
# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2 = t2*4
lw $t0,-20($s0) # load pointer value
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
add $t0,$t2,$t0 # get address
addi $t0,$t0,4 # still getting address..
lw $t1,0($t0) # get value at index
sw $t1,0($s1) # replace index on stack with valu


# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label19 # 000 -> int
beq $t1,$t3,label19 # 111 -> int
addi $t3,$zero,3
bne $t1,$t3,label18 # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label17: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label20 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label17 # continue printing characters

label18:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label20

label19:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label20:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $zero, 10
addi $v0, $zero, 11 
syscall




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
