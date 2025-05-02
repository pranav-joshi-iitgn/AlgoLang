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
addi $s1,$s0,-28

jal pathfinder
addi $t1,$t1,16
li $t2,0x80000000
or $t1,$t1,$t2
sw $t1,-8($s0)

thestart:
addi $t8,$zero,1
addi $t9,$zero,1

# Definition : gcd is -16($s0)

# Algorithm
add $t2,$ra,$zero # save current ra
jal pathfinder # find path of next line
add $ra,$t2,$zero # restore ra
addi $t1,$t1,28 # address to start the function
li $t2,0x80000000
or $t1,$t1,$t2
addi $s1,$s1,-4
sw $t1,0($s1)
j label9 # skip function
label8:

# x is -16($s0)
# y is -20($s0)

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-20

# Condition

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
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

lw $t9,0($s1) #get result of condition
addi $s1,$s1,4 # delete a value
beq $t9,$zero,label3 # if

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)
# return

# duplicate current stack frame on heap
# ignore the return value at top of stack

addi $t0,$s1,4 # initialise pointer
label1: # put a value on heap
sgt $t3,$t0,$s0 # check if base is crossed, which happens when $t0 > $s0
bne $t3,$zero,label2 # if crossed, stop
lw $t1,0($t0) # get value from stack
sw $t1,0($s5) # put value on heap
addi $t0,$t0,4 # move stack pointer
addi $s5,$s5,4 # move heap pointer
j label1 # repeat until all values are copied
label2:# finished putting value
lw $t1,-8($s0) # get self
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5 # address corresponding to self
addi $s4,$s5,-4
sw $s4,4($t1) # store fake base

lw $t0,0($s0) # caller's base

lw $t1,0($s1) # return value
sw $t1,0($s0) # store return value at base
addi $t9,$zero,1 

add $s1,$s0,$zero # restore stack pointer
add $s0,$zero,$t0 # restore base pointer
jr $ra # return
# End of return




addi $t9,$zero,1
label3: # end if

# getting gcd
add $t0,$s0,$zero
add $t4,$zero,$t0 # make a copy
lw $t0,-12($t0) # fake parent stack
bne $t0,$zero,label4 # even the fake parent is dead .. 1 
li $t5,0x7F000000
li $t6,0x1FFFFFFF
lw $t1,-8($t4) # self
and $t1,$t1,$t6
or $t1,$t1,$t5
lw $t2,0($t1) # parent
lw $t0,-4($t4)
lw $t3,-8($t0) # self_new
beq $t3,$t2,label4
and $t2,$t2,$t6
or $t2,$t2,$t5
lw $t0,4($t2) # depend on fake parent
beq $t0,$zero,error # even the fake parent is dead ... 2
sw $t0,-12($t4) # update the fake parent
label4:# creator alive checking over
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1) 
# assert type is alg
lw $t1,0($s1)
srl $t1,$t1,29
addi $t2,$zero,4
beq $t1,$t2,label5
j error # if wrong type
label5:# type check over 
lw $t1, 0($s1)

#li $t2,0x1FFFFFFF
#and $t3, $t1, $t2
#sw $t3, 0($s1)

# function called
sw $ra,0($s1) #sw $ra,-4($s1)
addi $s1,$s1,-4
sw $s0,0($s1) #

# Getting Arguments

# first argument is the creator base, currently available in $t0
addi $s1,$s1,-4
sw $t0,0($s1)

# second is the value of this function, currently available in $t1
addi $s1,$s1,-4
sw $t1,0($s1)

# third is the stack base of fake parent, initially 0
addi $s1,$s1,-4
sw $zero,0($s1)

# All other arguments
# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1)

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
div $t1,$t2
mflo $t2
mfhi $t1
sw $t1,0($s1)

# Making a stack frame
addi $s1,$s1,20
lw $t1,-8($s1) #lw $t2,4($s1)
li $t2,0x1FFFFFFF #lw $t1,0($s1)
and $t2, $t1, $t2 #sw $t1,4($s1)
#sw $s0,0($s1)
add $s0,$s1,$zero
addi $s1,$s1,-20

# jumping to the function
jal pathfinder
addi $ra,$t1,8 # $ra points to the next to next instruction
jr $t2

# getting the return value
lw $t1,0($s1)
addi $s1,$s1,4
lw $ra,0($s1)
sw $t1,0($s1)

# return

# duplicate current stack frame on heap
# ignore the return value at top of stack

addi $t0,$s1,4 # initialise pointer
label6: # put a value on heap
sgt $t3,$t0,$s0 # check if base is crossed, which happens when $t0 > $s0
bne $t3,$zero,label7 # if crossed, stop
lw $t1,0($t0) # get value from stack
sw $t1,0($s5) # put value on heap
addi $t0,$t0,4 # move stack pointer
addi $s5,$s5,4 # move heap pointer
j label6 # repeat until all values are copied
label7:# finished putting value
lw $t1,-8($s0) # get self
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5 # address corresponding to self
addi $s4,$s5,-4
sw $s4,4($t1) # store fake base

lw $t0,0($s0) # caller's base

lw $t1,0($s1) # return value
sw $t1,0($s0) # store return value at base
addi $t9,$zero,1 

add $s1,$s0,$zero # restore stack pointer
add $s0,$zero,$t0 # restore base pointer
jr $ra # return
# End of return




# return
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
sw $zero,4($t1) # child has null as its copy, since it's not dead yet


lw $t1,0($s1) # get value
addi $t0,$s0,-16 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : lcm is -20($s0)

# Algorithm
add $t2,$ra,$zero # save current ra
jal pathfinder # find path of next line
add $ra,$t2,$zero # restore ra
addi $t1,$t1,28 # address to start the function
li $t2,0x80000000
or $t1,$t1,$t2
addi $s1,$s1,-4
sw $t1,0($s1)
j label19 # skip function
label18:

# x is -16($s0)
# y is -20($s0)

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-24

# Definition : g is -24($s0)

# getting gcd
add $t0,$s0,$zero
add $t4,$zero,$t0 # make a copy
lw $t0,-12($t0) # fake parent stack
bne $t0,$zero,label10 # even the fake parent is dead .. 1 
li $t5,0x7F000000
li $t6,0x1FFFFFFF
lw $t1,-8($t4) # self
and $t1,$t1,$t6
or $t1,$t1,$t5
lw $t2,0($t1) # parent
lw $t0,-4($t4)
lw $t3,-8($t0) # self_new
beq $t3,$t2,label10
and $t2,$t2,$t6
or $t2,$t2,$t5
lw $t0,4($t2) # depend on fake parent
beq $t0,$zero,error # even the fake parent is dead ... 2
sw $t0,-12($t4) # update the fake parent
label10:# creator alive checking over
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1) 
# assert type is alg
lw $t1,0($s1)
srl $t1,$t1,29
addi $t2,$zero,4
beq $t1,$t2,label11
j error # if wrong type
label11:# type check over 
lw $t1, 0($s1)

#li $t2,0x1FFFFFFF
#and $t3, $t1, $t2
#sw $t3, 0($s1)

# function called
sw $ra,0($s1) #sw $ra,-4($s1)
addi $s1,$s1,-4
sw $s0,0($s1) #

# Getting Arguments

# first argument is the creator base, currently available in $t0
addi $s1,$s1,-4
sw $t0,0($s1)

# second is the value of this function, currently available in $t1
addi $s1,$s1,-4
sw $t1,0($s1)

# third is the stack base of fake parent, initially 0
addi $s1,$s1,-4
sw $zero,0($s1)

# All other arguments
# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1)

# Making a stack frame
addi $s1,$s1,20
lw $t1,-8($s1) #lw $t2,4($s1)
li $t2,0x1FFFFFFF #lw $t1,0($s1)
and $t2, $t1, $t2 #sw $t1,4($s1)
#sw $s0,0($s1)
add $s0,$s1,$zero
addi $s1,$s1,-20

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

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# getting g
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-24($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
div $t1,$t2
mfhi $t2
mflo $t1
sw $t1,0($s1)

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
# # if t1 is a list or t2 is a list, then throw an error
# addi $t4,$zero,3
# srl $t3,$t2,29
# beq $t3,$t4,error
# srl $t3,$t1,29
# beq $t3,$t4,error

# assume t1 is an int
add $t7,$zero,$zero 
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label13
beq $t3,$zero,label13
addi $t7,$zero,1 # we know now that t1 is a float
label13: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label14
beq $t3,$zero,label14
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float14 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float14 # j to float operation

label14: # t2 is int
bne $t7,$zero,label_float_conv14 # if t1 was a float, jump to conversion

label_int14: # int multiplication
mult $t1,$t2
mflo $t1
mfhi $t2
j label15 # finish

label_float_conv14: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float14: # float multiplication
mul.s $f1,$f1,$f2
mfc1 $t1,$f1

label15: # finish
sw $t1,0($s1)
# return

# duplicate current stack frame on heap
# ignore the return value at top of stack

addi $t0,$s1,4 # initialise pointer
label16: # put a value on heap
sgt $t3,$t0,$s0 # check if base is crossed, which happens when $t0 > $s0
bne $t3,$zero,label17 # if crossed, stop
lw $t1,0($t0) # get value from stack
sw $t1,0($s5) # put value on heap
addi $t0,$t0,4 # move stack pointer
addi $s5,$s5,4 # move heap pointer
j label16 # repeat until all values are copied
label17:# finished putting value
lw $t1,-8($s0) # get self
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5 # address corresponding to self
addi $s4,$s5,-4
sw $s4,4($t1) # store fake base

lw $t0,0($s0) # caller's base

lw $t1,0($s1) # return value
sw $t1,0($s0) # store return value at base
addi $t9,$zero,1 

add $s1,$s0,$zero # restore stack pointer
add $s0,$zero,$t0 # restore base pointer
jr $ra # return
# End of return




# return
lw $t0,0($s0)
addi $t9,$zero,0
add $s1,$s0,$zero
add $s0,$zero,$t0
jr $ra
label19: # end of function

# Add this to parent pointer tree
lw $t2,-8($s0) # parent
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5
sw $t2,0($t1) # child -> parent
sw $zero,4($t1) # child has null as its copy, since it's not dead yet


lw $t1,0($s1) # get value
addi $t0,$s0,-20 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : x is -24($s0)

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-24 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : l is -28($s0)

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-28 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

label20_start: # while 

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-24($t0)
sw $t1,0($s1)

# int 20
addi $s1,$s1,-4
li $t1,20
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t1,$t2,$t1
sub $t1,$t8,$t1
sw $t1,0($s1)
lw $t9,0($s1)
addi $s1,$s1,4
slt $t1,$zero,$t9
slt $t9,$t9,$zero
or $t9,$t9,$t1
beq $t9,$zero,label20_end

# getting lcm
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1) 
# assert type is alg
lw $t1,0($s1)
srl $t1,$t1,29
addi $t2,$zero,4
beq $t1,$t2,label21
j error # if wrong type
label21:# type check over 
lw $t1, 0($s1)

