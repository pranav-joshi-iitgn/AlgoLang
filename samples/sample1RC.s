
.data
.align 2
__d_gpr_prefix:   .asciiz " $ "
__d_colon_space:  .asciiz ": "
__d_comma_space:  .asciiz ", "
__d_fpr1_prefix:  .asciiz " $f1: "
__d_fpr2_prefix:  .asciiz " $f2: "
__d_fpr12_prefix: .asciiz " $f12: "
__d_newline:      .asciiz "\n"

.text
#---------------------------------------------------
# Routine: __print_registers
# Prints GPRs 0-31 and FPRs $f1,$f2,$f12 as integers.
# Preserves caller's $a0, $v0 using $s3, $s4.
# Clobbers $t0, $t1 (used as temporaries).
#---------------------------------------------------
__print_registers:      # Routine label
    move $s3, $a0         # Save caller's $a0
    move $s4, $v0         # Save caller's $v0

    li $v0, 4           # syscall print_string
    la $a0, __d_newline # Load address of newline string
    syscall             # Print newline before GPRs

    # --- Print GPRs 2-31 ---
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 2          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $v0     # Move GPR $2 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 3          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $v1     # Move GPR $3 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 4          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $a0     # Move GPR $4 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 5          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $a1     # Move GPR $5 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 6          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $a2     # Move GPR $6 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 7          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $a3     # Move GPR $7 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 8          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $t0     # Move GPR $8 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 9          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $t1     # Move GPR $9 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 10          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $t2     # Move GPR $10 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 11          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $t3     # Move GPR $11 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 12          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $t4     # Move GPR $12 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 13          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $t5     # Move GPR $13 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 14          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $t6     # Move GPR $14 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 15          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $t7     # Move GPR $15 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 16          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $s0     # Move GPR $16 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 17          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $s1     # Move GPR $17 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 18          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $s2     # Move GPR $18 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 19          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $s3     # Move GPR $19 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 20          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $s4     # Move GPR $20 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 21          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $s5     # Move GPR $21 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 22          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $s6     # Move GPR $22 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 23          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $s7     # Move GPR $23 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 24          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $t8     # Move GPR $24 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 25          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $t9     # Move GPR $25 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 26          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $k0     # Move GPR $26 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 27          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $k1     # Move GPR $27 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 28          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $gp     # Move GPR $28 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 29          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $sp     # Move GPR $29 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 30          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $fp     # Move GPR $30 value to $a0
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_comma_space
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_gpr_prefix
    syscall
    li $v0, 1           # syscall print_int
    li $a0, 31          # Load GPR index i
    syscall
    li $v0, 4           # syscall print_string
    la $a0, __d_colon_space
    syscall
    li $v0, 1           # syscall print_int
    move $a0, $ra     # Move GPR $31 value to $a0
    syscall

    li $v0, 4           # syscall print_string
    la $a0, __d_newline # Load address of newline string
    syscall             # Print newline before FPRs

    # --- Print FPRs ($f1, $f2, $f12 as int) ---
    li $v0, 4
    la $a0, __d_fpr1_prefix
    syscall
    mfc1 $t1, $f1         # Move bits of $f1 into GPR $t1
    li $v0, 1
    move $a0, $t1         # Move value from $t1 into $a0
    syscall
    li $v0, 4
    la $a0, __d_comma_space
    syscall
    li $v0, 4
    la $a0, __d_fpr2_prefix
    syscall
    mfc1 $t1, $f2         # Move bits of $f2 into GPR $t1
    li $v0, 1
    move $a0, $t1         # Move value from $t1 into $a0
    syscall
    li $v0, 4
    la $a0, __d_comma_space
    syscall
    li $v0, 4
    la $a0, __d_fpr12_prefix
    syscall
    mfc1 $t1, $f12        # Move bits of $f12 into GPR $t1
    li $v0, 1
    move $a0, $t1         # Move value from $t1 into $a0
    syscall

    li $v0, 4           # syscall print_string
    la $a0, __d_newline # Load address of newline string
    syscall             # Print first newline
    syscall             # Print second newline for separation

    # --- Restore Registers ---
    move $a0, $s3         # Restore caller's $a0 from $s3
    move $v0, $s4         # Restore caller's $v0 from $s4
    jr $ra                # Return
