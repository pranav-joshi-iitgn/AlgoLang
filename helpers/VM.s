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

{syscalls}

# syscalls over

# making space for globals
addi $s1,$s0,{m4n}

# main code 

{mips_code}

# print newline via syscall 11 to clean up
addi $a0, $0, 10
addi $v0, $0, 11 
syscall
theend:
# Exit via syscall 10
addi $v0,$zero,10
syscall #10
{error_log}
# Exit via syscall 10
addi $v0,$zero,10
syscall #10
