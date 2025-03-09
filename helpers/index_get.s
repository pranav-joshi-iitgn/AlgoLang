lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2 = t2*4
lw $t0,{m4v}($s0) # load pointer value
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
add $t0,$t2,$t0 # get address
addi $t0,$t0,4 # still getting address..
lw $t1,0($t0) # get value at index
sw $t1,0($s1) # replace index on stack with valu
