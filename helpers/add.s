# if t1 is a list or t2 is a list, then jump
addi $t4,$zero,3
srl $t3,$t2,29
beq $t3,$t4,label{labelsm1}
srl $t3,$t1,29
beq $t3,$t4,label{labelsm1}

# assume both types are int
add $t7,$zero,$zero # assume t1 is not a float
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label{labelsm3}
beq $t3,$zero,label{labelsm3}
addi $t7,$zero,1 # we know now that t1 is a float

label{labelsm3}: # t1 is int
srl $t3,$t2,29
beq $t3,$t4,label{labelsm2}
beq $t3,$zero,label{labelsm2}
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float{labelsm2} # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float{labelsm2} # j to float addition

label{labelsm2}: # t2 is int
bne $t7,$zero,label_float_conv{labelsm2} # if t1 was a float, jump to conversion

label_int{labelsm2}: # int addition
add $t1,$t1,$t2
j label{labels} # finish

label_float_conv{labelsm2}: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float{labelsm2}: # float addition
add.s $f1,$f1,$f2
mfc1 $t1,$f1
j label{labels} #finish


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
