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
addi $s1,$s0,-4

# Definition : s is -4($s0)

# putting "a1b2" on heap 
add $t0,$s5,$zero
addi $s5, $s5,20
addi $t1,$zero,97 # a
sw $t1, 0($t0)
addi $t1,$zero,49 # 1
sw $t1, 4($t0)
addi $t1,$zero,98 # b
sw $t1, 8($t0)
addi $t1,$zero,50 # 2
sw $t1, 12($t0)
# add a null character
sw $zero, 16($t0)
# add the pointer on stack
addi $s1,$s1,-4
sw $t0,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-4 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# getting s
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-4($t0)
sw $t1,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,30
addi $t3,$zero,5
beq $t1,$zero,label2
beq $t1,$t3,label2
bne $t1,$t8,error
label1:addi $v0, $zero, 11 # str
lw $t1,0($t0)
beq $t1,$zero,label3
addi $a0,$t1,0
syscall
addi $t0,$t0,4
j label1 # continue printing charactters
label2:# int
addi $v0, $zero,1
addi $a0,$t0,1
syscall
label3:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $0, 10
addi $v0, $0, 11 
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