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

# int 2
addi $s1,$s1,-4
li $t1,2
sw $t1,0($s1)
 # int 3
addi $s1,$s1,-4
li $t1,3
sw $t1,0($s1)
 lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
# fast exponentiation
add $t4,$t8,$zero # t4 = 1
label1_loop:
beq $t2,$zero,label1_out
and $t3,$t2,$t8
beq $t3,$zero,label1_in
mult $t4,$t1
mflo $t4 # t4 = t4*t1
label1_in: # mult done
mult $t1,$t1
mflo $t1 # square
srl $t2,$t2,1
j label1_loop
label1_out:
add $t1,$t4,$zero
# end exponentiation
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label4 # 000 -> int
beq $t1,$t3,label4 # 111 -> int
addi $t3,$zero,3
bne $t1,$t3,label3 # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label2: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label5 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label2 # continue printing characters

label3:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label5

label4:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label5:# end print
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
