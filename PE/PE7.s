# This code can be run on the Virtual Machine PyVM that comes bundled with the project

.data
.text
.globl main
j main # this is because the VM goes to the first line directly, and not to main.

pathfinder:
add $t1,$ra,$zero
jr $ra

main:
li $sp,0x60000000
addi $s0,$sp,0
addi $s5,$sp,4
addi $s1,$s0,-12

jal pathfinder
addi $t1,$t1,16
li $t2,0x80000000
or $t1,$t1,$t2
sw $t1,-8($s0)

thestart:
addi $t8,$zero,1
addi $t9,$zero,1

# syscalls

# Syscall Declaration
add $t2,$ra,$zero # save current ra
jal pathfinder # find path of next line
add $ra,$t2,$zero # restore ra
addi $t1,$t1,28 # address to start the syscall
sll $t2,$t8,31 # 0x80000000
or $t1,$t1,$t2 # adjust $t1 to point to start label
addi $s1,$s1,-4 # new slot in stack
sw $t1,0($s1) # add syscall to stack
j label2 # skip function
label1:

# No named arguments. This is a syscall

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


# return
lw $t0,0($s0) # caller's base
lw $t1,0($s1) # return value
sw $t1,0($s0) # store return value at base
addi $t9,$zero,1 # assert that return happened
add $s1,$s0,$zero # restore stack pointer
add $s0,$zero,$t0 # restore base pointer
jr $ra # return
# End of return
label2: # end of function

# Add this to parent pointer tree (optional)
lw $t2,-8($s0) # parent (global scope)
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5
sw $t2,0($t1) # child -> parent
sw $zero,4($t1) # child has null as its copy, since it's not dead yet

# Syscall Declaration
add $t2,$ra,$zero # save current ra
jal pathfinder # find path of next line
add $ra,$t2,$zero # restore ra
addi $t1,$t1,28 # address to start the syscall
sll $t2,$t8,31 # 0x80000000
or $t1,$t1,$t2 # adjust $t1 to point to start label
addi $s1,$s1,-4 # new slot in stack
sw $t1,0($s1) # add syscall to stack
j label4 # skip function
label3:

# No named arguments. This is a syscall

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


# return
lw $t0,0($s0) # caller's base
lw $t1,0($s1) # return value
sw $t1,0($s0) # store return value at base
addi $t9,$zero,1 # assert that return happened
add $s1,$s0,$zero # restore stack pointer
add $s0,$zero,$t0 # restore base pointer
jr $ra # return
# End of return
label4: # end of function

# Add this to parent pointer tree (optional)
lw $t2,-8($s0) # parent (global scope)
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5
sw $t2,0($t1) # child -> parent
sw $zero,4($t1) # child has null as its copy, since it's not dead yet

# Syscall Declaration
add $t2,$ra,$zero # save current ra
jal pathfinder # find path of next line
add $ra,$t2,$zero # restore ra
addi $t1,$t1,28 # address to start the syscall
sll $t2,$t8,31 # 0x80000000
or $t1,$t1,$t2 # adjust $t1 to point to start label
addi $s1,$s1,-4 # new slot in stack
sw $t1,0($s1) # add syscall to stack
j label6 # skip function
label5:

# No named arguments. This is a syscall

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

# return
lw $t0,0($s0) # caller's base
lw $t1,0($s1) # return value
sw $t1,0($s0) # store return value at base
addi $t9,$zero,1 # assert that return happened
add $s1,$s0,$zero # restore stack pointer
add $s0,$zero,$t0 # restore base pointer
jr $ra # return
# End of return
label6: # end of function

# Add this to parent pointer tree (optional)
lw $t2,-8($s0) # parent (global scope)
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5
sw $t2,0($t1) # child -> parent
sw $zero,4($t1) # child has null as its copy, since it's not dead yet

