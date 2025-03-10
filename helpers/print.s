
# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label{labelsm1} # 000 -> int
beq $t1,$t3,label{labelsm1} # 111 -> int
addi $t3,$zero,3
bne $t1,$t3,label{labelsm2} # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label{labelsm3}: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label{labels} # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label{labelsm3} # continue printing characters

label{labelsm2}:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label{labels}

label{labelsm1}:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label{labels}:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $zero, 10
addi $v0, $zero, 11 
syscall
