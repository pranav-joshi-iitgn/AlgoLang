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

# Definition : L is -4($s0)

# int 3
addi $s1,$s1,-4
li $t1,3
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

# Definition : x is -8($s0)

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-8 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# int 12
addi $s1,$s1,-4
li $t1,12
sw $t1,0($s1)

# Assignment
# Getting index
# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2=t2*4
lw $t0,-4($s0) # load pointer
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
lw $t1,4($s1) # load value to be assignment
add $t0,$t2,$t0 # get address on memory location
addi $t0,$t0,4 # still getting address..
sw $t1,0($t0) # store value to address
addi $s1,$s1,8 #clear both index and value

# Getting index
# int 0
addi $s1,$s1,-4
li $t1,0
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2 = t2*4
lw $t0,-4($s0) # load pointer value
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


# int 100
addi $s1,$s1,-4
li $t1,100
sw $t1,0($s1)

lw $t1,0($s1)
sub $t1,$zero,$t1
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label5 # 000 -> int
beq $t1,$t3,label5 # 111 -> int
srl $t1,$t1,1
bne $t1,$t8,error # 010 or 011 are for str and list
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # str
label4: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label6 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label4 # continue printing charactters
label5:# int
addi $v0, $zero,1
add $a0,$t0,$zero
syscall
label6:# end print
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