# Syscall Declaration
add $t2,$ra,$zero # save current ra
jal pathfinder # find path of next line
add $ra,$t2,$zero # restore ra
addi $t1,$t1,28 # address to start the syscall
sll $t2,$t8,31 # 0x80000000
or $t1,$t1,$t2 # adjust $t1 to point to start label
addi $s1,$s1,-4 # new slot in stack
sw $t1,0($s1) # add syscall to stack
j label8 # skip function
label7:

# No named arguments. This is a syscall

# --- Print Prompt using Structure Pointer from $s1 ---
# Load base address pointer from $s1 stack top
    lw $t6, 0($s1)     # $t6 = base address of prompt structure
#addi $s1, $s1, 4 # Pop the pointer from $s1 stack
# Load size (4N) from structure base
    lw $t3, 0($t6)     # $t3 = prompt size in bytes (64)
# Calculate N (number of chars): N = Size / 4
    srl $t3, $t3, 2    # $t3 = prompt length N (16)

# Set pointer to the first character word in the structure
    addi $t0, $t6, 4   # $t0 = address of first character word ('E')

# Initialize loop counter
    add $t4, $zero, $zero  # $t4 = count of chars printed

print_prompt_loop:
# Check if all characters printed ($t4 >= N?)
    slt $t2, $t4, $t3   # $t2 = 1 if $t4 < N, else 0
    beq $t2, $zero, end_print_prompt_loop # Branch if $t2 is 0 ($t4 >= N)

# Load character word from the structure
    lw $a0, 0($t0)     # Load word into $a0
# Print the character
    ori $v0, $zero, 11 # syscall 11
    syscall
# Increment total printed counter
    addi $t4, $t4, 1
# Increment structure pointer
    addi $t0, $t0, 4
    j print_prompt_loop

end_print_prompt_loop:
# Prompt printing finished.
# --- End Print Prompt ---

# --- Prepare for User Input ---
# Input buffer starts at the current $s5
    add $t6, $s5, $zero   # $t6 = Base address for user input buffer

# Read the user string input into buffer starting at $t6
    ori $v0, $zero, 8        # syscall 8
    add $a0, $t6, $zero      # Address of buffer ($t6)
    ori $a1, $zero, 101      # Max length
    syscall

# --- Stage 1: Store user characters on stack ($s1) and count length N ---

    add $t0, $t6, $zero      # $t0 = pointer to current char in input buffer
    add $t3, $zero, $zero    # $t3 = user string length N counter

store_loop:
    lb $t2, 0($t0)     # Load character from input buffer into $t2

# Check for newline (10) or null (0) terminator
    ori $t4, $zero, 10 # ASCII newline
    beq $t2, $t4, end_store_loop
    beq $t2, $zero, end_store_loop # Check for null

# If not terminator:
# 1. Decrement $s1 stack pointer
    addi $s1, $s1, -4
# 2. Store the character word onto $s1 stack
    sw $t2, 0($s1)
# 3. Increment length counter N
    addi $t3, $t3, 1
# 4. Increment input buffer pointer
    addi $t0, $t0, 1
    j store_loop

end_store_loop:
# User string length N is now in $t3
# $s1 points to the word containing the *last* user character pushed

# --- Stage 1.5: Create user "string" structure on $s5 stack (Corrected Order) ---
# Reserve space for input buffer (104 bytes aligned) then create structure.
# Structure starts at $t6 + 104.
    addi $t7, $t6, 104 # $t7 = Base address for the new user structure

# Calculate Size (4N): Size = N * 4
    sll $t2, $t3, 2    # $t2 = Size in bytes (4*N)

# Store Size (4N) at the beginning of the structure
    sw $t2, 0($t7)

# Calculate address for the *last* character slot in the destination structure
    # Offset of last char = 4 * (N - 1)
    addi $t4, $t3, -1  # $t4 = N - 1
    sll $t4, $t4, 2    # $t4 = 4 * (N - 1)
    # Address = Base + 4 (skip size) + Offset
    addi $t5, $t7, 4   # $t5 = Address after size word
    add $t5, $t5, $t4  # $t5 = Address of the LAST character slot

