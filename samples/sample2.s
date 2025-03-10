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

# Definition : f is -4($s0)

# Algorithm
jal pathfinder # find path of next line
addi $t1,$t1,24
li $t2,0xA0000000
or $t1,$t1,$t2
addi $s1,$s1,-4
sw $t1,0($s1)
j label5 # skip function
label4:

# x is -8($s0)
# y is -12($s0)

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-12

# getting y
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-12($t0)
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label2 # 000 -> int
beq $t1,$t3,label2 # 111 -> int
srl $t1,$t1,1
bne $t1,$t8,error # 010 or 011 are for str and list
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # str
label1: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label3 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label1 # continue printing charactters
label2:# int
addi $v0, $zero,1
add $a0,$t0,$zero
syscall
label3:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $zero, 10
addi $v0, $zero, 11 
syscall




# return whatever is on the top of stack
lw $t0,0($s0)
addi $t9,$zero,0
add $s1,$s0,$zero
add $s0,$zero,$t0
jr $ra
label5: # end of function


lw $t1,0($s1) # get value
addi $t0,$s0,-4 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : x is -8($s0)

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-8 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# getting f
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-4($t0)
sw $t1,0($s1)
 # assert type is alg
lw $t1,0($s1)
srl $t1,$t1,29
addi $t2,$zero,5
beq $t1,$t2,label6
j error # if wrong type
label6:# type check over
 lw $t1, 0($s1)
li $t2,0x1FFFFFFF
and $t1, $t1, $t2
sw $t1, 0($s1)

# function call
sw $ra,-4($s1)
addi $s1,$s1,-4

# Getting Arguments

# first argument is the creator base, currently available in $t0
addi $s1,$s1,-4
sw $t0,0($s1)

# int 2
addi $s1,$s1,-4
li $t1,2
sw $t1,0($s1)

# putting "ab" on heap 
add $t0,$s5,$zero
addi $s5, $s5,12
addi $t1,$zero,8 # add size at start
sw $t1,0($t0)
addi $t1,$zero,97 # a
sw $t1, 4($t0)
addi $t1,$zero,98 # b
sw $t1, 8($t0)
# add the pointer on stack
addi $s1,$s1,-4
sw $t0,0($s1)

# Making a stack frame
addi $s1,$s1,12
lw $t2,4($s1)
lw $t1,0($s1)
sw $t1,4($s1)
sw $s0,0($s1)
add $s0,$s1,$zero
addi $s1,$s1,-12
jal pathfinder
addi $ra,$t1,8
jr $t2
addi $s1,$s1,8
lw $ra,-4($s1)




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