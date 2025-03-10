# # if t1 is a list or t2 is a list, then throw an error
# addi $t4,$zero,3
# srl $t3,$t2,29
# beq $t3,$t4,error
# srl $t3,$t1,29
# beq $t3,$t4,error

# assume t1 is an int
add $t7,$zero,$zero 
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label{labelsm2}
beq $t3,$zero,label{labelsm2}
addi $t7,$zero,1 # we know now that t1 is a float
label{labelsm2}: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label{labelsm1}
beq $t3,$zero,label{labelsm1}
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float{labelsm1} # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float{labelsm1} # j to float operation

label{labelsm1}: # t2 is int
bne $t7,$zero,label_float_conv{labelsm1} # if t1 was a float, jump to conversion

label_int{labelsm1}: # int multiplication
mult $t1,$t2
mflo $t1
mfhi $t2
j label{labels} # finish

label_float_conv{labelsm1}: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float{labelsm1}: # float multiplication
mul.s $f1,$f1,$f2
mfc1 $t1,$f1

label{labels}: # finish