# Conversion to integer
lw   $t0, 0($s1)       # Load the value (pointer, int, float) from memory into $t0.
srl  $t1, $t0, 29      # Extract the type bits (most significant 3 bits) into $t1.
addi $t3, $zero, 7      # $t3 = 7 (binary 111, for int type).
addi $t4, $zero, 4      # $t4 = 4 (binary 100, for alg type).
beq  $t1, $zero, end_int_convert  # If type bits are 000, jump to integer (no conversion needed).
beq  $t1, $t3, end_int_convert  # If type bits are 111, jump to integer (no conversion needed).
beq  $t1, $t4, error  # If type bits are 100, jump to error as algorithhms can't be converted to integers.
addi $t3, $zero, 3      # $t3 = 3 (binary 011, for str/list type).
bne  $t1, $t3, float_int_convert # If type bits are not 011, must be float; jump to float conversion (treat as 0).

string_int_convert:
    lw   $t2, 0($t0)       # Load the byte offset from the start of the string structure ($t0).
    srl  $t2, $t2, 2       # Convert byte offset to word count (number of words including this first one).
    addi $t0, $t0, 4       # Advance $t0 to point to the first character's word.
    li   $t5, 0            # $t5 = 0. Initialize the integer result accumulator.
    string_int_convert_loop:
        beq  $t2, $zero, string_int_convert_loop_end # If counter ($t2) is zero, all digits processed, exit loop.
        lw   $t3, 0($t0)       # Load the word containing the ASCII code of the current digit into $t3.
        # Validate character: Check if $t3 < '0' (ASCII 48)
        addi $t6, $zero, 48    # '0'
        slt  $t4, $t3, $t6     # $t4 = 1 if $t3 < 48, else $t4 = 0.
        bne  $t4, $zero, error # If $t4 is not zero ($t3 < '0'), jump to the error label.
        # Validate character: Check if $t3 > '9' (ASCII 57)
        addi $t6, $zero, 58    # '9'
        slt  $t4, $t3, $t6     # $t4 = 1 if $t3 < 58 (i.e., $t3 <= 57), else $t4 = 0.
        beq  $t4, $zero, error # If $t4 is zero ($t3 > '9'), jump to the error label.
        # Character is valid ('0' - '9'), proceed with conversion.
        addi $t3, $t3, -48      # Convert ASCII digit ('0' is 48) to its integer value (0-9).
        # Update result: result = result * 10 + digit_value
        # Calculate result * 10 using shifts and add ($t5 holds current result).
        sll $t6, $t5, 3        # $t6 = $t5 * 8 (Shift left logical by 3 bits).
        sll $t7, $t5, 1        # $t7 = $t5 * 2 (Shift left logical by 1 bit).
        add $t5, $t6, $t7      # $t5 = ($t5 * 8) + ($t5 * 2) = current result * 10.
        # Add the integer value of the current digit.
        add  $t5, $t5, $t3     # $t5 = (result * 10) + digit_value.
        # Prepare for the next iteration.
        addi $t0,$t0,4 # Advance pointer ($t0) to the next character's word.
        addi $t2,$t2,-1 # Decrement the remaining character count ($t2).
        j string_int_convert_loop # Jump back to the start of the loop.
    string_int_convert_loop_end:
    sw $t5, 0($s1) # Store the final integer result from $t5 back into the original memory location.
    j end_int_convert # Jump to the common end_convert point.

float_int_convert:
    mtc1 $t0,$f1
    cvt.w.s $f2,$f1
    mfc1 $t5,$f2
    sw $t5,0($s1) 

end_int_convert:
