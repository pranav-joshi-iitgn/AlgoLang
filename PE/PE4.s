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
addi $s1,$s0,-32

jal pathfinder
addi $t1,$t1,16
li $t2,0x80000000
or $t1,$t1,$t2
sw $t1,-8($s0)

thestart:
addi $t8,$zero,1
addi $t9,$zero,1

# Definition : check is -16($s0)

# Algorithm
add $t2,$ra,$zero # save current ra
jal pathfinder # find path of next line
addi $t1,$t1,28 # address to start the function
add $ra,$t2,$zero # restore ra
li $t2,0x80000000
or $t1,$t1,$t2
addi $s1,$s1,-4
sw $t1,0($s1)
j label27 # skip function
label26:

# x is -16($s0)

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-32

# Definition : y is -20($s0)

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-20 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : n is -24($s0)

# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-24 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

label1_start: # while 

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
slt $t1,$t2,$t1
sw $t1,0($s1)
lw $t9,0($s1)
addi $s1,$s1,4
slt $t1,$zero,$t9
slt $t9,$t9,$zero
or $t9,$t9,$t1
beq $t9,$zero,label1_end

# getting n
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
beq $t3,$t4,label4
srl $t3,$t1,29
beq $t3,$t4,label4

# assume both types are int
add $t7,$zero,$zero # assume t1 is not a float
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label2
beq $t3,$zero,label2
addi $t7,$zero,1 # we know now that t1 is a float

label2: # t1 is int
srl $t3,$t2,29
beq $t3,$t4,label3
beq $t3,$zero,label3
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float3 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float3 # j to float addition

label3: # t2 is int
bne $t7,$zero,label_float_conv3 # if t1 was a float, jump to conversion

label_int3: # int addition
add $t1,$t1,$t2
j label5 # finish

label_float_conv3: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float3: # float addition
add.s $f1,$f1,$f2
mfc1 $t1,$f1
j label5 #finish


label4: # list
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
label_t1_5:
slt $t7,$zero,$t3 # t3 > 0
beq $t7,$zero,label_t2_5 # done adding
addi $t6,$t6,4
addi $t1,$t1,4
lw $t7,0($t1)
sw $t7,0($t6)
addi $t3,$t3,-4
j label_t1_5
label_t2_5: # add struff from second list
slt $t7,$zero,$t4 # t3 > 0
beq $t7,$zero,label_t2_end_5 # done adding
addi $t6,$t6,4
addi $t2,$t2,4
lw $t7,0($t2)
sw $t7,0($t6)
addi $t4,$t4,-4
j label_t2_5
label_t2_end_5: # end adding from 2nd list
add $t1,$t0,$zero

label5: # finish

sw $t1,0($s1)

# Assignment
# getting n
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-24($t0)
addi $s1,$s1,4

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1)

# int 10
addi $s1,$s1,-4
li $t1,10
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
div $t1,$t2
mfhi $t2
mflo $t1
sw $t1,0($s1)

# Assignment
# getting y
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-20($t0)
addi $s1,$s1,4



j label1_start
label1_end: # end while

# Definition : first is -28($s0)

# Definition : last is -32($s0)

label6_start: # while 

# getting n
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
slt $t1,$t2,$t1
sw $t1,0($s1)
lw $t9,0($s1)
addi $s1,$s1,4
slt $t1,$zero,$t9
slt $t9,$t9,$zero
or $t9,$t9,$t1
beq $t9,$zero,label6_end

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# int 10
addi $s1,$s1,-4
li $t1,10
sw $t1,0($s1)
 # getting n
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
beq $t3,$t4,label8
beq $t3,$zero,label8
addi $t7,$zero,1 # we know now that t1 is a float
label8: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label9
beq $t3,$zero,label9
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float9 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float9 # j to float subtraction

label9: # t2 is int
bne $t7,$zero,label_float_conv9 # if t1 was a float, jump to conversion

label_int9: # int subtraction
sub $t1,$t1,$t2
j label10 # finish