# Initialize loop counter for copy (use N from $t3)
    add $t4, $t3, $zero # $t4 = number of characters N to copy

copy_loop:
    beq $t4, $zero, end_copy_loop # Exit if count N reaches zero

# Load character word from current $s1 stack top (last char pushed first)
    lw $t2, 0($s1)
# Store character word at destination slot $t5 (filling from end backwards)
    sw $t2, 0($t5)

# "Pop" from $s1 stack (move pointer up towards first char pushed)
    addi $s1, $s1, 4
# Decrement destination pointer (move towards first char slot)
    addi $t5, $t5, -4
# Decrement copy counter N
    addi $t4, $t4, -1
    j copy_loop

end_copy_loop:
# $s1 now points back up, effectively clearing the pushed user chars from its view.
# Structure created correctly at $t7.

# Update $s5 register to point past the new structure.
# New top = Base ($t7) + SizeWord (4) + CharBytes (4*N = $t2)
    addi $t5, $t7, 4   # $t5 = Address after size word
    lw $t2, 0($t7)     # Reload $t2 with Size (4*N) just in case
    add $s5, $t5, $t2  # $s5 = $t7 + 4 + 4*N = New top of $s5 stack

# Store on stack
sw $t7,0($s1)

# return
lw $t0,0($s0) # caller's base
lw $t1,0($s1) # return value
sw $t1,0($s0) # store return value at base
addi $t9,$zero,1 # assert that return happened
add $s1,$s0,$zero # restore stack pointer
add $s0,$zero,$t0 # restore base pointer
jr $ra # return
# End of return
label8: # end of function

# Add this to parent pointer tree (optional)
lw $t2,-8($s0) # parent (global scope)
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5
sw $t2,0($t1) # child -> parent
sw $zero,4($t1) # child has null as its copy, since it's not dead yet

# Syscall Declaration
add $t2,$ra,$zero # save current ra
jal pathfinder # find path of next line
add $ra,$t2,$zero # restore ra
addi $t1,$t1,28 # address to start the syscall
sll $t2,$t8,31 # 0x80000000
or $t1,$t1,$t2 # adjust $t1 to point to start label
addi $s1,$s1,-4 # new slot in stack
sw $t1,0($s1) # add syscall to stack
j label10 # skip function
label9:

# No named arguments. This is a syscall

# getting length lw $t0,0($s1) # load list/str
lw $t1,0($t0) # 4N
srl $t1,$t1,2 # N
sw $t1,0($s1) #replaced with length

# return
lw $t0,0($s0) # caller's base
lw $t1,0($s1) # return value
sw $t1,0($s0) # store return value at base
addi $t9,$zero,1 # assert that return happened
add $s1,$s0,$zero # restore stack pointer
add $s0,$zero,$t0 # restore base pointer
jr $ra # return
# End of return
label10: # end of function

# Add this to parent pointer tree (optional)
lw $t2,-8($s0) # parent (global scope)
li $t5,0x7F000000
li $t6,0x1FFFFFFF
and $t1,$t1,$t6
or $t1,$t1,$t5
sw $t2,0($t1) # child -> parent
sw $zero,4($t1) # child has null as its copy, since it's not dead yet


# syscalls over

# making space for globals
addi $s1,$s0,-56

# main code 

# Definition : N is -36($s0)

# int 300000
li $t1,300000
addi $s1,$s1,-4
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-36 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : L is -40($s0)

# getting N
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-36($t0)
sw $t1,0($s1)

# list
add $t0,$s5,$zero
lw $t1,0($s1) # n
sll $t1,$t1,2 # 4n
addi $t2,$t1,4 # 4n+4
add $s5,$s5,$t2 # inc $s5 by 4n+4
sw $t0,0($s1) # store pointer on stack
sw $t1,0($t0) # store 4n as first thing

lw $t1,0($s1) # get value
addi $t0,$s0,-40 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : i is -44($s0)

# int 0
li $t1,0
addi $s1,$s1,-4
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-44 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

label11_start: # while 

