# Syscall Declaration
add $t2,$ra,$zero # save current ra
jal pathfinder # find path of next line
add $ra,$t2,$zero # restore ra
addi $t1,$t1,28 # address to start the syscall
sll $t2,$t8,31 # 0x80000000
or $t1,$t1,$t2 # adjust $t1 to point to start label
addi $s1,$s1,-4 # new slot in stack
sw $t1,0($s1) # add syscall to stack
j {end} # skip function
{start}:

# No named arguments. This is a syscall

{code}

# return
lw $t0,0($s0) # caller's base
lw $t1,0($s1) # return value
sw $t1,0($s0) # store return value at base
addi $t9,$zero,1 # assert that return happened
add $s1,$s0,$zero # restore stack pointer
add $s0,$zero,$t0 # restore base pointer
jr $ra # return
# End of return
{end}: # end of function

# Add this to parent pointer tree (optional)
lw $t2,-8($s0) # parent (global scope)
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5
sw $t2,0($t1) # child -> parent
sw $zero,4($t1) # child has null as its copy, since it's not dead yet