label_float_conv9: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float9: # float subtraction
sub.s $f1,$f1,$f2
mfc1 $t1,$f1

label10: # finish
sw $t1,0($s1)
 lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
# fast exponentiation
add $t4,$t8,$zero # t4 = 1
label11_loop:
beq $t2,$zero,label11_out
and $t3,$t2,$t8
beq $t3,$zero,label11_in
mult $t4,$t1
mflo $t4 # t4 = t4*t1
label11_in: # mult done
mult $t1,$t1
mflo $t1 # square
srl $t2,$t2,1
j label11_loop
label11_out:
add $t1,$t4,$zero
# end exponentiation
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
div $t1,$t2
mfhi $t2
mflo $t1
sw $t1,0($s1)

# Assignment
# getting first
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-28($t0)
addi $s1,$s1,4

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# int 10
addi $s1,$s1,-4
li $t1,10
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
div $t1,$t2
mflo $t2
mfhi $t1
sw $t1,0($s1)

# Assignment
# getting last
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-32($t0)
addi $s1,$s1,4

# Condition

# getting first
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-28($t0)
sw $t1,0($s1)

# getting last
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-32($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t3,$t1,$t2
slt $t2,$t2,$t1
or $t1,$t3,$t2
sub $t1,$t8,$t1
sw $t1,0($s1)

# <bound method LogicLiteral.op of LogicLiteral->not Comparison>
lw $t1,0($s1)
sub $t1,$t8,$t1
sw $t1,0($s1)

lw $t9,0($s1) #get result of condition
addi $s1,$s1,4 # delete a value
beq $t9,$zero,label14 # if

# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)
# return

# duplicate current stack frame on heap
# ignore the return value at top of stack

addi $t0,$s1,4 # initialise pointer
label12: # put a value on heap
slt $t3,$s0,$t0 # check if base is not reacged
beq $t3,$zero,label13 # if reached, stop
lw $t1,0($t0) # get value from stack
sw $t1,0($s5) # put value on heap
addi $t0,$t0,4 # move stack pointer
addi $s5,$s5,4 # move heap pointer
j label12 # repeat until all values are copied
label13:# finished putting value
lw $t1,-8($s0) # get self
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5 # address corresponding to self
sw $s0,4($t1) # store fake base

lw $t0,0($s0) # caller's base

lw $t1,0($s1) # return value
sw $t1,0($s0) # store return value at base
addi $t9,$zero,1 

add $s1,$s0,$zero # restore stack pointer
add $s0,$zero,$t0 # restore base pointer
jr $ra # return
# End of return




addi $t9,$zero,1
label14: # end if

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# int 10
addi $s1,$s1,-4
li $t1,10
sw $t1,0($s1)
 # getting n
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
beq $t3,$t4,label16
beq $t3,$zero,label16
addi $t7,$zero,1 # we know now that t1 is a float
label16: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label17
beq $t3,$zero,label17
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float17 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float17 # j to float subtraction

label17: # t2 is int
bne $t7,$zero,label_float_conv17 # if t1 was a float, jump to conversion

label_int17: # int subtraction
sub $t1,$t1,$t2
j label18 # finish

label_float_conv17: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float17: # float subtraction
sub.s $f1,$f1,$f2
mfc1 $t1,$f1

label18: # finish
sw $t1,0($s1)
 lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
# fast exponentiation
add $t4,$t8,$zero # t4 = 1
label19_loop:
beq $t2,$zero,label19_out
and $t3,$t2,$t8
beq $t3,$zero,label19_in
mult $t4,$t1
mflo $t4 # t4 = t4*t1
label19_in: # mult done
mult $t1,$t1
mflo $t1 # square
srl $t2,$t2,1
j label19_loop
label19_out:
add $t1,$t4,$zero
# end exponentiation
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
div $t1,$t2
mflo $t2
mfhi $t1
sw $t1,0($s1)

# int 10
addi $s1,$s1,-4
li $t1,10
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
div $t1,$t2
mfhi $t2
mflo $t1
sw $t1,0($s1)

# Assignment
# getting x
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-16($t0)
addi $s1,$s1,4

# getting n
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-24($t0)
sw $t1,0($s1)

# int 2
addi $s1,$s1,-4
li $t1,2
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
beq $t3,$t4,label21
beq $t3,$zero,label21
addi $t7,$zero,1 # we know now that t1 is a float
label21: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label22
beq $t3,$zero,label22
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float22 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float22 # j to float subtraction

label22: # t2 is int
bne $t7,$zero,label_float_conv22 # if t1 was a float, jump to conversion

label_int22: # int subtraction
sub $t1,$t1,$t2
j label23 # finish

label_float_conv22: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float22: # float subtraction
sub.s $f1,$f1,$f2
mfc1 $t1,$f1

label23: # finish
sw $t1,0($s1)

# Assignment
# getting n
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-24($t0)
addi $s1,$s1,4



j label6_start
label6_end: # end while

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)
# return

