lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
# fast exponentiation
add $t4,$t8,$zero # t4 = 1
label{labels}_loop:
beq $t2,$zero,label{labels}_out
and $t3,$t2,$t8
beq $t3,$zero,label{labels}_in
mult $t4,$t1
mflo $t4 # t4 = t4*t1
label{labels}_in: # mult done
mult $t1,$t1
mflo $t1 # square
srl $t2,$t2,1
j label{labels}_loop
label{labels}_out:
add $t1,$t4,$zero
# end exponentiation
sw $t1,0($s1)