# getting i
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-44($t0)
sw $t1,0($s1)

# getting N
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-36($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t1,$t1,$t2
sw $t1,0($s1)
lw $t9,0($s1)
addi $s1,$s1,4
slt $t1,$zero,$t9
slt $t9,$t9,$zero
or $t9,$t9,$t1
beq $t9,$zero,label11_end

# int 1
li $t1,1
addi $s1,$s1,-4
sw $t1,0($s1)

# Assignment
# Getting index
# getting i
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-44($t0)
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2=t2*4
lw $t0,-40($s0) # load pointer
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
lw $t1,4($s1) # load value to be assignment
add $t0,$t2,$t0 # get address on memory location
addi $t0,$t0,4 # still getting address..
sw $t1,0($t0) # store value to address
addi $s1,$s1,8 #clear both index and value

# getting i
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-44($t0)
sw $t1,0($s1)

# int 1
li $t1,1
addi $s1,$s1,-4
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
add $t1,$t1,$t2
sw $t1,0($s1)

# Assignment
# getting i
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-44($t0)
addi $s1,$s1,4



j label11_start
label11_end: # end while

# int 0
li $t1,0
addi $s1,$s1,-4
sw $t1,0($s1)

# Assignment
# Getting index
# int 0
li $t1,0
addi $s1,$s1,-4
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2=t2*4
lw $t0,-40($s0) # load pointer
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
lw $t1,4($s1) # load value to be assignment
add $t0,$t2,$t0 # get address on memory location
addi $t0,$t0,4 # still getting address..
sw $t1,0($t0) # store value to address
addi $s1,$s1,8 #clear both index and value

# int 0
li $t1,0
addi $s1,$s1,-4
sw $t1,0($s1)

# Assignment
# Getting index
# int 1
li $t1,1
addi $s1,$s1,-4
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2=t2*4
lw $t0,-40($s0) # load pointer
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
lw $t1,4($s1) # load value to be assignment
add $t0,$t2,$t0 # get address on memory location
addi $t0,$t0,4 # still getting address..
sw $t1,0($t0) # store value to address
addi $s1,$s1,8 #clear both index and value

# Definition : p is -48($s0)

# int 1
li $t1,1
addi $s1,$s1,-4
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-48 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# Definition : x is -52($s0)

# Definition : counter is -56($s0)

# int 0
li $t1,0
addi $s1,$s1,-4
sw $t1,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-56 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

label12_start: # while 

# getting p
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-48($t0)
sw $t1,0($s1)

# getting N
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-36($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t1,$t1,$t2
sw $t1,0($s1)
lw $t9,0($s1)
addi $s1,$s1,4
slt $t1,$zero,$t9
slt $t9,$t9,$zero
or $t9,$t9,$t1
beq $t9,$zero,label12_end

# Condition

# Getting index
# getting p
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-48($t0)
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2 = t2*4
lw $t0,-40($s0) # load pointer value
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
add $t0,$t2,$t0 # get address
addi $t0,$t0,4 # still getting address..
lw $t1,0($t0) # get value at index
sw $t1,0($s1) # replace index on stack with valu


lw $t9,0($s1) #get result of condition
addi $s1,$s1,4 # delete a value
beq $t9,$zero,label23 # if

# getting counter
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-56($t0)
sw $t1,0($s1)

# int 1
li $t1,1
addi $s1,$s1,-4
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
add $t1,$t1,$t2
sw $t1,0($s1)

# Assignment
# getting counter
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-56($t0)
addi $s1,$s1,4

# Condition

# getting counter
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-56($t0)
sw $t1,0($s1)

# int 10001
li $t1,10001
addi $s1,$s1,-4
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t3,$t1,$t2
slt $t2,$t2,$t1
or $t1,$t3,$t2
sub $t1,$t8,$t1
sw $t1,0($s1)

lw $t9,0($s1) #get result of condition
addi $s1,$s1,4 # delete a value
beq $t9,$zero,label17 # if

# getting p
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-48($t0)
sw $t1,0($s1)

# Print
lw $t0,0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
addi $t4,$zero,4
beq $t1,$zero,label15 # 000 -> int
beq $t1,$t3,label15 # 111 -> int
beq $t1,$t4,label_alg15 # 100 -> alg .. printed as int
addi $t3,$zero,3
bne $t1,$t3,label14 # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label13: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label16 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label13 # continue printing characters

label14:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label16

label_alg15:#print alg
addi $v0,$zero,11
addi $a0,$zero,'a'
syscall
addi $a0,$zero,'l'
syscall
addi $a0,$zero,'g'
syscall
addi $a0,$zero,' '
syscall
addi $a0,$zero,'a'
syscall
addi $a0,$zero,'t'
syscall
addi $a0,$zero,' '
syscall
addi $v0,$zero,1
add $a0,$t0,$zero
syscall
j label16


label15:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label16:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0,$zero,10
addi $v0,$zero,11 
syscall


addi $t9,$zero,1
j label12_end



addi $t9,$zero,1
label17: # end if

# int 2
li $t1,2
addi $s1,$s1,-4
sw $t1,0($s1)

# getting p
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-48($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
# # if t1 is a list or t2 is a list, then throw an error
# addi $t4,$zero,3
# srl $t3,$t2,29
# beq $t3,$t4,error
# srl $t3,$t1,29
# beq $t3,$t4,error

# assume t1 is an int
add $t7,$zero,$zero 
addi $t4,$t4,7
srl $t3,$t1,29
beq $t3,$t4,label19
beq $t3,$zero,label19
addi $t7,$zero,1 # we know now that t1 is a float
label19: # t1 is int

# Assume t2 is an int
srl $t3,$t2,29
beq $t3,$t4,label20
beq $t3,$zero,label20
# t2 is a float now
mtc1 $t1,$f1
mtc1 $t2,$f2
bne $t7,$zero,label_float20 # if t1 was a float too, jump to adition
cvt.s.w $f1,$f1 # if not, convert t1 to float
j label_float20 # j to float operation

label20: # t2 is int
bne $t7,$zero,label_float_conv20 # if t1 was a float, jump to conversion

label_int20: # int multiplication
mult $t1,$t2
mflo $t1
mfhi $t2
j label21 # finish

label_float_conv20: # conversion of t2 to float
mtc1 $t1,$f1
mtc1 $t2,$f2
cvt.s.w $f2,$f2

label_float20: # float multiplication
mul.s $f1,$f1,$f2
mfc1 $t1,$f1

label21: # finish
sw $t1,0($s1)

# Assignment
# getting x
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-52($t0)
addi $s1,$s1,4

label22_start: # while 

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-52($t0)
sw $t1,0($s1)

# getting N
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-36($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
slt $t1,$t1,$t2
sw $t1,0($s1)
lw $t9,0($s1)
addi $s1,$s1,4
slt $t1,$zero,$t9
slt $t9,$t9,$zero
or $t9,$t9,$t1
beq $t9,$zero,label22_end

# int 0
li $t1,0
addi $s1,$s1,-4
sw $t1,0($s1)

# Assignment
# Getting index
# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-52($t0)
sw $t1,0($s1)

lw $t2,0($s1) # load index
sll $t2,$t2,2 # t2=t2*4
lw $t0,-40($s0) # load pointer
srl $t1,$t0,30 # a lil bit of type checking
bne $t1,$t8,error # type check over
lw $t1,4($s1) # load value to be assignment
add $t0,$t2,$t0 # get address on memory location
addi $t0,$t0,4 # still getting address..
sw $t1,0($t0) # store value to address
addi $s1,$s1,8 #clear both index and value

# getting x
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-52($t0)
sw $t1,0($s1)

# getting p
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-48($t0)
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
add $t1,$t1,$t2
sw $t1,0($s1)

# Assignment
# getting x
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-52($t0)
addi $s1,$s1,4



j label22_start
label22_end: # end while



addi $t9,$zero,1
label23: # end if

# getting p
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-48($t0)
sw $t1,0($s1)

# int 1
li $t1,1
addi $s1,$s1,-4
sw $t1,0($s1)

lw $t2,0($s1)
addi $s1,$s1,4
lw $t1,0($s1)
add $t1,$t1,$t2
sw $t1,0($s1)

# Assignment
# getting p
add $t0,$s0,$zero
lw $t1,0($s1)
sw $t1,-48($t0)
addi $s1,$s1,4



j label12_start
label12_end: # end while

# else
bne $t9,$zero,label33

# getting counter
add $t0,$s0,$zero
addi $s1,$s1,-4
lw $t1,-56($t0)
sw $t1,0($s1)

# Print
lw $t0,0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
addi $t4,$zero,4
beq $t1,$zero,label26 # 000 -> int
beq $t1,$t3,label26 # 111 -> int
beq $t1,$t4,label_alg26 # 100 -> alg .. printed as int
addi $t3,$zero,3
bne $t1,$t3,label25 # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label24: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label27 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label24 # continue printing characters

label25:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label27

label_alg26:#print alg
addi $v0,$zero,11
addi $a0,$zero,'a'
syscall
addi $a0,$zero,'l'
syscall
addi $a0,$zero,'g'
syscall
addi $a0,$zero,' '
syscall
addi $a0,$zero,'a'
syscall
addi $a0,$zero,'t'
syscall
addi $a0,$zero,' '
syscall
addi $v0,$zero,1
add $a0,$t0,$zero
syscall
j label27


label26:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label27:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0,$zero,10
addi $v0,$zero,11 
syscall


# int 1
li $t1,1
addi $s1,$s1,-4
sw $t1,0($s1)

# <bound method SignedValue.op of SignedValue->- EnclosedValues>
lw $t1,0($s1)
srl $t2,$t1,29
addi $t3,$zero,7
beq $t2,$t3,label_int28
beq $t2,$zero,label_int28
mtc1 $t1,$f1
mtc1 $zero,$f2
sub.s $f1,$f2,$f1
mfc1 $t1,$f1
j label28
label_int28: #int
sub $t1,$zero,$t1
label28: # finish
sw $t1,0($s1)

# Print
lw $t0,0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
addi $t4,$zero,4
beq $t1,$zero,label31 # 000 -> int
beq $t1,$t3,label31 # 111 -> int
beq $t1,$t4,label_alg31 # 100 -> alg .. printed as int
addi $t3,$zero,3
bne $t1,$t3,label30 # 011 is for str

# print a string
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # for printing characters
label29: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label32 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label29 # continue printing characters

label30:#print float
addi $v0,$zero,2
mtc1 $t0,$f12
syscall
j label32

label_alg31:#print alg
addi $v0,$zero,11
addi $a0,$zero,'a'
syscall
addi $a0,$zero,'l'
syscall
addi $a0,$zero,'g'
syscall
addi $a0,$zero,' '
syscall
addi $a0,$zero,'a'
syscall
addi $a0,$zero,'t'
syscall
addi $a0,$zero,' '
syscall
addi $v0,$zero,1
add $a0,$t0,$zero
syscall
j label32


label31:#print int
addi $v0,$zero,1
add $a0,$t0,$zero
syscall

label32:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0,$zero,10
addi $v0,$zero,11 
syscall




addi $t9,$zero,1
label33: # end else



# print newline via syscall 11 to clean up
addi $a0, $0, 10
addi $v0, $0, 11 
syscall
theend:
# Exit via syscall 10
addi $v0,$zero,10
syscall #10
error:#Print ERROR
addi $v0,$zero,11
addi $a0,$zero,69 #E
syscall
addi $a0,$zero,82 #R
syscall
addi $a0,$zero,82 #R
syscall
addi $a0,$zero,79 #O
syscall
addi $a0,$zero,82 #R
syscall
addi $a0,$zero,10 # newline
syscall

# Exit via syscall 10
addi $v0,$zero,10
syscall #10