# duplicate current stack frame on heap
# ignore the return value at top of stack

addi $t0,$s1,4 # initialise pointer
label24: # put a value on heap
slt $t3,$s0,$t0 # check if base is not reacged
beq $t3,$zero,label25 # if reached, stop
lw $t1,0($t0) # get value from stack
sw $t1,0($s5) # put value on heap
addi $t0,$t0,4 # move stack pointer
addi $s5,$s5,4 # move heap pointer
j label24 # repeat until all values are copied
label25:# finished putting value
lw $t1,-8($s0) # get self
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5 # address corresponding to self
sw $s0,4($t1) # store fake base

lw $t0,0($s0) # caller's base

lw $t1,0($s1) # return value
sw $t1,0($s0) # store return value at base
addi $t9,$zero,1 

add $s1,$s0,$zero # restore stack pointer
add $s0,$zero,$t0 # restore base pointer
jr $ra # return
# End of return




# return whatever is on the top of stack
lw $t0,0($s0)
addi $t9,$zero,0
add $s1,$s0,$zero
add $s0,$zero,$t0
jr $ra
label27: # end of function

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

# Definition : x is -20($s0)

# int 999
addi $s1,$s1,-4
li $t1,999
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-20 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : biggest is -24($s0)

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-24 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : y is -28($s0)

# Definition : z is -32($s0)

label32_start: # while 

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1)

# int 99
addi $s1,$s1,-4
li $t1,99
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t1,$t2,$t1
sw $t1,0($s1)

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1)

# int 990
addi $s1,$s1,-4
li $t1,990
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
beq $t3,$t4,label29
beq $t3,$zero,label29
addi $t7,$zero,1 # we know now that t1 is a float
label29: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label30
beq $t3,$zero,label30
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float30 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float30 # j to float operation

label30: # t2 is int
bne $t7,$zero,label_float_conv30 # if t1 was a float, jump to conversion

label_int30: # int multiplication
mult $t1,$t2
mflo $t1
mfhi $t2
j label31 # finish

label_float_conv30: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float30: # float multiplication
mul.s $f1,$f1,$f2
mfc1 $t1,$f1

label31: # finish
sw $t1,0($s1)

# getting biggest
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-24($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t1,$t2,$t1
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
and $t1,$t1,$t2
sw $t1,0($s1)
lw $t9,0($s1)
addi $s1,$s1,4
slt $t1,$zero,$t9
slt $t9,$t9,$zero
or $t9,$t9,$t1
beq $t9,$zero,label32_end

# int 990
addi $s1,$s1,-4
li $t1,990
sw $t1,0($s1)

# Assignment
# getting y
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-28($t0)
addi $s1,$s1,4

label33_start: # while 

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-28($t0)
sw $t1,0($s1)

# int 99
addi $s1,$s1,-4
li $t1,99
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t1,$t2,$t1
sw $t1,0($s1)
lw $t9,0($s1)
addi $s1,$s1,4
slt $t1,$zero,$t9
slt $t9,$t9,$zero
or $t9,$t9,$t1
beq $t9,$zero,label33_end

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1)

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-28($t0)
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
beq $t3,$t4,label35
beq $t3,$zero,label35
addi $t7,$zero,1 # we know now that t1 is a float
label35: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label36
beq $t3,$zero,label36
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float36 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float36 # j to float operation