#li $t2,0x1FFFFFFF
#and $t3, $t1, $t2
#sw $t3, 0($s1)

# function called
sw $ra,0($s1) #sw $ra,-4($s1)
addi $s1,$s1,-4
sw $s0,0($s1) #

# Getting Arguments

# first argument is the creator base, currently available in $t0
addi $s1,$s1,-4
sw $t0,0($s1)

# second is the value of this function, currently available in $t1
addi $s1,$s1,-4
sw $t1,0($s1)

# third is the stack base of fake parent, initially 0
addi $s1,$s1,-4
sw $zero,0($s1)

# All other arguments
# getting l
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-28($t0)
sw $t1,0($s1)

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-24($t0)
sw $t1,0($s1)

# Making a stack frame
addi $s1,$s1,20
lw $t1,-8($s1) #lw $t2,4($s1)
li $t2,0x1FFFFFFF #lw $t1,0($s1)
and $t2, $t1, $t2 #sw $t1,4($s1)
#sw $s0,0($s1)
add $s0,$s1,$zero
addi $s1,$s1,-20

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
# getting l
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-28($t0)
addi $s1,$s1,4

# getting x
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
beq $t3,$t4,label24
srl $t3,$t1,29
beq $t3,$t4,label24

# assume both types are int
add $t7,$zero,$zero # assume t1 is not a float
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label22
beq $t3,$zero,label22
addi $t7,$zero,1 # we know now that t1 is a float

label22: # t1 is int
srl $t3,$t2,29
beq $t3,$t4,label23
beq $t3,$zero,label23
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float23 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float23 # j to float addition

label23: # t2 is int
bne $t7,$zero,label_float_conv23 # if t1 was a float, jump to conversion

label_int23: # int addition
add $t1,$t1,$t2
j label25 # finish

label_float_conv23: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float23: # float addition
add.s $f1,$f1,$f2
mfc1 $t1,$f1
j label25 #finish


label24: # list
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
label_t1_25:
slt $t7,$zero,$t3 # t3 > 0
beq $t7,$zero,label_t2_25 # done adding
addi $t6,$t6,4
addi $t1,$t1,4
lw $t7,0($t1)
sw $t7,0($t6)
addi $t3,$t3,-4
j label_t1_25
label_t2_25: # add struff from second list
slt $t7,$zero,$t4 # t3 > 0
beq $t7,$zero,label_t2_end_25 # done adding
addi $t6,$t6,4
addi $t2,$t2,4
lw $t7,0($t2)
sw $t7,0($t6)
addi $t4,$t4,-4
j label_t2_25
label_t2_end_25: # end adding from 2nd list
add $t1,$t0,$zero

label25: # finish

sw $t1,0($s1)

# Assignment
# getting x
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-24($t0)
addi $s1,$s1,4



j label20_start
label20_end: # end while

# getting l
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-28($t0)
sw $t1,0($s1)

# Print
lw $t0,0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
addi $t4,$zero,4
beq $t1,$zero,label28 # 000 -> int
beq $t1,$t3,label28 # 111 -> int
beq $t1,$t4,label_alg28 # 100 -> alg .. printed as int
addi $t3,$zero,3
bne $t1,$t3,label27 # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label26: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label29 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label26 # continue printing characters

label27:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label29

label_alg28:#print alg
addi $v0,$zero,11
addi $a0,$zero,'a'
syscall
addi $a0,$zero,'l'
syscall
addi $a0,$zero,'g'
syscall
addi $a0,$zero,' '
syscall
addi $a0,$zero,'a'
syscall
addi $a0,$zero,'t'
syscall
addi $a0,$zero,' '
syscall
addi $v0,$zero,1
add $a0,$t0,$zero
syscall
j label29


label28:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label29:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0,$zero,10
addi $v0,$zero,11 
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
