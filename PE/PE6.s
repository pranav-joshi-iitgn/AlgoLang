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
addi $s1,$s0,-12

# Definition : n is -4($s0)

# int 100
addi $s1,$s1,-4
li $t1,100
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-4 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : S is -8($s0)

# getting n
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-4($t0)
sw $t1,0($s1)

# getting n
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-4($t0)
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
beq $t3,$t8,label3
srl $t3,$t2,30
beq $t3,$t8,label3
# ensure type is int
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label1
beq $t3,$zero,label1
j error
label1: # t1 is ok
srl $t3,$t2,29
beq $t3,$t4,label2
beq $t3,$zero,label2
j error
label2: # t2 is ok
add $t1,$t1,$t2 # addition of integers
j label4 # finish

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
mult $t1,$t2
mflo $t1
mfhi $t2
sw $t1,0($s1)

# int 2
addi $s1,$s1,-4
li $t1,2
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
div $t1,$t2
mfhi $t2
mflo $t1
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-8 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : S2 is -12($s0)

# getting n
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-4($t0)
sw $t1,0($s1)

# getting n
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-4($t0)
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
beq $t3,$t8,label7
srl $t3,$t2,30
beq $t3,$t8,label7
# ensure type is int
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label5
beq $t3,$zero,label5
j error
label5: # t1 is ok
srl $t3,$t2,29
beq $t3,$t4,label6
beq $t3,$zero,label6
j error
label6: # t2 is ok
add $t1,$t1,$t2 # addition of integers
j label8 # finish

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

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
mult $t1,$t2
mflo $t1
mfhi $t2
sw $t1,0($s1)

# int 2
addi $s1,$s1,-4
li $t1,2
sw $t1,0($s1)

# getting n
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-4($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
mult $t1,$t2
mflo $t1
mfhi $t2
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
beq $t3,$t8,label11
srl $t3,$t2,30
beq $t3,$t8,label11
# ensure type is int
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label9
beq $t3,$zero,label9
j error
label9: # t1 is ok
srl $t3,$t2,29
beq $t3,$t4,label10
beq $t3,$zero,label10
j error
label10: # t2 is ok
add $t1,$t1,$t2 # addition of integers
j label12 # finish

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
mult $t1,$t2
mflo $t1
mfhi $t2
sw $t1,0($s1)

# int 6
addi $s1,$s1,-4
li $t1,6
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
div $t1,$t2
mfhi $t2
mflo $t1
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-12 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# getting S
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-8($t0)
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
label13_loop:
beq $t2,$zero,label13_out
and $t3,$t2,$t8
beq $t3,$zero,label13_in
mult $t4,$t1
mflo $t4 # t4 = t4*t1
label13_in: # mult done
mult $t1,$t1
mflo $t1 # square
srl $t2,$t2,1
j label13_loop
label13_out:
add $t1,$t4,$zero
# end exponentiation
sw $t1,0($s1)

# getting S2
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-12($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
sub $t1,$t1,$t2
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label15 # 000 -> int
beq $t1,$t3,label15 # 111 -> int
srl $t1,$t1,1
bne $t1,$t8,error # 010 or 011 are for str and list
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # str
label14: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label16 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label14 # continue printing charactters
label15:# int
addi $v0, $zero,1
add $a0,$t0,$zero
syscall
label16:# end print
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