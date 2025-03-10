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
addi $s1,$s0,0

# int 1
addi $s1,$s1,-4
li $t1,1
sw $t1,0($s1)

# <bound method SignedValue.op of SignedValue->- EnclosedValues>
lw $t1,0($s1)
srl $t2,$t1,29
addi $t3,$zero,7
beq $t2,$t3,label_int1
beq $t2,$zero,label_int1
mtc1 $t1,$f1
mtc1 $zero,$f2
sub.s $f1,$f2,$f1
mfc1 $t1,$f1
j label1
label_int1: #int
sub $t1,$zero,$t1
label1: # finish
sw $t1,0($s1)

# int 2
addi $s1,$s1,-4
li $t1,2
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
beq $t3,$t4,label2
beq $t3,$zero,label2
# we know now that f1 is a float
j label3 # skip conversion
label2: # f1 is int
cvt.s.w $f1,$f1
label3: # f1 is finally a float

# convert f2 if not float
srl $t3,$t2,29
beq $t3,$t4,label4
beq $t3,$zero,label4
# we know now that f2 is a float
j label5 # skip conversion
label4: # f2 is int
cvt.s.w $f2,$f2
label5: # f2 is finally a float

div.s $f1,$f1,$f2
mfc1 $t1,$f1
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label8 # 000 -> int
beq $t1,$t3,label8 # 111 -> int
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