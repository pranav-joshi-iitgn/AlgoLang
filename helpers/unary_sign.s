srl $t2,$t1,29
addi $t3,$zero,7
beq $t2,$t3,label_int{labels}
beq $t2,$zero,label_int{labels}
mtc1 $t1,$f1
mtc1 $zero,$f2
sub.s $f1,$f2,$f1
mfc1 $t1,$f1
j label{labels}
label_int{labels}: #int
sub $t1,$zero,$t1
label{labels}: # finish