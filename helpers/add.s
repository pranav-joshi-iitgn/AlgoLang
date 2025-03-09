# if t1 is a list or t2 is a list, then jump
srl $t3,$t1,30
beq $t3,$t8,label{labelsm1}
srl $t3,$t2,30
beq $t3,$t8,label{labelsm1}
# ensure type is int
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label{labelsm3}
beq $t3,$zero,label{labelsm3}
j error
label{labelsm3}: # t1 is ok
srl $t3,$t2,29
beq $t3,$t4,label{labelsm2}
beq $t3,$zero,label{labelsm2}
j error
label{labelsm2}: # t2 is ok
add $t1,$t1,$t2 # addition of integers
j label{labels} # finish

label{labelsm1}: # list
# concatenate lists
lw $t3,0($t1) # 4*n1
lw $t4,0($t2) # 4*n2
add $t5,$t3,$t4 # 4*(n1+n2)
add $t0,$s5,$zero # our new thing to return
add $s5,$s5,$t5 # s5 += 4*(n1+n2)
addi $s5,$s5,4 # s5 += 4
sw $t5,0($t0) # store size first
add $t6,$t0,$zero
# Add stuff from first list to new allocated space
label_t1_{labels}:
slt $t7,$zero,$t3 # t3 > 0
beq $t7,$zero,label_t2_{labels} # done adding
addi $t6,$t6,4
addi $t1,$t1,4
lw $t7,0($t1)
sw $t7,0($t6)
addi $t3,$t3,-4
j label_t1_{labels}
label_t2_{labels}: # add struff from second list
slt $t7,$zero,$t4 # t3 > 0
beq $t7,$zero,label_t2_end_{labels} # done adding
addi $t6,$t6,4
addi $t2,$t2,4
lw $t7,0($t2)
sw $t7,0($t6)
addi $t4,$t4,-4
j label_t2_{labels}
label_t2_end_{labels}: # end adding from 2nd list
add $t1,$t0,$zero

label{labels}: # finish
