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
addi $s1,$s0,-24

jal pathfinder
addi $t1,$t1,16
li $t2,0x80000000
or $t1,$t1,$t2
sw $t1,-8($s0)

thestart:
addi $t8,$zero,1
addi $t9,$zero,1

# Definition : n is -16($s0)

# int 100
addi $s1,$s1,-4
li $t1,100
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-16 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : S is -20($s0)

# getting n
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# getting n
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
beq $t3,$t4,label6
beq $t3,$zero,label6
addi $t7,$zero,1 # we know now that t1 is a float
label6: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label7
beq $t3,$zero,label7
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float7 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float7 # j to float operation

label7: # t2 is int
bne $t7,$zero,label_float_conv7 # if t1 was a float, jump to conversion

label_int7: # int multiplication
mult $t1,$t2
mflo $t1
mfhi $t2
j label8 # finish

label_float_conv7: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float7: # float multiplication
mul.s $f1,$f1,$f2
mfc1 $t1,$f1

label8: # finish
sw $t1,0($s1)

# int 2
addi $s1,$s1,-4
li $t1,2
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
div $t1,$t2
mflo $t1
mfhi $t2
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-20 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : S2 is -24($s0)

# getting n
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# getting n
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
beq $t3,$t4,label14
beq $t3,$zero,label14
addi $t7,$zero,1 # we know now that t1 is a float
label14: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label15
beq $t3,$zero,label15
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float15 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float15 # j to float operation

label15: # t2 is int
bne $t7,$zero,label_float_conv15 # if t1 was a float, jump to conversion

label_int15: # int multiplication
mult $t1,$t2
mflo $t1
mfhi $t2
j label16 # finish

label_float_conv15: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float15: # float multiplication
mul.s $f1,$f1,$f2
mfc1 $t1,$f1

label16: # finish
sw $t1,0($s1)

# int 2
addi $s1,$s1,-4
li $t1,2
sw $t1,0($s1)

# getting n
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
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
beq $t3,$t4,label18
beq $t3,$zero,label18
addi $t7,$zero,1 # we know now that t1 is a float
label18: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label19
beq $t3,$zero,label19
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float19 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float19 # j to float operation

label19: # t2 is int
bne $t7,$zero,label_float_conv19 # if t1 was a float, jump to conversion

label_int19: # int multiplication
mult $t1,$t2
mflo $t1
mfhi $t2
j label20 # finish

label_float_conv19: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float19: # float multiplication
mul.s $f1,$f1,$f2
mfc1 $t1,$f1

label20: # finish
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
beq $t3,$t4,label23
srl $t3,$t1,29
beq $t3,$t4,label23

# assume both types are int
add $t7,$zero,$zero # assume t1 is not a float
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label21
beq $t3,$zero,label21
addi $t7,$zero,1 # we know now that t1 is a float

label21: # t1 is int
srl $t3,$t2,29
beq $t3,$t4,label22
beq $t3,$zero,label22
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float22 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float22 # j to float addition

label22: # t2 is int
bne $t7,$zero,label_float_conv22 # if t1 was a float, jump to conversion

label_int22: # int addition
add $t1,$t1,$t2
j label24 # finish

label_float_conv22: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float22: # float addition
add.s $f1,$f1,$f2
mfc1 $t1,$f1
j label24 #finish


label23: # list
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
label_t1_24:
slt $t7,$zero,$t3 # t3 > 0
beq $t7,$zero,label_t2_24 # done adding
addi $t6,$t6,4
addi $t1,$t1,4
lw $t7,0($t1)
sw $t7,0($t6)
addi $t3,$t3,-4
j label_t1_24
label_t2_24: # add struff from second list
slt $t7,$zero,$t4 # t3 > 0
beq $t7,$zero,label_t2_end_24 # done adding
addi $t6,$t6,4
addi $t2,$t2,4
lw $t7,0($t2)
sw $t7,0($t6)
addi $t4,$t4,-4
j label_t2_24
label_t2_end_24: # end adding from 2nd list
add $t1,$t0,$zero

label24: # finish

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
beq $t3,$t4,label26
beq $t3,$zero,label26
addi $t7,$zero,1 # we know now that t1 is a float
label26: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label27
beq $t3,$zero,label27
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float27 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float27 # j to float operation

label27: # t2 is int
bne $t7,$zero,label_float_conv27 # if t1 was a float, jump to conversion

label_int27: # int multiplication
mult $t1,$t2
mflo $t1
mfhi $t2
j label28 # finish

label_float_conv27: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float27: # float multiplication
mul.s $f1,$f1,$f2
mfc1 $t1,$f1

label28: # finish
sw $t1,0($s1)

# int 6
addi $s1,$s1,-4
li $t1,6
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
div $t1,$t2
mflo $t1
mfhi $t2
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-24 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# getting S
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
# fast exponentiation
add $t4,$t8,$zero # t4 = 1
label29_loop:
beq $t2,$zero,label29_out
and $t3,$t2,$t8
beq $t3,$zero,label29_in
mult $t4,$t1
mflo $t4 # t4 = t4*t1
label29_in: # mult done
mult $t1,$t1
mflo $t1 # square
srl $t2,$t2,1
j label29_loop
label29_out:
add $t1,$t4,$zero
# end exponentiation
sw $t1,0($s1)

# getting S2
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-24($t0)
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
beq $t3,$t4,label31
beq $t3,$zero,label31
addi $t7,$zero,1 # we know now that t1 is a float
label31: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label32
beq $t3,$zero,label32
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float32 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float32 # j to float subtraction

label32: # t2 is int
bne $t7,$zero,label_float_conv32 # if t1 was a float, jump to conversion

label_int32: # int subtraction
sub $t1,$t1,$t2
j label33 # finish

label_float_conv32: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float32: # float subtraction
sub.s $f1,$f1,$f2
mfc1 $t1,$f1

label33: # finish
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
addi $t4,$zero,4
beq $t1,$zero,label36 # 000 -> int
beq $t1,$t3,label36 # 111 -> int
beq $t1,$t4,label_alg36 # 100 -> alg .. printed as int
addi $t3,$zero,3
bne $t1,$t3,label35 # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label34: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label37 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label34 # continue printing characters

label35:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label37

label_alg36:#print alg
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
j label37


label36:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label37:# end print
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
