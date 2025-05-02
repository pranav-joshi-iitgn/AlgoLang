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
addi $s1,$s0,-12

jal pathfinder
addi $t1,$t1,16
li $t2,0x80000000
or $t1,$t1,$t2
sw $t1,-8($s0)

thestart:
addi $t8,$zero,1
addi $t9,$zero,1

# syscalls



# syscalls over

# making space for globals
addi $s1,$s0,-12

# main code 

# putting "Hello" on heap 
add $t0,$s5,$zero
addi $s5, $s5,24
addi $t1,$zero,20 # add size at start
sw $t1,0($t0)
addi $t1,$zero,72 # H
sw $t1, 4($t0)
addi $t1,$zero,101 # e
sw $t1, 8($t0)
addi $t1,$zero,108 # l
sw $t1, 12($t0)
addi $t1,$zero,108 # l
sw $t1, 16($t0)
addi $t1,$zero,111 # o
sw $t1, 20($t0)
# add the pointer on stack
addi $s1,$s1,-4
sw $t0,0($s1)

# putting " " on heap 
add $t0,$s5,$zero
addi $s5, $s5,8
addi $t1,$zero,4 # add size at start
sw $t1,0($t0)
addi $t1,$zero,32 #  
sw $t1, 4($t0)
# add the pointer on stack
addi $s1,$s1,-4
sw $t0,0($s1)

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

# putting "World" on heap 
add $t0,$s5,$zero
addi $s5, $s5,24
addi $t1,$zero,20 # add size at start
sw $t1,0($t0)
addi $t1,$zero,87 # W
sw $t1, 4($t0)
addi $t1,$zero,111 # o
sw $t1, 8($t0)
addi $t1,$zero,114 # r
sw $t1, 12($t0)
addi $t1,$zero,108 # l
sw $t1, 16($t0)
addi $t1,$zero,100 # d
sw $t1, 20($t0)
# add the pointer on stack
addi $s1,$s1,-4
sw $t0,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
# if t1 is a list or t2 is a list, then jump
addi $t4,$zero,3
srl $t3,$t2,29
beq $t3,$t4,label7
srl $t3,$t1,29
beq $t3,$t4,label7

# assume both types are int
add $t7,$zero,$zero # assume t1 is not a float
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label5
beq $t3,$zero,label5
addi $t7,$zero,1 # we know now that t1 is a float

label5: # t1 is int
srl $t3,$t2,29
beq $t3,$t4,label6
beq $t3,$zero,label6
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float6 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float6 # j to float addition

label6: # t2 is int
bne $t7,$zero,label_float_conv6 # if t1 was a float, jump to conversion

label_int6: # int addition
add $t1,$t1,$t2
j label8 # finish

label_float_conv6: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float6: # float addition
add.s $f1,$f1,$f2
mfc1 $t1,$f1
j label8 #finish


label7: # list
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
label_t1_8:
slt $t7,$zero,$t3 # t3 > 0
beq $t7,$zero,label_t2_8 # done adding
addi $t6,$t6,4
addi $t1,$t1,4
lw $t7,0($t1)
sw $t7,0($t6)
addi $t3,$t3,-4
j label_t1_8
label_t2_8: # add struff from second list
slt $t7,$zero,$t4 # t3 > 0
beq $t7,$zero,label_t2_end_8 # done adding
addi $t6,$t6,4
addi $t2,$t2,4
lw $t7,0($t2)
sw $t7,0($t6)
addi $t4,$t4,-4
j label_t2_8
label_t2_end_8: # end adding from 2nd list
add $t1,$t0,$zero

label8: # finish

sw $t1,0($s1)

# putting "!" on heap 
add $t0,$s5,$zero
addi $s5, $s5,8
addi $t1,$zero,4 # add size at start
sw $t1,0($t0)
addi $t1,$zero,33 # !
sw $t1, 4($t0)
# add the pointer on stack
addi $s1,$s1,-4
sw $t0,0($s1)

# int 10
li $t1,10
addi $s1,$s1,-4
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
beq $t3,$t4,label10
beq $t3,$zero,label10
addi $t7,$zero,1 # we know now that t1 is a float
label10: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label11
beq $t3,$zero,label11
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float11 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float11 # j to float operation

label11: # t2 is int
bne $t7,$zero,label_float_conv11 # if t1 was a float, jump to conversion

label_int11: # int multiplication
mult $t1,$t2
mflo $t1
mfhi $t2
j label12 # finish

label_float_conv11: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float11: # float multiplication
mul.s $f1,$f1,$f2
mfc1 $t1,$f1

label12: # finish
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
# if t1 is a list or t2 is a list, then jump
addi $t4,$zero,3
srl $t3,$t2,29
beq $t3,$t4,label15
srl $t3,$t1,29
beq $t3,$t4,label15

# assume both types are int
add $t7,$zero,$zero # assume t1 is not a float
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label13
beq $t3,$zero,label13
addi $t7,$zero,1 # we know now that t1 is a float

label13: # t1 is int
srl $t3,$t2,29
beq $t3,$t4,label14
beq $t3,$zero,label14
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float14 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float14 # j to float addition

label14: # t2 is int
bne $t7,$zero,label_float_conv14 # if t1 was a float, jump to conversion

label_int14: # int addition
add $t1,$t1,$t2
j label16 # finish

label_float_conv14: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float14: # float addition
add.s $f1,$f1,$f2
mfc1 $t1,$f1
j label16 #finish


label15: # list
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
label_t1_16:
slt $t7,$zero,$t3 # t3 > 0
beq $t7,$zero,label_t2_16 # done adding
addi $t6,$t6,4
addi $t1,$t1,4
lw $t7,0($t1)
sw $t7,0($t6)
addi $t3,$t3,-4
j label_t1_16
label_t2_16: # add struff from second list
slt $t7,$zero,$t4 # t3 > 0
beq $t7,$zero,label_t2_end_16 # done adding
addi $t6,$t6,4
addi $t2,$t2,4
lw $t7,0($t2)
sw $t7,0($t6)
addi $t4,$t4,-4
j label_t2_16
label_t2_end_16: # end adding from 2nd list
add $t1,$t0,$zero

label16: # finish

sw $t1,0($s1)

# Print
lw $t0,0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
addi $t4,$zero,4
beq $t1,$zero,label19 # 000 -> int
beq $t1,$t3,label19 # 111 -> int
beq $t1,$t4,label_alg19 # 100 -> alg .. printed as int
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

label_alg19:#print alg
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
j label20


label19:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label20:# end print
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
