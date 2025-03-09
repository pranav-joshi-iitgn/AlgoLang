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
addi $s1,$s0,-20

# Definition : check is -4($s0)

# Algorithm
jal pathfinder # find path of next line
addi $t1,$t1,24
li $t2,0xA0000000
or $t1,$t1,$t2
addi $s1,$s1,-4
sw $t1,0($s1)
j label11 # skip function
label10:

# x is -8($s0)

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-24

# Definition : y is -12($s0)

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-8($t0)
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-12 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : n is -16($s0)

# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-16 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

label1_start: # while 

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-12($t0)
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
srl $t3,$t1,30
beq $t3,$t8,label4
srl $t3,$t2,30
beq $t3,$t8,label4
# ensure type is int
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label2
beq $t3,$zero,label2
j error
label2: # t1 is ok
srl $t3,$t2,29
beq $t3,$t4,label3
beq $t3,$zero,label3
j error
label3: # t2 is ok
add $t1,$t1,$t2 # addition of integers
j label5 # finish

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
sw $t1,-16($t0)
addi $s1,$s1,4

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-12($t0)
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
sw $t1,-12($t0)
addi $s1,$s1,4



j label1_start
label1_end: # end while

# Definition : first is -20($s0)

# Definition : last is -24($s0)

label6_start: # while 

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
lw $t1,-8($t0)
sw $t1,0($s1)

# int 10
addi $s1,$s1,-4
li $t1,10
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
sub $t1,$t1,$t2
sw $t1,0($s1)
 lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
# fast exponentiation
add $t4,$t8,$zero # t4 = 1
label7_loop:
beq $t2,$zero,label7_out
and $t3,$t2,$t8
beq $t3,$zero,label7_in
mult $t4,$t1
mflo $t4 # t4 = t4*t1
label7_in: # mult done
mult $t1,$t1
mflo $t1 # square
srl $t2,$t2,1
j label7_loop
label7_out:
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
sw $t1,-20($t0)
addi $s1,$s1,4

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-8($t0)
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
sw $t1,-24($t0)
addi $s1,$s1,4

# Condition

# getting first
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1)

# getting last
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-24($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t3,$t1,$t2
slt $t2,$t2,$t1
or $t1,$t3,$t2
sub $t1,$t8,$t1
sw $t1,0($s1)

lw $t1,0($s1)
sub $t1,$t8,$t1
sw $t1,0($s1)

lw $t9,0($s1) #get result of condition
addi $s1,$s1,4 # delete a value
beq $t9,$zero,label8 # if

# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)
# return
lw $t0,0($s0)
lw $t1,0($s1)
sw $t1,0($s0)
addi $t9,$zero,1
add $s1,$s0,$zero
add $s0,$zero,$t0
jr $ra



addi $t9,$zero,1
label8: # end if

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-8($t0)
sw $t1,0($s1)

# int 10
addi $s1,$s1,-4
li $t1,10
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
sub $t1,$t1,$t2
sw $t1,0($s1)
 lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
# fast exponentiation
add $t4,$t8,$zero # t4 = 1
label9_loop:
beq $t2,$zero,label9_out
and $t3,$t2,$t8
beq $t3,$zero,label9_in
mult $t4,$t1
mflo $t4 # t4 = t4*t1
label9_in: # mult done
mult $t1,$t1
mflo $t1 # square
srl $t2,$t2,1
j label9_loop
label9_out:
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
sw $t1,-8($t0)
addi $s1,$s1,4

# getting n
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# int 2
addi $s1,$s1,-4
li $t1,2
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
sub $t1,$t1,$t2
sw $t1,0($s1)

# Assignment
# getting n
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-16($t0)
addi $s1,$s1,4



j label6_start
label6_end: # end while

# int 1
addi $s1,$s1,-4
li $t1,1
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
label11: # end of function


lw $t1,0($s1) # get value
addi $t0,$s0,-4 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : x is -8($s0)

# int 999
addi $s1,$s1,-4
li $t1,999
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-8 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : biggest is -12($s0)

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-12 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : y is -16($s0)

# Definition : z is -20($s0)

label12_start: # while 

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-8($t0)
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
lw $t1,-8($t0)
sw $t1,0($s1)

# int 990
addi $s1,$s1,-4
li $t1,990
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
mult $t1,$t2
mflo $t1
mfhi $t2
sw $t1,0($s1)

# getting biggest
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-12($t0)
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
beq $t9,$zero,label12_end

# int 990
addi $s1,$s1,-4
li $t1,990
sw $t1,0($s1)

# Assignment
# getting y
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-16($t0)
addi $s1,$s1,4

label13_start: # while 

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
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
beq $t9,$zero,label13_end

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-8($t0)
sw $t1,0($s1)

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
mult $t1,$t2
mflo $t1
mfhi $t2
sw $t1,0($s1)

# Assignment
# getting z
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-20($t0)
addi $s1,$s1,4

# Condition

# getting check
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-4($t0)
sw $t1,0($s1) 
# assert type is alg
lw $t1,0($s1)
srl $t1,$t1,29
addi $t2,$zero,5
beq $t1,$t2,label14
j error # if wrong type
label14:# type check over 

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

# getting z
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
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


# getting z
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1)

# getting biggest
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-12($t0)
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
beq $t9,$zero,label15 # if

# getting z
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
sw $t1,0($s1)

# Assignment
# getting biggest
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-12($t0)
addi $s1,$s1,4

addi $t9,$zero,1
j label13_end



addi $t9,$zero,1
label15: # end if

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# int 11
addi $s1,$s1,-4
li $t1,11
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
sub $t1,$t1,$t2
sw $t1,0($s1)

# Assignment
# getting y
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-16($t0)
addi $s1,$s1,4



j label13_start
label13_end: # end while

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-8($t0)
sw $t1,0($s1)

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
sub $t1,$t1,$t2
sw $t1,0($s1)

# Assignment
# getting x
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-8($t0)
addi $s1,$s1,4



j label12_start
label12_end: # end while

# getting biggest
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-12($t0)
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label17 # 000 -> int
beq $t1,$t3,label17 # 111 -> int
srl $t1,$t1,1
bne $t1,$t8,error # 010 or 011 are for str and list
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # str
label16: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label18 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label16 # continue printing charactters
label17:# int
addi $v0, $zero,1
add $a0,$t0,$zero
syscall
label18:# end print
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
error:
addi $a0, $zero, -1
addi $v0, $zero, 1
syscall
# Exit via syscall 10
addi $v0,$zero,10
syscall #10