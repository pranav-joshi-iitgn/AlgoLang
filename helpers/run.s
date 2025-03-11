lw $t1, 0($s1)
li $t2,0x1FFFFFFF
and $t1, $t1, $t2
sw $t1, 0($s1)

# function call
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
{getargs}

# Making a stack frame
addi $s1,$s1,{p4Np12}
lw $t2,4($s1)
lw $t1,0($s1)
sw $t1,4($s1)
sw $s0,0($s1)
add $s0,$s1,$zero
addi $s1,$s1,{m4Nm12}
jal pathfinder
addi $ra,$t1,8
jr $t2
addi $s1,$s1,8
lw $ra,-4($s1)
