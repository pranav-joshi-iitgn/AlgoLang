# return

# duplicate current stack frame on heap
# ignore the return value at top of stack

{recreate}addi $t0,$s1,4 # initialise pointer
{recreate}label{labelsm1}: # put a value on heap
{recreate}sgt $t3,$t0,$s0 # check if base is crossed, which happens when $t0 > $s0
{recreate}bne $t3,$zero,label{labels} # if crossed, stop
{recreate}lw $t1,0($t0) # get value from stack
{recreate}sw $t1,0($s5) # put value on heap
{recreate}addi $t0,$t0,4 # move stack pointer
{recreate}addi $s5,$s5,4 # move heap pointer
{recreate}j label{labelsm1} # repeat until all values are copied
{recreate}label{labels}:# finished putting value
{recreate}lw $t1,-8($s0) # get self
{recreate}li $t5,0x7F000000
{recreate}li $t6,0x1FFFFFFF
{recreate}and $t1,$t1,$t6
{recreate}or $t1,$t1,$t5 # address corresponding to self
{recreate}addi $s4,$s5,-4
{recreate}sw $s4,4($t1) # store fake base

lw $t0,0($s0) # caller's base

lw $t1,0($s1) # return value
sw $t1,0($s0) # store return value at base
addi $t9,$zero,1 

add $s1,$s0,$zero # restore stack pointer
add $s0,$zero,$t0 # restore base pointer
jr $ra # return
# End of return
