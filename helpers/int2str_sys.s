main_convert_to_string_v3:
    # --- Setup ---
    # Save initial stack pointers. $t7 = initial $s1, $a2 = initial $s5.
    add  $t7, $s1, $zero   # Use add rd, rs, $zero (move pseudo)
    add  $a2, $s5, $zero   # $a2 holds the target base address for the result string

    # Save initial $s5 pointer onto the $s1 stack for later restoration.
    addi $s1, $s1, -4     # Decrement $s1 to make space
    sw   $s5, 0($s1)       # Store initial $s5

    # Load the input value (int or float bits)
    lw   $t0, 0($t7)       # Load from original location using saved initial $s1 ($t7)

    # Set $t8 = 1 (Rule 4)
    addi $t8, $zero, 1     # Load immediate 1

    # --- Type Checking ---
    # Extract the type bits (most significant 3 bits) into $t1.
    srl  $t1, $t0, 29

    # Check for Integer (000 or 111)
    beq  $t1, $zero, process_integer_c2s_stack_v3 # Type 000
    addi $t3, $zero, 7      # Load immediate 7
    beq  $t1, $t3, process_integer_c2s_stack_v3 # Type 111

    # Check for Invalid Types (Error: 011=str/list, 100=alg)
    addi $t3, $zero, 3      # Load immediate 3
    beq  $t1, $t3, error     # Type 011 -> Error
    addi $t4, $zero, 4      # Load immediate 4
    beq  $t1, $t4, error     # Type 100 -> Error

    # If it passes all above, it's a float, which we won't allow to be passed as input to 'str'
    j error

#-----------------------------------------------------
# Integer to String Conversion (v3)
# Input: $t0=int value. Uses $s1 stack for temp digits. Builds result on $s5 stack (base $a2).
# Output: Final $s5 points after result. Result address ($a2) written to 0($t7).
# Clobbers: $t0-t6, $a0. Saves/Restores them using $s1 stack.
#-----------------------------------------------------
process_integer_c2s_stack_v3:
    # --- Save Registers (GPRs $t0-$t6, $a0 = 8 regs * 4 = 32 bytes) ---
    addi $s1, $s1, -32
    sw   $t0, 0($s1)
    sw   $t1, 4($s1) # Holds digit count
    sw   $t2, 8($s1) # Working copy of number
    sw   $t3, 12($s1)# Base 10 / Temp
    sw   $t4, 16($s1)# Remainder / ASCII Digit
    sw   $t5, 20($s1)# Sign Flag
    sw   $t6, 24($s1)# Total char count N
    sw   $a0, 28($s1)# Used for syscall debug only

    # --- Conversion Logic ---
    addi $t5, $zero, 0     # $t5 = sign flag (0=positive, 1=negative)
    add  $t2, $t0, $zero   # Copy input integer to $t2 for processing
    addi $t3, $zero, 10    # $t3 = 10 for division
    addi $t1, $zero, 0     # $t1 = count of digits generated = 0

    # Handle Zero Integer Input
    beq  $t2, $zero, int_is_zero_c2s_v3

    # Handle Negative Numbers
    # Use slt: $t4 = 1 if $t2 < 0.
    slt  $t4, $t2, $zero
    beq  $t4, $zero, int_positive_loop_c2s_v3 # Branch if $t2 >= 0.

int_is_negative_c2s_v3:
    addi $t5, $zero, 1     # Set sign flag to negative.
    sub  $t2, $zero, $t2   # Negate $t2 ($t2 = 0 - $t2).
    # Fall through to conversion loop

int_positive_loop_c2s_v3:
    beq  $t2, $zero, int_digits_done_c2s_v3 # If number is 0, done generating digits.
    # Assume standard MIPS 'div' pseudo-instruction or sequence available
    div  $t2, $t3          # Divide $t2 by $t3 (10). LO=quotient, HI=remainder.
    mflo $t2               # Quotient stored back in $t2.
    mfhi $t4               # Remainder stored in $t4 (0-9).

    addi $t4, $t4, 48      # Convert digit (0-9) to ASCII ('0'-'9').
    addi $s1, $s1, -4      # Push ASCII digit onto $s1 stack
    sw   $t4, 0($s1)
    addi $t1, $t1, 1       # Increment digit count

    j    int_positive_loop_c2s_v3

int_is_zero_c2s_v3:
    addi $t4, $zero, 48    # Load immediate ASCII '0'.
    addi $s1, $s1, -4      # Push '0' onto $s1 stack
    sw   $t4, 0($s1)
    addi $t1, $t1, 1       # Increment digit count ($t1 = 1)

int_digits_done_c2s_v3:
    # Digits are on $s1 stack (LSB deepest), count in $t1, sign flag in $t5.
    # Result base address is in $a2 (initial $s5).

    # --- Assemble String on $s5 Stack ---
    # Calculate final character count N ($t6)
    add $t6, $t1, $t5      # N = digit_count($t1) + sign_flag($t5)

    # Write size header (4*N) to 0($a2)
    sll $t4, $t6, 2        # $t4 = N * 4
    sw  $t4, 0($a2)        # Store size header

    # Setup write pointer ($t0) for $s5 stack, starting after header
    add $t0, $a2, $zero
    addi $t0, $t0, 4

    # Write sign if negative ($t5 == 1)
    beq $t5, $zero, int_skip_sign_c2s_v3
    addi $t4, $zero, 45    # ASCII '-'
    sw   $t4, 0($t0)       # Write sign word
    addi $t0, $t0, 4       # Advance $s5 write pointer
int_skip_sign_c2s_v3:

    # Pop digits from $s1 and write (in reverse order) to $s5 stack space
    # $t1 holds digit count (use as loop counter)
int_reverse_copy_loop_c2s_v3:
    beq $t1, $zero, int_copy_done_c2s_v3 # Loop until count is 0
    lw   $t4, 0($s1)       # Pop digit (MSB first now)
    addi $s1, $s1, 4       # Adjust $s1 stack
    sw   $t4, 0($t0)       # Write digit word to $s5 space
    addi $t0, $t0, 4       # Advance $s5 write pointer
    addi $t1, $t1, -1      # Decrement digit count
    j    int_reverse_copy_loop_c2s_v3

int_copy_done_c2s_v3:
    # Update final $s5 register to point after the last written word
    add $s5, $t0, $zero

    # --- Restore Registers ---
    lw   $a0, 28($s1)
    lw   $t6, 24($s1)
    lw   $t5, 20($s1)
    lw   $t4, 16($s1)
    lw   $t3, 12($s1)
    lw   $t2, 8($s1)
    lw   $t1, 4($s1)
    lw   $t0, 0($s1)
    addi $s1, $s1, 32    # Restore $s1 stack pointer

    j    cleanup_c2s_stack_v3 # Go to common cleanup

#-----------------------------------------------------
# Cleanup
#-----------------------------------------------------
cleanup_c2s_stack_v3:
    addi $s1, $s1, 4       # Pop the saved initial $s5 value

    # Restore initial $s1 (held in $t7)

    # Final step: Write the result address ($a2, which holds initial $s5)
    # back to the original memory location (0($t7)).
    sw   $a2, 0($t7)

    # Ensure $s1 is restored to its very initial value for the caller.
    add $s1, $t7, $zero    # Restore $s1 from $t7