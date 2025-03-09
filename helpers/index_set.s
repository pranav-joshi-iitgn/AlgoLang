lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2=t2*4
lw $t0,{m4v}($s0) # load pointer
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
lw $t1,4($s1) # load value to be assignment
add $t0,$t2,$t0 # get address on memory location
addi $t0,$t0,4 # still getting address..
sw $t1,0($t0) # store value to address
addi $s1,$s1,8 #clear both index and value