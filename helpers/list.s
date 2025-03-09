
# list
add $t0,$s5,$zero
lw $t1,0($s1) # n
sll $t1,$t1,2 # 4n
addi $t2,$t1,4 # 4n+4
add $s5,$s5,$t2 # inc $s5 by 4n+4
sw $t0,0($s1) # store pointer on stack
sw $t1,0($t0) # store 4n as first thing