#---------------------------------------------------


.text
.globl main

main:
label0x00400000:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    j label0x0040000C

label0x00400004:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    add $t1, $ra, $zero

label0x00400008:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    jr $ra

label0x0040000C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lui $s7, 0x6000

label0x00400010:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    ori $sp, $s7, 0x0

label0x00400014:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s0, $sp, 0

label0x00400018:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s5, $sp, 4

label0x0040001C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s0, -16

label0x00400020:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    jal label0x00400004

label0x00400024:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $t1, 16

label0x00400028:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lui $s7, 0x8000

label0x0040002C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    ori $t2, $s7, 0x0

label0x00400030:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    or $t1, $t1, $t2

label0x00400034:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, -8($s0)

label0x00400038:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t8, $zero, 1

label0x0040003C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t9, $zero, 1

label0x00400040:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, -4

label0x00400044:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $zero, 8

label0x00400048:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 0($s1)

label0x0040004C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t1, 0($s1)

label0x00400050:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t0, $s0, -16

label0x00400054:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 0($t0)

label0x00400058:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, 4

label0x0040005C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    add $t0, $s0, $zero

label0x00400060:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, -4

label0x00400064:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t1, -16($t0)

label0x00400068:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 0($s1)

label0x0040006C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, -4

label0x00400070:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $zero, 1

label0x00400074:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 0($s1)

label0x00400078:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t2, 0($s1)

label0x0040007C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, 4

label0x00400080:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t1, 0($s1)

label0x00400084:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    slt $t3, $t1, $t2

label0x00400088:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    slt $t2, $t2, $t1

label0x0040008C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    or $t1, $t3, $t2

label0x00400090:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sub $t1, $t8, $t1

label0x00400094:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 0($s1)

label0x00400098:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t9, 0($s1)

label0x0040009C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, 4

label0x004000A0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t9, $zero, label0x00400174

label0x004000A4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, -4

label0x004000A8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $zero, 1

label0x004000AC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 0($s1)

label0x004000B0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t0, 0($s1)

label0x004000B4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    srl $t1, $t0, 29

label0x004000B8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t3, $zero, 7

label0x004000BC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t4, $zero, 4

label0x004000C0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t1, $zero, label0x00400154

label0x004000C4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t1, $t3, label0x00400154

label0x004000C8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t1, $t4, label0x00400108

label0x004000CC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t3, $zero, 3

label0x004000D0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    bne $t1, $t3, label0x004000F8

label0x004000D4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t1, 0($t0)

label0x004000D8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 11

label0x004000DC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    slt $t3, $zero, $t1

label0x004000E0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t3, $zero, label0x00400160

label0x004000E4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t0, $t0, 4

label0x004000E8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $a0, 0($t0)

label0x004000EC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x004000F0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $t1, -4

label0x004000F4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    j label0x004000DC

label0x004000F8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 2

label0x004000FC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    mtc1 $t0, $f12

label0x00400100:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400104:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    j label0x00400160

label0x00400108:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 11

label0x0040010C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 97

label0x00400110:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400114:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 108

label0x00400118:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040011C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 103

label0x00400120:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400124:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 32

label0x00400128:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040012C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 97

label0x00400130:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400134:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 116

label0x00400138:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040013C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 32

label0x00400140:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400144:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 1

label0x00400148:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    add $a0, $t0, $zero

label0x0040014C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400150:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    j label0x00400160

label0x00400154:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 1

label0x00400158:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    add $a0, $t0, $zero

label0x0040015C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400160:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, 4

label0x00400164:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 10

label0x00400168:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 11

label0x0040016C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400170:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t9, $zero, 1

label0x00400174:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    add $t0, $s0, $zero

label0x00400178:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, -4

label0x0040017C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t1, -16($t0)

label0x00400180:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 0($s1)

label0x00400184:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, -4

