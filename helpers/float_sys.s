# Conversion to float
lw   $t0, 0($s1)       # Load the value (pointer, int, float) from memory into $t0.
srl  $t1, $t0, 29      # Extract the type bits (most significant 3 bits) into $t1.
addi $t3, $zero, 7      # $t3 = 7 (binary 111, for int type).
addi $t4, $zero, 4      # $t4 = 4 (binary 100, for alg type).
beq  $t1, $zero, int_float_convert  # If type bits are 000, jump to int_float_convert
beq  $t1, $t3, int_float_convert  # If type bits are 111, jump to integer_float_convert.
beq  $t1, $t4, error  # If type bits are 100, jump to error as algorithhms can't be converted to floats.
addi $t3, $zero, 3      # $t3 = 3 (binary 011, for str/list type).
bne  $t1, $t3, end_float_convert # If type bits are not 011, must be float.
# else, it's a string
string_float_convert:
    lw   $t2, 0($t0)       # Load the byte offset from the start of the string structure ($t0).
    srl  $t2, $t2, 2       # Convert byte offset to word count (number of words including this first one).
    addi $t0, $t0, 4       # Advance $t0 to point to the first character's word.
    addi $t5, $zero, 0     # $t5 = 0. Initialize the integer result accumulator.
    addi $t7, $zero, 0     # This will hold number of decimal scpaces
    addi $s4, $zero, 46    # '.'
    string_float_convert_loop:
        beq  $t2, $zero, string_float_convert_loop_end # If counter ($t2) is zero, all digits processed, exit loop.
        lw   $t3, 0($t0)       # Load the word containing the ASCII code of the current digit into $t3.
        addi $t2,$t2,-1 # Decrement the remaining character count ($t2).
        addi $t0,$t0,4 # Advance pointer ($t0) to the next character's word.
        # Check if it is a '.' character. If not, skip
        bne $t3,$s4,string_flot_convert_skip_if_not_dot
        bne $t7,$zero,error # if this is the second dot we are seeing, the string cannot be converted to float.
        add $t7,$t2,$zero # number of characters after the dot.
        j string_float_convert_loop # this character is done. Go back to loop
        string_flot_convert_skip_if_not_dot:
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
        sll $t5, $t5, 1        # $t5 = $t5 * 2 (Shift left logical by 1 bit).
        add $t5, $t6, $t5      # current result * 10.
        # Add the integer value of the current digit.
        add  $t5, $t5, $t3     # $t5 = (result * 10) + digit_value.
        # Prepare for the next iteration.
        j string_float_convert_loop # Jump back to the start of the loop.
    string_float_convert_loop_end:

    # #DEBUG
    # addi $v0,$zero,1
    # add $a0,$t5,$zero
    # syscall
    # addi $v0,$zero,11
    # addi $a0,$zero,10
    # syscall
    # addi $v0,$zero,1
    # add $a0,$t7,$zero
    # syscall
    # addi $v0,$zero,11
    # addi $a0,$zero,10
    # syscall

    # calculating $t5 * 10^-$t7

        # --- Setup Constants ---
        addi $t6, $zero, 10  # $t6 = 10 (integer base for power calculation)
        mtc1 $t8, $f2        # Move integer 1 to $f2
        cvt.s.w $f2, $f2     # Convert $f2 to float 1.0

        # --- Calculate 10^y using Integer Exponentiation by Squaring ---
        # Registers for power calculation:
        # $t0: current base (starts at 10, gets squared)
        # $t1: result (starts at 1, accumulates base when exponent is odd)
        # $t4: remaining exponent (copy of y, gets halved)
        # $t2: temporary for checking odd exponent

        addi $t1, $zero, 1  # Initialize result = 1
        move $t0, $t6       # Initialize base = 10
        move $t4, $t7       # Copy y to $t4 (exponent)

        string_float_convert_power_loop_int:
            beq $t4, $zero, string_float_convert_power_loop_int_end # If exponent is 0, we are done

            # Check if exponent is odd
            andi $t2, $t4, 1      # $t2 = exponent & 1
            beq $t2, $zero, string_float_convert_exponent_even # Skip multiplication if exponent is even

            # Exponent is odd: result = result * base
            # Using MIPS integer multiplication (stores 64-bit result in HI/LO)
            # Assume result fits in 32 bits (LO) for simplicity
            mult $t1, $t0         # result * base
            mflo $t1              # $t1 = low 32 bits of result

        string_float_convert_exponent_even:
            # Square the base: base = base * base
            mult $t0, $t0         # base * base
            mflo $t0              # $t0 = low 32 bits of base^2

            # Halve the exponent: exponent = exponent / 2
            srl $t4, $t4, 1       # Logical shift right by 1 (integer division by 2)

            j string_float_convert_power_loop_int      # Repeat loop

        string_float_convert_power_loop_int_end:
        # Integer 10^y is now in $t1

        # --- Convert x and 10^y to Floating Point ---
        mtc1 $t5, $f4        # Move x ($t5) to $f4
        cvt.s.w $f4, $f4     # Convert x ($f4) to float

        mtc1 $t1, $f6        # Move integer 10^y ($t1) to $f6
        cvt.s.w $f6, $f6     # Convert 10^y ($f6) to float

        # --- Calculate 1.0 / (10^y) ---
        # $f2 contains 1.0
        # $f6 contains float(10^y)
        div.s $f8, $f2, $f6  # $f8 = 1.0 / float(10^y)

        # --- Calculate final result: x * (10^-y) ---
        # $f4 contains float(x)
        # $f8 contains float(10^-y)
        mul.s $f12, $f4, $f8  # $f1 = float(x) * float(10^-y)

        mfc1 $t5,$f12

    #End of $t5 * 10^-$t7 calculation

    sw $t5, 0($s1) # Store the final integer result from $t5 back into the original memory location.
    j end_float_convert # Jump to the common end_convert point.

int_float_convert:
    mtc1 $t0,$f1
    cvt.s.w $f2,$f1
    mfc1 $t5,$f2
    sw $t5,0($s1) 

end_float_convert:
