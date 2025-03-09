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
addi $s1,$s0,-8

# Definition : L0 is -4($s0)

# int 6
addi $s1,$s1,-4
li $t1,6
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
addi $t0,$s0,-4 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : L is -8($s0)

# getting L0
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-4($t0)
sw $t1,0($s1)

# get the elements of list, from left to right
# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

# int 2
addi $s1,$s1,-4
li $t1,2
sw $t1,0($s1)

# int 3
addi $s1,$s1,-4
li $t1,3
sw $t1,0($s1)

addi $s5, 12 # make space for 4 elements on heap
# store element at index 2
lw $t1,0($s1)
sw $t1,-4($s5)
# store element at index 1
lw $t1,4($s1)
sw $t1,-8($s5)
# store element at index 0
lw $t1,8($s1)
sw $t1,-12($s5)
addi $s1,8 # pop stack 2 times
addi $t0,$s5,-16 # old $s5 value
sw $t0,0($s1) # store pointer on heap
addi $t1,$zero,12
sw $t1,0($t0) # store 4n as first element

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

lw $t1,0($s1) # get value
addi $t0,$s0,-8 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Getting index
# int 7
addi $s1,$s1,-4
li $t1,7
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2 = t2*4
lw $t0,-8($s0) # load pointer value
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
beq $t1,$zero,label6 # 000 -> int
beq $t1,$t3,label6 # 111 -> int
srl $t1,$t1,1
bne $t1,$t8,error # 010 or 011 are for str and list
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # str
label5: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label7 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label5 # continue printing charactters
label6:# int
addi $v0, $zero,1
add $a0,$t0,$zero
syscall
label7:# end print
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