label0x00400188:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $zero, 2

label0x0040018C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 0($s1)

label0x00400190:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t2, 0($s1)

label0x00400194:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, 4

label0x00400198:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t1, 0($s1)

label0x0040019C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    slt $t3, $t1, $t2

label0x004001A0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    slt $t2, $t2, $t1

label0x004001A4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    or $t1, $t3, $t2

label0x004001A8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sub $t1, $t8, $t1

label0x004001AC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 0($s1)

label0x004001B0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    bne $t9, $zero, label0x00400290

label0x004001B4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t9, 0($s1)

label0x004001B8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, 4

label0x004001BC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t9, $zero, label0x00400290

label0x004001C0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, -4

label0x004001C4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $zero, 2

label0x004001C8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 0($s1)

label0x004001CC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t0, 0($s1)

label0x004001D0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    srl $t1, $t0, 29

label0x004001D4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t3, $zero, 7

label0x004001D8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t4, $zero, 4

label0x004001DC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t1, $zero, label0x00400270

label0x004001E0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t1, $t3, label0x00400270

label0x004001E4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t1, $t4, label0x00400224

label0x004001E8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t3, $zero, 3

label0x004001EC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    bne $t1, $t3, label0x00400214

label0x004001F0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t1, 0($t0)

label0x004001F4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 11

label0x004001F8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    slt $t3, $zero, $t1

label0x004001FC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t3, $zero, label0x0040027C

label0x00400200:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t0, $t0, 4

label0x00400204:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $a0, 0($t0)

label0x00400208:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040020C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $t1, -4

label0x00400210:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    j label0x004001F8

label0x00400214:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 2

label0x00400218:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    mtc1 $t0, $f12

label0x0040021C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400220:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    j label0x0040027C

label0x00400224:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 11

label0x00400228:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 97

label0x0040022C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400230:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 108

label0x00400234:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400238:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 103

label0x0040023C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400240:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 32

label0x00400244:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400248:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 97

label0x0040024C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400250:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 116

label0x00400254:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400258:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 32

label0x0040025C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400260:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 1

label0x00400264:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    add $a0, $t0, $zero

label0x00400268:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040026C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    j label0x0040027C

label0x00400270:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 1

label0x00400274:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    add $a0, $t0, $zero

label0x00400278:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040027C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, 4

label0x00400280:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 10

label0x00400284:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 11

label0x00400288:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040028C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t9, $zero, 1

label0x00400290:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    add $t0, $s0, $zero

label0x00400294:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, -4

label0x00400298:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t1, -16($t0)

label0x0040029C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 0($s1)

label0x004002A0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, -4

label0x004002A4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $zero, 3

label0x004002A8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 0($s1)

label0x004002AC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t2, 0($s1)

label0x004002B0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, 4

label0x004002B4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t1, 0($s1)

label0x004002B8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    slt $t3, $t1, $t2

label0x004002BC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    slt $t2, $t2, $t1

label0x004002C0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    or $t1, $t3, $t2

label0x004002C4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sub $t1, $t8, $t1

label0x004002C8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 0($s1)

label0x004002CC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    bne $t9, $zero, label0x004003AC

label0x004002D0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t9, 0($s1)

label0x004002D4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, 4

label0x004002D8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t9, $zero, label0x004003AC

label0x004002DC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, -4

label0x004002E0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $zero, 3

label0x004002E4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 0($s1)

label0x004002E8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t0, 0($s1)

label0x004002EC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    srl $t1, $t0, 29

label0x004002F0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t3, $zero, 7

label0x004002F4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t4, $zero, 4

label0x004002F8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t1, $zero, label0x0040038C

label0x004002FC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t1, $t3, label0x0040038C

label0x00400300:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t1, $t4, label0x00400340

label0x00400304:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t3, $zero, 3

label0x00400308:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    bne $t1, $t3, label0x00400330

label0x0040030C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t1, 0($t0)

label0x00400310:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 11

label0x00400314:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    slt $t3, $zero, $t1

label0x00400318:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t3, $zero, label0x00400398

