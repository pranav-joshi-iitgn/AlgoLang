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
addi $s1,$s0,-20

jal pathfinder
addi $t1,$t1,16
li $t2,0x80000000
or $t1,$t1,$t2
sw $t1,-8($s0)

thestart:
addi $t8,$zero,1
addi $t9,$zero,1

# Definition : x is -16($s0)

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-16 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Condition

# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)

lw $t9,0($s1) #get result of condition
addi $s1,$s1,4 # delete a value
beq $t9,$zero,label1 # if



addi $t9,$zero,1
label1: # end if

# else
bne $t9,$zero,label10

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
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

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label8 # 000 -> int
beq $t1,$t3,label8 # 111 -> int
addi $t3,$zero,3
bne $t1,$t3,label7 # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label6: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label9 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label6 # continue printing characters

label7:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label9

label8:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label9:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $zero, 10
addi $v0, $zero, 11 
syscall




addi $t9,$zero,1
label10: # end else

# else
bne $t9,$zero,label15

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label13 # 000 -> int
beq $t1,$t3,label13 # 111 -> int
addi $t3,$zero,3
bne $t1,$t3,label12 # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label11: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label14 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label11 # continue printing characters

label12:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label14

label13:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label14:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $zero, 10
addi $v0, $zero, 11 
syscall




addi $t9,$zero,1
label15: # end else

# Definition : i is -20($s0)

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-20 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

label16_start: # while 

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)
lw $t9,0($s1)
addi $s1,$s1,4
slt $t1,$zero,$t9
slt $t9,$t9,$zero
or $t9,$t9,$t1
beq $t9,$zero,label16_end

# Condition

# getting i
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
slt $t1,$t2,$t1
sw $t1,0($s1)

lw $t9,0($s1) #get result of condition
addi $s1,$s1,4 # delete a value
beq $t9,$zero,label17 # if

addi $t9,$zero,1
j label16_end



addi $t9,$zero,1
label17: # end if

# Condition

# getting i
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
slt $t3,$t1,$t2
slt $t2,$t2,$t1
or $t1,$t3,$t2
sub $t1,$t8,$t1
sw $t1,0($s1)

lw $t9,0($s1) #get result of condition
addi $s1,$s1,4 # delete a value
beq $t9,$zero,label22 # if

# getting i
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
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
beq $t3,$t4,label19
beq $t3,$zero,label19
addi $t7,$zero,1 # we know now that t1 is a float
label19: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label20
beq $t3,$zero,label20
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float20 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float20 # j to float operation

label20: # t2 is int
bne $t7,$zero,label_float_conv20 # if t1 was a float, jump to conversion

label_int20: # int multiplication
mult $t1,$t2
mflo $t1
mfhi $t2
j label21 # finish

label_float_conv20: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float20: # float multiplication
mul.s $f1,$f1,$f2
mfc1 $t1,$f1

label21: # finish
sw $t1,0($s1)

# Assignment
# getting i
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-20($t0)
addi $s1,$s1,4

j label16_start



addi $t9,$zero,1
label22: # end if

# getting i
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
# if t1 is a list or t2 is a list, then jump
addi $t4,$zero,3
srl $t3,$t2,29
beq $t3,$t4,label25
srl $t3,$t1,29
beq $t3,$t4,label25

# assume both types are int
add $t7,$zero,$zero # assume t1 is not a float
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label23
beq $t3,$zero,label23
addi $t7,$zero,1 # we know now that t1 is a float

label23: # t1 is int
srl $t3,$t2,29
beq $t3,$t4,label24
beq $t3,$zero,label24
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float24 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float24 # j to float addition

label24: # t2 is int
bne $t7,$zero,label_float_conv24 # if t1 was a float, jump to conversion

label_int24: # int addition
add $t1,$t1,$t2
j label26 # finish

label_float_conv24: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float24: # float addition
add.s $f1,$f1,$f2
mfc1 $t1,$f1
j label26 #finish


label25: # list
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
label_t1_26:
slt $t7,$zero,$t3 # t3 > 0
beq $t7,$zero,label_t2_26 # done adding
addi $t6,$t6,4
addi $t1,$t1,4
lw $t7,0($t1)
sw $t7,0($t6)
addi $t3,$t3,-4
j label_t1_26
label_t2_26: # add struff from second list
slt $t7,$zero,$t4 # t3 > 0
beq $t7,$zero,label_t2_end_26 # done adding
addi $t6,$t6,4
addi $t2,$t2,4
lw $t7,0($t2)
sw $t7,0($t6)
addi $t4,$t4,-4
j label_t2_26
label_t2_end_26: # end adding from 2nd list
add $t1,$t0,$zero

label26: # finish

sw $t1,0($s1)

# Assignment
# getting i
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-20($t0)
addi $s1,$s1,4



j label16_start
label16_end: # end while

# getting i
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label29 # 000 -> int
beq $t1,$t3,label29 # 111 -> int
addi $t3,$zero,3
bne $t1,$t3,label28 # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label27: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label30 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label27 # continue printing characters

label28:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label30

label29:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label30:# end print
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
