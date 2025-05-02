.text
main:
    li $a0, 30
    addi $a0,$a0,1
    jal fib
    add $a0, $v0, $zero
    jal print_int
    jal print_newline
    li $a0, 10
    li $v0, 10
    syscall
    
fib:    
    addi    $sp, $sp, -12
    sw    $ra, 0($sp)
    sw    $s0, 4($sp)
    sw    $s1, 8($sp)
    
    addi    $s0, $a0, 0
    beq    $0, $s0, done
    addi    $t0, $0, 1
    beq    $t0, $s0, done
    
    addi    $a0, $s0, -1
    jal    fib
    addi    $s1, $v0, 0
    addi    $a0, $s0, -2
    jal    fib
    add    $v0, $v0, $s1
    j    finish
    
done:    
    add    $v0, $0, $s0
    j    finish
    
finish: 
    lw    $s1, 8($sp)
    lw    $s0, 4($sp)
    lw    $ra, 0($sp)
    addi  $sp, $sp, 12
    jr    $ra

print_int:
    add $a0, $v0, $zero
    li    $v0, 1
    syscall
    jr    $ra
    
print_newline:
    li    $v0, 11
    li    $a0, 10
    syscall
    jr    $ra    
