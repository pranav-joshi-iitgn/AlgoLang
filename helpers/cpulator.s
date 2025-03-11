# This code can be run on this MIPS simulator :
# https://cpulator.01xz.net/?sys=mipsr5-spim

.global _start

pathfinder:
add $t1,$ra,$zero
jr $ra

_start:
li $s0,0x40000000
li $s5,0x60000000
addi $s1,$s0,{m4n}

jal pathfinder
addi $t1,$t1,16
li $t2,0x80000000
or $t1,$t1,$t2
sw $t1,-8($s0)

thestart:
addi $t8,$zero,1
addi $t9,$zero,1

{mips_code}

# print newline via syscall 11 to clean up
addi $a0, $zero, 10
addi $v0, $zero, 11 
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
