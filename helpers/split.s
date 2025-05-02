# Assume setup code above this line is unchanged and provides:
# - $s1 pointing to the memory location holding the input string structure pointer (P_str)
# - $s1+4 points to the memory location holding the character code x (as a word)
# - $s5 pointing to the top of the upward-growing heap/stack area
# - $t8=1, $s0/$t9 reserved, no forbidden registers/instructions below

#---------------------
# Start of the Implemented Logic

# --- Stage 0: Load Operands and Prepare ---

# Load string base pointer P_str from $s1 stack top
    lw $t6, 0($s1)     # $t6 = P_str (base address of the string structure on $s5)
# Load character 'x' from $s1 stack
    lw $t7, 4($s1)     # $t7 = the character code x to search for

# Save the $s1 address *before* addresses are pushed (after operands are popped)
    addi $s6, $s1, 8   # $s6 holds the address $s1 *will* have after popping operands.
                       # Marks logical top of $s1 before pushing addresses.

# Adjust $s1 to effectively pop P_str and x
    addi $s1, $s1, 8

# Push Base Address P_str onto $s1 stack first
    addi $s1, $s1, -4  # Make space
    sw $t6, 0($s1)     # Store P_str ($t6)

# Initialize the count of addresses pushed (M) to 1 (for P_str)
    ori $s3, $zero, 1  # $s3 = M = 1

# Load original string Size (4N) from structure base P_str
    lw $t3, 0($t6)     # $t3 = Size in bytes (4N)
# Calculate N (number of chars): N = Size / 4
    srl $s2, $t3, 2    # $s2 = N (Length of string)

# Initialize pointers and counters for processing loop
    addi $t0, $t6, 4   # $t0 = pointer to the first character word in the string structure
    add $t4, $zero, $zero  # $t4 = counter for non-'x' characters since last 'x'
    add $t5, $zero, $zero  # $t5 = iteration counter (0 to N-1)
    add $t1, $zero, $zero  # $t1 = flag: 0 = first 'x' not found yet, 1 = first 'x' found

# --- Stage 1: Process String, Replace 'x', Record Addresses Where 'x' Occurred ---

process_loop:
# Loop Condition: Check if iteration counter $t5 < N ($s2)
    slt $t2, $t5, $s2   # $t2 = 1 if $t5 < N, else 0
    beq $t2, $zero, end_process_loop # Exit loop if $t5 >= N

# Load current character word
    lw $a0, 0($t0)     # $a0 = current character code C

# Compare C with 'x' ($t7)
    bne $a0, $t7, not_x # Branch if C != x

# Path if character IS 'x':
    # Task 1: Record Address of 'x' occurrence onto $s1 stack (grows down)
    addi $s1, $s1, -4
    sw $t0, 0($s1)
    # Task 2: Increment address count M
    addi $s3, $s3, 1   # $s3 = M

    # Task 3: Calculate replacement value R = (Count * 4)
    sll $a1, $t4, 2    # $a1 = R

    # Task 4: Store replacement value R back into string structure at current position
    sw $a1, 0($t0)

    # Task 5: Handle 0th index replacement *only if this is the first 'x'*
    bne $t1, $zero, already_found_first_x # Skip if first 'x' flag ($t1) is already 1
    # This is the first 'x' found:
    sw $a1, 4($t6)     # Replace the 0th character word (at Base P_str + 4) with R
    ori $t1, $zero, 1  # Set flag $t1 to 1 indicating first 'x' is now processed

already_found_first_x:
    # Task 6: Reset non-'x' counter
    add $t4, $zero, $zero
    j next_char        # Skip the non-x path

not_x:
# Path if character is NOT 'x':
    addi $t4, $t4, 1   # Increment non-'x' counter

# Task 7: Advance to next character position (common to both paths)
next_char:
    addi $t0, $t0, 4   # Move to next character word address
    addi $t5, $t5, 1   # Increment iteration counter
    j process_loop

end_process_loop:
# String processing finished. Original string modified.
# $s1 stack contains M addresses: [Addr_x_last, ..., Addr_x1, Ptr_Base]
# $s3 contains M (total number of addresses pushed).
# $s6 points to where $s1 *was* before addresses were pushed.

# --- Stage 2: Create Pointer List Structure on $s5 stack ---

# Base address for the new pointer structure starts at current $s5 top
    add $t6, $s5, $zero  # $t6 = Base address for the new pointer list structure

# Calculate Size for pointer structure (4 * M)
    sll $t2, $s3, 2    # $t2 = Size = 4 * M

# Store Size (4*M) at the beginning of the pointer structure
    sw $t2, 0($t6)

# Initialize destination pointer for pointer structure
    addi $t5, $t6, 4   # $t5 = Address for first pointer entry in new structure

# Initialize source pointer to read addresses from $s1 stack area
    # Addresses were pushed M times from $s6 downwards.
    # The *first* address pushed (Ptr_Base) is at $s6 - 4.
    # The *last* address pushed (Addr_x_last) is at current $s1.
    # We want to copy them in the order they were pushed (Ptr_Base, Addr_x1, ...).
    # So, we read from $s6 - 4 down towards current $s1.
    addi $t0, $s6, -4  # $t0 points to the *first* address pushed (Ptr_Base)

# Initialize loop counter for copy (use M from $s3)
    add $t3, $s3, $zero # Use $t3 as loop counter, initialized to M

copy_pointers_loop:
    beq $t3, $zero, end_copy_pointers_loop # Exit if count M reaches zero

# Load address from the $s1 stack area (reading downwards, order: Base, x1, ...)
    lw $a0, 0($t0)
# Store address into the new pointer structure (writing forwards)
    sw $a0, 0($t5)

# Decrement source pointer (move up memory, towards current $s1)
    addi $t0, $t0, -4
# Increment destination pointer
    addi $t5, $t5, 4
# Decrement copy counter M
    addi $t3, $t3, -1
    j copy_pointers_loop

end_copy_pointers_loop:
# Pointer structure created at $t6. $t5 points just past it.

# Update $s5 register to point past the new pointer structure
    add $s5, $t5, $zero

# Restore $s1 to its state before addresses were pushed
    add $s1, $s6, $zero

# --- Stage 3: Store Base Pointer of New Structure on $s1 stack ---

# Push the base pointer ($t6) of the new pointer list structure onto $s1 stack
    addi $s1, $s1, -4
    sw $t6, 0($s1)

# --- Processing Complete ---

# Add exit syscall for standalone testing if needed
# exit:
#    ori $v0, $zero, 10 # syscall 10
#    syscall