label0x0040031C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t0, $t0, 4

label0x00400320:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $a0, 0($t0)

label0x00400324:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400328:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $t1, -4

label0x0040032C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    j label0x00400314

label0x00400330:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 2

label0x00400334:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    mtc1 $t0, $f12

label0x00400338:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040033C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    j label0x00400398

label0x00400340:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 11

label0x00400344:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 97

label0x00400348:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040034C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 108

label0x00400350:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400354:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 103

label0x00400358:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040035C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 32

label0x00400360:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400364:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 97

label0x00400368:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040036C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 116

label0x00400370:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400374:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 32

label0x00400378:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040037C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 1

label0x00400380:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    add $a0, $t0, $zero

label0x00400384:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400388:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    j label0x00400398

label0x0040038C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 1

label0x00400390:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    add $a0, $t0, $zero

label0x00400394:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400398:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, 4

label0x0040039C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 10

label0x004003A0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 11

label0x004003A4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x004003A8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t9, $zero, 1

label0x004003AC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    bne $t9, $zero, label0x004004AC

label0x004003B0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    add $t0, $s5, $zero

label0x004003B4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s5, $s5, 20

label0x004003B8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $zero, 16

label0x004003BC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 0($t0)

label0x004003C0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $zero, 110

label0x004003C4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 4($t0)

label0x004003C8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $zero, 111

label0x004003CC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 8($t0)

label0x004003D0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $zero, 110

label0x004003D4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 12($t0)

label0x004003D8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $zero, 101

label0x004003DC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t1, 16($t0)

label0x004003E0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, -4

label0x004003E4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    sw $t0, 0($s1)

label0x004003E8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t0, 0($s1)

label0x004003EC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    srl $t1, $t0, 29

label0x004003F0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t3, $zero, 7

label0x004003F4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t4, $zero, 4

label0x004003F8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t1, $zero, label0x0040048C

label0x004003FC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t1, $t3, label0x0040048C

label0x00400400:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t1, $t4, label0x00400440

label0x00400404:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t3, $zero, 3

label0x00400408:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    bne $t1, $t3, label0x00400430

label0x0040040C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $t1, 0($t0)

label0x00400410:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 11

label0x00400414:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    slt $t3, $zero, $t1

label0x00400418:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    beq $t3, $zero, label0x00400498

label0x0040041C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t0, $t0, 4

label0x00400420:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    lw $a0, 0($t0)

label0x00400424:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400428:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t1, $t1, -4

label0x0040042C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    j label0x00400414

label0x00400430:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 2

label0x00400434:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    mtc1 $t0, $f12

label0x00400438:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040043C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    j label0x00400498

label0x00400440:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 11

label0x00400444:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 97

label0x00400448:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040044C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 108

label0x00400450:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400454:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 103

label0x00400458:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040045C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 32

label0x00400460:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400464:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 97

label0x00400468:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040046C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 116

label0x00400470:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400474:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 32

label0x00400478:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x0040047C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 1

label0x00400480:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    add $a0, $t0, $zero

label0x00400484:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400488:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    j label0x00400498

label0x0040048C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 1

label0x00400490:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    add $a0, $t0, $zero

label0x00400494:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x00400498:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $s1, $s1, 4

label0x0040049C:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 10

label0x004004A0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 11

label0x004004A4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x004004A8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $t9, $zero, 1

label0x004004AC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 10

label0x004004B0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 11

label0x004004B4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x004004B8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 10

label0x004004BC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x004004C0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 11

label0x004004C4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 69

label0x004004C8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x004004CC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 82

label0x004004D0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x004004D4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 82

label0x004004D8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x004004DC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 79

label0x004004E0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x004004E4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 82

label0x004004E8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x004004EC:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $a0, $zero, 10

label0x004004F0:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

label0x004004F4:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    addi $v0, $zero, 10

label0x004004F8:
    move $s6, $ra         # Save original $ra before dump call
    jal __print_registers # Call routine to dump GPRs/FPRs
    move $ra, $s6         # Restore original $ra after dump call

    syscall

