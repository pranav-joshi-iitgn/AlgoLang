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

# Definition : f is -16($s0)

# Algorithm
add $t2,$ra,$zero # save current ra
jal pathfinder # find path of next line
addi $t1,$t1,28 # address to start the function
add $ra,$t2,$zero # restore ra
li $t2,0x80000000
or $t1,$t1,$t2
addi $s1,$s1,-4
sw $t1,0($s1)
j label13 # skip function
label12:

# x is -16($s0)

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-16

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
slt $t1,$t2,$t1
sub $t1,$t8,$t1
sw $t1,0($s1)

lw $t9,0($s1) #get result of condition
addi $s1,$s1,4 # delete a value
beq $t9,$zero,label1 # if

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



addi $t9,$zero,1
label1: # end if

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# getting f
add $t0,$s0,$zero
li $t5,0x7F000000
li $t6,0x1FFFFFFF
lw $t1,-8($t0) # self
and $t1,$t1,$t6
or $t1,$t1,$t5
lw $t2,0($t1) # parent
lw $t0,-4($t0)
lw $t3,-8($t0) # self_new
beq $t3,$t2,label2
#Print parent dead
addi $v0,$zero,11
addi $a0,$zero,112 #p
syscall
addi $a0,$zero,97 #a
syscall
addi $a0,$zero,114 #r
syscall
addi $a0,$zero,101 #e
syscall
addi $a0,$zero,110 #n
syscall
addi $a0,$zero,116 #t
syscall
addi $a0,$zero,32 # 
syscall
addi $a0,$zero,100 #d
syscall
addi $a0,$zero,101 #e
syscall
addi $a0,$zero,97 #a
syscall
addi $a0,$zero,100 #d
syscall
addi $a0,$zero,10 # newline
syscall

j error
label2:# creator is still alive
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1) 
# assert type is alg
lw $t1,0($s1)
srl $t1,$t1,29
addi $t2,$zero,4
beq $t1,$t2,label7
j error # if wrong type
label7:# type check over 

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

# third is the value of the parent, available at -8($t0)
addi $s1,$s1,-4
lw $t2,-8($t0)
sw $t2,0($s1)

# All other arguments
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
beq $t3,$t4,label4
beq $t3,$zero,label4
addi $t7,$zero,1 # we know now that t1 is a float
label4: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label5
beq $t3,$zero,label5
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float5 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float5 # j to float subtraction

label5: # t2 is int
bne $t7,$zero,label_float_conv5 # if t1 was a float, jump to conversion

label_int5: # int subtraction
sub $t1,$t1,$t2
j label6 # finish

label_float_conv5: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float5: # float subtraction
sub.s $f1,$f1,$f2
mfc1 $t1,$f1

label6: # finish
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
beq $t3,$t4,label9
beq $t3,$zero,label9
addi $t7,$zero,1 # we know now that t1 is a float
label9: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label10
beq $t3,$zero,label10
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float10 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float10 # j to float operation

label10: # t2 is int
bne $t7,$zero,label_float_conv10 # if t1 was a float, jump to conversion

label_int10: # int multiplication
mult $t1,$t2
mflo $t1
mfhi $t2
j label11 # finish

label_float_conv10: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float10: # float multiplication
mul.s $f1,$f1,$f2
mfc1 $t1,$f1

label11: # finish
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
label13: # end of function

# Add this to parent pointer tree
lw $t2,-8($s0) # parent
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5
sw $t2,0($t1) # child -> parent


lw $t1,0($s1) # get value
addi $t0,$s0,-16 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# getting f
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1) 
# assert type is alg
lw $t1,0($s1)
srl $t1,$t1,29
addi $t2,$zero,4
beq $t1,$t2,label14
j error # if wrong type
label14:# type check over 

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

# third is the value of the parent, available at -8($t0)
addi $s1,$s1,-4
lw $t2,-8($t0)
sw $t2,0($s1)

# All other arguments
# int 10
addi $s1,$s1,-4
li $t1,10
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


# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label17 # 000 -> int
beq $t1,$t3,label17 # 111 -> int
addi $t3,$zero,3
bne $t1,$t3,label16 # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label15: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label18 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label15 # continue printing characters

label16:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label18

label17:#print int
addi $v0,$zero,1
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
