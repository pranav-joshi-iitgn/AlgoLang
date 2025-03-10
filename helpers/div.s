# # if t1 is a list or t2 is a list, then throw an error
# addi $t4,$zero,3
# srl $t3,$t2,29
# beq $t3,$t4,error
# srl $t3,$t1,29
# beq $t3,$t4,error

#This final division will necessarily be a float division
mtc1 $t1,$f1
mtc1 $t2,$f2
addi $t4,$t4,7

# convert  f1 if not float
srl $t3,$t1,29
beq $t3,$t4,label{labelsm3}
beq $t3,$zero,label{labelsm3}
# we know now that f1 is a float
j label{labelsm2} # skip conversion
label{labelsm3}: # f1 is int
cvt.s.w $f1,$f1
label{labelsm2}: # f1 is finally a float

# convert f2 if not float
srl $t3,$t2,29
beq $t3,$t4,label{labelsm1}
beq $t3,$zero,label{labelsm1}
# we know now that f2 is a float
j label{labels} # skip conversion
label{labelsm1}: # f2 is int
cvt.s.w $f2,$f2
label{labels}: # f2 is finally a float

div.s $f1,$f1,$f2
mfc1 $t1,$f1