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