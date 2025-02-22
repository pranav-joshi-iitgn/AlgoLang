.global _start
_start:

addi $t8,$zero,1

addi $t9,$zero,1

addi $s0,$zero,1024

addi $s1,$s0,-4

# x is -4($s0)

addi $s1,$s1,-4
addi $t1,$zero,2
sw $t1,0($s1)

lw $t1,0($s1)
addi $t0,$s0,-4
sw $t1,0($t0)
addi $s1,$s1,4

label1: # while 

addi $t0,$s0,-4
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

addi $s1,$s1,-4
addi $t1,$zero,10
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t1,$t1,$t2
sw $t1,0($s1)
lw $t9,0($s1)
addi $s1,$s1,4
slt $t1,$zero,$t9
slt $t9,$t9,$zero
or $t9,$t9,$t1
beq $t9,$zero,label2

addi $t0,$s0,-4
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

addi $t0,$s0,-4
addi $s1,$s1,-4
lw $t1,0($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
add $t1,$t1,$t2
sw $t1,0($s1)

lw $t1,0($s1)
addi $t0,$s0,-4
sw $t1,0($t0)
addi $s1,$s1,4

j label1



j label1
label2: # end while



syscall 10