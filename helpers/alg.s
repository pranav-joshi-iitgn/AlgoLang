# Algorithm
jal pathfinder # find path of next line
addi $t1,$t1,24
li $t2,0xA0000000
or $t1,$t1,$t2
addi $s1,$s1,-4
sw $t1,0($s1)
j {end} # skip function
{start}:

{arg}

{code}

# return whatever is on the top of stack
lw $t0,0($s0)
addi $t9,$zero,0
add $s1,$s0,$zero
add $s0,$zero,$t0
jr $ra
{end}: # end of function
