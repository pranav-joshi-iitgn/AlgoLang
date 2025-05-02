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
addi $s1,$s0,-20

# main code 

# X gate
addi $t1,$zero,0
X $t1

# X gate
addi $t1,$zero,1
X $t1

# Definition : pi is -16($s0)

# float 3.1415926535
li $t1,1078530011
addi $s1,$s1,-4
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-16 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : piby2 is -20($s0)

# getting pi
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-16($t0)
sw $t1,0($s1)

# int 2
li $t1,2
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

#This final division will necessarily be a float division
mtc1 $t1,$f1
mtc1 $t2,$f2
addi $t4,$t4,7

# convert  f1 if not float
srl $t3,$t1,29
beq $t3,$t4,label1
beq $t3,$zero,label1
# we know now that f1 is a float
j label2 # skip conversion
label1: # f1 is int
cvt.s.w $f1,$f1
label2: # f1 is finally a float

# convert f2 if not float
srl $t3,$t2,29
beq $t3,$t4,label3
beq $t3,$zero,label3
# we know now that f2 is a float
j label4 # skip conversion
label3: # f2 is int
cvt.s.w $f2,$f2
label4: # f2 is finally a float

div.s $f1,$f1,$f2
mfc1 $t1,$f1
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-20 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# CP gate
addi $t7,$zero,0
# getting piby2
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-20($t0)
# skipping storing
addi $t6,$zero,1
CP $t1,$t7,$t6



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
