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
addi $s1,$s0,-16

jal pathfinder
addi $t1,$t1,16
li $t2,0x80000000
or $t1,$t1,$t2
sw $t1,-8($s0)

thestart:
addi $t8,$zero,1
addi $t9,$zero,1

# Definition : x is -16($s0)

# int 8
addi $s1,$s1,-4
li $t1,8
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-16 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Condition

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
slt $t3,$t1,$t2
slt $t2,$t2,$t1
or $t1,$t3,$t2
sub $t1,$t8,$t1
sw $t1,0($s1)

lw $t9,0($s1) #get result of condition
addi $s1,$s1,4 # delete a value
beq $t9,$zero,label5 # if

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
addi $t4,$zero,4
beq $t1,$zero,label3 # 000 -> int
beq $t1,$t3,label3 # 111 -> int
beq $t1,$t4,label_alg3 # 100 -> alg .. printed as int
addi $t3,$zero,3
bne $t1,$t3,label2 # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label1: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label4 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label1 # continue printing characters

label2:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label4

label_alg3:#print alg
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
j label4


label3:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label4:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $zero, 10
addi $v0, $zero, 11 
syscall




addi $t9,$zero,1
label5: # end if

# Condition

# getting x
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
slt $t3,$t1,$t2
slt $t2,$t2,$t1
or $t1,$t3,$t2
sub $t1,$t8,$t1
sw $t1,0($s1)

bne $t9,$zero,label10 # el..
lw $t9,0($s1)
addi $s1,$s1,4
beq $t9,$zero,label10 # ..if

# int 2
addi $s1,$s1,-4
li $t1,2
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
addi $t4,$zero,4
beq $t1,$zero,label8 # 000 -> int
beq $t1,$t3,label8 # 111 -> int
beq $t1,$t4,label_alg8 # 100 -> alg .. printed as int
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

label_alg8:#print alg
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
label10: # end elif

# Condition

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# int 3
addi $s1,$s1,-4
li $t1,3
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t3,$t1,$t2
slt $t2,$t2,$t1
or $t1,$t3,$t2
sub $t1,$t8,$t1
sw $t1,0($s1)

bne $t9,$zero,label15 # el..
lw $t9,0($s1)
addi $s1,$s1,4
beq $t9,$zero,label15 # ..if

# int 3
addi $s1,$s1,-4
li $t1,3
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
addi $t4,$zero,4
beq $t1,$zero,label13 # 000 -> int
beq $t1,$t3,label13 # 111 -> int
beq $t1,$t4,label_alg13 # 100 -> alg .. printed as int
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

label_alg13:#print alg
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
label15: # end elif

# else
bne $t9,$zero,label20

# putting "none" on heap 
add $t0,$s5,$zero
addi $s5, $s5,20
addi $t1,$zero,16 # add size at start
sw $t1,0($t0)
addi $t1,$zero,110 # n
sw $t1, 4($t0)
addi $t1,$zero,111 # o
sw $t1, 8($t0)
addi $t1,$zero,110 # n
sw $t1, 12($t0)
addi $t1,$zero,101 # e
sw $t1, 16($t0)
# add the pointer on stack
addi $s1,$s1,-4
sw $t0,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
addi $t4,$zero,4
beq $t1,$zero,label18 # 000 -> int
beq $t1,$t3,label18 # 111 -> int
beq $t1,$t4,label_alg18 # 100 -> alg .. printed as int
addi $t3,$zero,3
bne $t1,$t3,label17 # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label16: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label19 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label16 # continue printing characters

label17:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label19

label_alg18:#print alg
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
j label19


label18:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label19:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $zero, 10
addi $v0, $zero, 11 
syscall




addi $t9,$zero,1
label20: # end else



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