label36: # t2 is int
bne $t7,$zero,label_float_conv36 # if t1 was a float, jump to conversion

label_int36: # int multiplication
mult $t1,$t2
mflo $t1
mfhi $t2
j label37 # finish

label_float_conv36: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float36: # float multiplication
mul.s $f1,$f1,$f2
mfc1 $t1,$f1

label37: # finish
sw $t1,0($s1)

# Assignment
# getting z
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-32($t0)
addi $s1,$s1,4

# Condition

# getting check
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1) 
# assert type is alg
lw $t1,0($s1)
srl $t1,$t1,29
addi $t2,$zero,4
beq $t1,$t2,label38
j error # if wrong type
label38:# type check over 

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

# third is the stack base of fake parent, initially 0
addi $s1,$s1,-4
# lw $t2,-8($t0)
# sw $t2,0($s1)
sw $zero,0($s1)

# All other arguments
# getting z
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-32($t0)
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


# getting z
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-32($t0)
sw $t1,0($s1)

# getting biggest
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-24($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t1,$t2,$t1
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
and $t1,$t1,$t2
sw $t1,0($s1)

lw $t9,0($s1) #get result of condition
addi $s1,$s1,4 # delete a value
beq $t9,$zero,label39 # if

# getting z
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-32($t0)
sw $t1,0($s1)

# Assignment
# getting biggest
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-24($t0)
addi $s1,$s1,4

addi $t9,$zero,1
j label33_end



addi $t9,$zero,1
label39: # end if

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-28($t0)
sw $t1,0($s1)

# int 11
addi $s1,$s1,-4
li $t1,11
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
beq $t3,$t4,label41
beq $t3,$zero,label41
addi $t7,$zero,1 # we know now that t1 is a float
label41: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label42
beq $t3,$zero,label42
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float42 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float42 # j to float subtraction

label42: # t2 is int
bne $t7,$zero,label_float_conv42 # if t1 was a float, jump to conversion

label_int42: # int subtraction
sub $t1,$t1,$t2
j label43 # finish

label_float_conv42: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float42: # float subtraction
sub.s $f1,$f1,$f2
mfc1 $t1,$f1

label43: # finish
sw $t1,0($s1)

# Assignment
# getting y
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-28($t0)
addi $s1,$s1,4



j label33_start
label33_end: # end while

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1)

# int 1
addi $s1,$s1,-4
li $t1,1
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
beq $t3,$t4,label45
beq $t3,$zero,label45
addi $t7,$zero,1 # we know now that t1 is a float
label45: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label46
beq $t3,$zero,label46
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float46 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float46 # j to float subtraction

label46: # t2 is int
bne $t7,$zero,label_float_conv46 # if t1 was a float, jump to conversion

label_int46: # int subtraction
sub $t1,$t1,$t2
j label47 # finish

label_float_conv46: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float46: # float subtraction
sub.s $f1,$f1,$f2
mfc1 $t1,$f1

label47: # finish
sw $t1,0($s1)

# Assignment
# getting x
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-20($t0)
addi $s1,$s1,4



j label32_start
label32_end: # end while

# getting biggest
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-24($t0)
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
addi $t4,$zero,4
beq $t1,$zero,label50 # 000 -> int
beq $t1,$t3,label50 # 111 -> int
beq $t1,$t4,label_alg50 # 100 -> alg .. printed as int
addi $t3,$zero,3
bne $t1,$t3,label49 # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label48: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label51 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label48 # continue printing characters

label49:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label51

label_alg50:#print alg
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
j label51


label50:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label51:# end print
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
