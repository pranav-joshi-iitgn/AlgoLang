/**
 * @file EXE.c
 * @brief A MIPS I simulator with support for base integer, FPU (COP1),
 *        and placeholder quantum (COP2) instructions.
 *        Includes memory management with dynamic resizing for Heap/PPT,
 *        syscall handling, debugging mode, and profiling mode.
 * @version 1.1
 * @author Pranav Joshi
 */

// --- Includes ---
#include <complex.h>   // Required for complex number types (complex float) and functions (crealf, cimagf, I)
#include <math.h>      // Required for sqrtf (square root)
#include <stdio.h>  // For standard I/O functions (printf, fopen, etc.)
#include <stdlib.h> // For memory allocation (malloc, calloc, realloc, free), program exit (exit), string conversion (strtoul)
#include <stdint.h> // For standard integer types (uint32_t, int32_t, uint64_t, int8_t, int16_t)
#include <string.h> // For string manipulation functions (memcpy, strcmp, strlen, strcspn)
#include <math.h>   // For floating-point functions (fabsf, truncf, NAN)
#include <time.h>   // For measuring execution time (clock, CLOCKS_PER_SEC) and seeding random numbers

// --- Configuration Constants ---

/** @brief Initial capacity for the Code segment in 32-bit words. */
#define CODE_INIT_CAPACITY_WORDS (64 * 1024) // Equals 256 KB
/** @brief Initial capacity for the Data segment in 32-bit words. */
#define DATA_INIT_CAPACITY_WORDS (64 * 1024) // Equals 256 KB
/** @brief Fixed capacity for the Stack segment in 32-bit words. */
#define STACK_CAPACITY_WORDS (128 * 1024) // Equals 512 KB
/** @brief Initial capacity for the Heap segment in 32-bit words (can be resized). */
#define HEAP_INIT_CAPACITY_WORDS (1024 * 1024) // Equals 4 MB
/** @brief Initial capacity for the Parent Pointer Tree segment in 32-bit words (can be resized). */
#define PPT_INIT_CAPACITY_WORDS (64 * 1024) // Equals 256 KB

// --- VM State (Global Variables) ---

// Registers
/** @brief Array representing the 32 MIPS General Purpose Registers ($0-$31). Index matches register number. */
uint32_t gpr[32];
/** @brief Array representing the 32 MIPS Floating Point Registers ($f0-$f31). Index matches register number. */
float fpr[32];
/** @brief The Program Counter register, holding the memory address of the next instruction to fetch. */
uint32_t pc;
/** @brief The special HI register, used to store the upper 32 bits of multiplication results or division remainders. */
uint32_t hi;
/** @brief The special LO register, used to store the lower 32 bits of multiplication results or division quotients. */
uint32_t lo;

// Memory Segments (Pointers to dynamically allocated memory blocks)
/** @brief Pointer to the beginning of the allocated Code segment memory. */
uint32_t *code_mem = NULL;
/** @brief Pointer to the beginning of the allocated Data segment memory. */
uint32_t *data_mem = NULL;
/** @brief Pointer to the beginning of the allocated Stack segment memory. */
uint32_t *stack_mem = NULL;
/** @brief Pointer to the beginning of the allocated Heap segment memory. */
uint32_t *heap_mem = NULL;
/** @brief Pointer to the beginning of the allocated Parent Pointer Tree segment memory. */
uint32_t *ppt_mem = NULL;

// Memory Segment Capacities (tracking current allocated size in words)
/** @brief Current allocated capacity of the Code segment memory array, in words. */
size_t code_capacity_words = CODE_INIT_CAPACITY_WORDS;
/** @brief Current allocated capacity of the Data segment memory array, in words. */
size_t data_capacity_words = DATA_INIT_CAPACITY_WORDS;
/** @brief Fixed allocated capacity of the Stack segment memory array, in words. */
size_t stack_capacity_words = STACK_CAPACITY_WORDS;
/** @brief Current allocated capacity of the Heap segment memory array, in words. */
size_t heap_capacity_words = HEAP_INIT_CAPACITY_WORDS;
/** @brief Current allocated capacity of the Parent Pointer Tree segment memory array, in words. */
size_t ppt_capacity_words = PPT_INIT_CAPACITY_WORDS;


#define NUM_QUBITS 5                          // Define the number of qubits to simulate.
#define QSTATE_SIZE (1 << NUM_QUBITS)         // Calculate the size of the state vector (2^N). Must be power of 2.
/** @brief Global array representing the quantum state vector. Stores 2^NUM_QUBITS complex amplitudes. */
complex float q_state[QSTATE_SIZE];           // Declare the global quantum state vector array.

// Simulation Control
/** @brief Global flag to control the main simulation loop. Set to 0 to stop execution. */
int run_bit = 1;

// Debugging & Profiling Globals
/** @brief Flag indicating if debug mode is active (set by command-line argument -d). */
int debug_mode = 0;
/** @brief Flag indicating if profiling mode is active (set by command-line argument -p). */
int profile_mode = 0;
/** @brief Counter for the total number of instructions executed during simulation. */
uint64_t instruction_count = 0;
/** @brief Counter for the number of R-type instructions executed. */
uint64_t r_type_count = 0;
/** @brief Counter for the number of I-type instructions executed. */
uint64_t i_type_count = 0;
/** @brief Counter for the number of J-type instructions executed. */
uint64_t j_type_count = 0;
/** @brief Counter for the number of COP1 (FPU) instructions executed. */
uint64_t cop1_count = 0;
/** @brief Counter for the number of COP2 (Quantum) instructions executed. */
uint64_t cop2_count = 0;
/** @brief Counter for the number of SYSCALL instructions executed. */
uint64_t syscall_count = 0;
/** @brief Counter for NOPs and any unrecognized/unsupported instructions. */
uint64_t other_count = 0;

// --- Segment Definitions & Table ---

// Segment number identifiers (used as indices and return codes)
/** @brief Segment number identifier for Code segment. */
#define SEG_CODE 0
/** @brief Segment number identifier for Data segment. */
#define SEG_DATA 1
/** @brief Segment number identifier for Stack segment. */
#define SEG_STACK 2
/** @brief Segment number identifier for Heap segment. */
#define SEG_HEAP 3
/** @brief Segment number identifier for Parent Pointer Tree segment. */
#define SEG_PPT 4
/** @brief Segment number identifier for Invalid Alignment error condition. */
#define SEG_INVALID_ALIGN 5
/** @brief Segment number identifier for Invalid Address Range error condition. */
#define SEG_INVALID_RANGE 6
/** @brief Total number of defined segment identifiers (including error codes). */
#define NUM_SEGMENTS 7

// Base Addresses for each segment in the MIPS 32-bit address space
/** @brief Base address of the Code (.text) segment. */
#define CODE_BASE 0x00400000
/** @brief Base address of the Static Data (.data) segment. */
#define DATA_BASE 0x10010000
/** @brief Base address of the Stack segment (top of the stack, memory addresses decrease from here). */
#define STACK_BASE 0x60000000
/** @brief Lowest valid memory address allocated for the Stack segment. */
#define STACK_LIMIT (STACK_BASE - (STACK_CAPACITY_WORDS * 4))
/** @brief Base address of the Heap segment (lowest address, memory addresses increase from here). */
#define HEAP_BASE 0x60000000
/** @brief Base address of the Parent Pointer Tree segment (lowest address, memory addresses increase from here). */
#define PARENT_TREE_BASE 0x7F400000
/** @brief Highest valid memory address in the user address space. */
#define USER_SPACE_END 0x7FFFFFFF

/** @brief Array storing the base address corresponding to each segment number identifier. */
const uint32_t segment_bases[NUM_SEGMENTS] = {
    CODE_BASE, DATA_BASE, STACK_BASE, HEAP_BASE, PARENT_TREE_BASE, 0, 0 // Bases for Code, Data, Stack, Heap, PPT, Invalid, Invalid
};
/** @brief Array indicating the growth direction for each segment type (0: Static, 1: Upwards, -1: Downwards). */
const int segment_directions[NUM_SEGMENTS] = {
    0, 0, -1, 1, 1, 0, 0 // Code(S), Data(S), Stack(-), Heap(+), PPT(+)
};

/**
 * @brief Returns a descriptive string name for a given segment number identifier.
 * @param seg_num The segment number identifier (e.g., SEG_CODE, SEG_INVALID_ALIGN).
 * @return Pointer to a constant string representing the segment name or error condition.
 */
const char *get_segment_name_from_number(int seg_num)
{
    // Selects and returns the appropriate string based on the segment number
    switch (seg_num)
    {
    case SEG_CODE:
        return "Code";
    case SEG_DATA:
        return "Data";
    case SEG_STACK:
        return "Stack";
    case SEG_HEAP:
        return "Heap";
    case SEG_PPT:
        return "PPT";
    case SEG_INVALID_ALIGN:
        return "Invalid/Unaligned"; // Specific alignment error
    case SEG_INVALID_RANGE:
        return "Invalid/Reserved/Kernel"; // Out of known user ranges
    default:
        return "Unknown Segment"; // Fallback for unexpected numbers
    }
}

// --- Helper Functions (Instruction Field Extraction) ---
// These functions extract specific bit fields from a 32-bit instruction word.

/** @brief Extracts the 6-bit opcode (bits 31-26) from an instruction word. */
uint32_t get_opcode(uint32_t i) { return (i >> 26) & 0x3F; } // Shift right 26, mask lower 6 bits
/** @brief Extracts the 5-bit 'rs' register index (bits 25-21). */
uint32_t get_rs(uint32_t i) { return (i >> 21) & 0x1F; } // Shift right 21, mask lower 5 bits
/** @brief Extracts the 5-bit 'rt' register index (bits 20-16). */
uint32_t get_rt(uint32_t i) { return (i >> 16) & 0x1F; } // Shift right 16, mask lower 5 bits
/** @brief Extracts the 5-bit 'rd' register index (bits 15-11). */
uint32_t get_rd(uint32_t i) { return (i >> 11) & 0x1F; } // Shift right 11, mask lower 5 bits
/** @brief Extracts the 5-bit shift amount 'shamt' (bits 10-6). */
uint32_t get_shamt(uint32_t i) { return (i >> 6) & 0x1F; } // Shift right 6, mask lower 5 bits
/** @brief Extracts the 6-bit function code 'funct' (bits 5-0) for R-type instructions. */
uint32_t get_funct(uint32_t i) { return i & 0x3F; } // Mask lower 6 bits
/** @brief Extracts the 16-bit immediate value (bits 15-0) without sign extension. */
uint32_t get_immediate(uint32_t i) { return i & 0xFFFF; } // Mask lower 16 bits
/** @brief Extracts and sign-extends the 16-bit immediate value (bits 15-0) to 32 bits. */
int32_t get_signed_immediate(uint32_t i)
{
    int16_t imm16 = (int16_t)(i & 0xFFFF);
    return (int32_t)imm16;
} // Cast to signed 16-bit then 32-bit
/** @brief Extracts the 26-bit target address field (bits 25-0) for J-type instructions. */
uint32_t get_target(uint32_t i) { return i & 0x03FFFFFF; } // Mask lower 26 bits
/** @brief Extracts the 5-bit format field 'fmt' (bits 25-21) for COP1 instructions (overlaps 'rs'). */
uint32_t get_fmt(uint32_t i) { return (i >> 21) & 0x1F; } // Same bits as rs

// --- Utility Functions ---
/** @brief Union to easily reinterpret the bits of a float as a uint32_t and vice-versa. */
typedef union
{
    float f;
    uint32_t u;
} float_uint_union;

/**
 * @brief Prints a 32-bit unsigned integer in binary format, grouping bits by 8.
 * @param value The 32-bit unsigned integer to print.
 */
void print_binary(uint32_t value)
{
    // Loop through each bit position from 31 down to 0
    for (int i = 31; i >= 0; i--)
    {
        // Extract the i-th bit and print '1' or '0'
        putchar((value >> i) & 1 ? '1' : '0');
        // Insert a space after every 8 bits for readability, except after the LSB
        if (i > 0 && i % 8 == 0)
        {
            putchar(' ');
        }
    }
}

// --- Memory Segmentation Function ---
/**
 * @brief Determines the memory segment number and byte offset for a given MIPS address.
 *        Also performs a word-alignment check (address must be divisible by 4).
 * @param address The 32-bit memory address to analyze.
 * @param out_segment_number Pointer to an integer where the determined segment number (SEG_...) will be stored.
 * @param out_offset Pointer to a uint32_t where the byte offset from the segment's base address will be stored.
 * @return int 1 if the address is valid (within a known segment and word-aligned), 0 otherwise.
 */
int get_memory_segment_info(uint32_t address, int *out_segment_number, uint32_t *out_offset)
{
    // Central alignment check: Instructions and word accesses must be word-aligned.
    if (address % 4 != 0)
    {
        *out_segment_number = SEG_INVALID_ALIGN; // Set error code for unaligned access
        *out_offset = 0;                         // Default offset for error
        printf("alignment error");
        return 0;                                // Return failure
    }

    // Calculate the current upper limit of the data segment based on its allocated capacity
    uint32_t data_actual_limit = segment_bases[SEG_DATA] + (data_capacity_words * 4);

    // Check address ranges, starting from highest addresses for clarity
    if (address >= segment_bases[SEG_PPT] && address <= USER_SPACE_END)
    {                                                   // Parent Pointer Tree
        *out_segment_number = SEG_PPT;                  // Set segment number
        *out_offset = address - segment_bases[SEG_PPT]; // Calculate byte offset from PPT base
        return 1;                                       // Success
    }
    else if (address >= segment_bases[SEG_HEAP] && address < segment_bases[SEG_PPT])
    {                                                    // Heap
        *out_segment_number = SEG_HEAP;                  // Set segment number
        *out_offset = address - segment_bases[SEG_HEAP]; // Calculate byte offset from Heap base
        return 1;                                        // Success
    }
    else if (address >= STACK_LIMIT && address < segment_bases[SEG_STACK])
    {                                    // Stack
        *out_segment_number = SEG_STACK; // Set segment number
        // Calculate byte offset *downwards* from the byte just below the base address
        *out_offset = segment_bases[SEG_STACK] - 1 - address;
        return 1; // Success
    }
    else if (address >= segment_bases[SEG_DATA] && address < data_actual_limit)
    {                                                    // Data
        *out_segment_number = SEG_DATA;                  // Set segment number
        *out_offset = address - segment_bases[SEG_DATA]; // Calculate byte offset from Data base
        return 1;                                        // Success
    }
    else if (address >= segment_bases[SEG_CODE] && address < segment_bases[SEG_DATA])
    {                                                    // Code
        *out_segment_number = SEG_CODE;                  // Set segment number
        *out_offset = address - segment_bases[SEG_CODE]; // Calculate byte offset from Code base
        return 1;                                        // Success
    }
    else
    {                                            // Address is outside all known/valid user ranges
        *out_segment_number = SEG_INVALID_RANGE; // Set error code for invalid range
        *out_offset = 0;                         // Default offset for error
        return 0;                                // Failure
    }
}

// --- Memory Management ---
/**
 * @brief Dynamically resizes the Heap or PPT segment if the required offset exceeds current capacity.
 *        The capacity is typically doubled until the requirement is met or a limit (e.g., code size for PPT) is reached.
 * @param seg_num The segment number identifier (must be SEG_HEAP or SEG_PPT).
 * @param required_byte_offset The minimum byte offset from the segment's base address that needs to be validly accessible.
 * @return int 1 if the segment is successfully resized (or already large enough), 0 on failure (memory allocation error, limit exceeded).
 */
int resize_segment(int seg_num, uint32_t required_byte_offset)
{
    uint32_t **seg_ptr_ptr = NULL;                                // Address of the global pointer to the segment's memory block
    size_t *capacity_words_ptr = NULL;                            // Address of the global variable storing the segment's capacity in words
    const char *seg_name = get_segment_name_from_number(seg_num); // Get segment name for logging

    // Calculate the word index needed to access the given byte offset.
    // E.g., byte offset 0-3 needs index 0, offset 4-7 needs index 1.
    size_t required_word_index = required_byte_offset / 4;
    // The capacity must be at least index + 1 to include that index.
    size_t required_words = required_word_index + 1;

    // Set up pointers to modify the correct global variables based on segment number
    if (seg_num == SEG_HEAP)
    {
        seg_ptr_ptr = &heap_mem;                   // Get address of heap_mem pointer
        capacity_words_ptr = &heap_capacity_words; // Get address of heap capacity variable
    }
    else if (seg_num == SEG_PPT)
    {
        seg_ptr_ptr = &ppt_mem;                   // Get address of ppt_mem pointer
        capacity_words_ptr = &ppt_capacity_words; // Get address of PPT capacity variable
        // Check PPT constraint: Capacity cannot exceed code segment capacity
        if ((*capacity_words_ptr) >= code_capacity_words)
        {
            // If already at max capacity, check if the required access is within bounds
            if (required_words > *capacity_words_ptr)
            {
                fprintf(stderr, "RUNTIME ERROR: PPT segment (%s) requires index 0x%zX, but limit is 0x%zX (Code size).\n",
                        seg_name, required_word_index, code_capacity_words - 1);
                run_bit = 0;
                return 0; // Cannot fulfill request
            }
            return 1; // At max capacity, but request is within bounds
        }
    }
    else
    {
        // Error: This function should only resize Heap or PPT
        fprintf(stderr, "RUNTIME ERROR: Attempted to resize non-dynamic segment %s.\n", seg_name);
        return 0;
    }

    // If the current capacity is already sufficient, no action needed
    if (required_words <= *capacity_words_ptr)
    {
        return 1;
    }

    // Calculate the new capacity needed. Strategy: Double until requirement is met.
    size_t new_capacity_words = *capacity_words_ptr; // Start with current capacity
    while (new_capacity_words < required_words)
    {
        // If capacity is 0, start with 1024 words; otherwise, double it
        new_capacity_words = (new_capacity_words == 0) ? 1024 : new_capacity_words * 2;
    }

    // Re-apply the PPT size limit after calculating the desired new capacity
    if (seg_num == SEG_PPT)
    {
        if (new_capacity_words > code_capacity_words)
        {
            new_capacity_words = code_capacity_words; // Cap at code capacity
            // Final check: if the required size still exceeds the cap
            if (required_words > new_capacity_words)
            {
                fprintf(stderr, "RUNTIME ERROR: PPT segment (%s) requires index 0x%zX, exceeding capped limit 0x%zX (Code size).\n",
                        seg_name, required_word_index, code_capacity_words - 1);
                run_bit = 0;
                return 0; // Cannot fulfill request
            }
        }
    }

    // Log the resize operation
    fprintf(stdout, "RUNTIME INFO: Resizing %s segment from 0x%zX words to 0x%zX words.\n",
            seg_name, *capacity_words_ptr, new_capacity_words);

    // Attempt to resize the memory block using realloc
    uint32_t *new_ptr = (uint32_t *)realloc(*seg_ptr_ptr, new_capacity_words * sizeof(uint32_t));
    if (new_ptr == NULL)
    {
        // Reallocation failed (e.g., out of system memory)
        perror("RUNTIME ERROR: Failed to reallocate memory");
        run_bit = 0; // Stop simulation
        return 0;    // Failure
    }

    // If the block grew, zero out the newly allocated portion
    if (new_capacity_words > *capacity_words_ptr)
    {
        // Calculate start pointer for the new portion
        uint32_t *new_portion_start = new_ptr + *capacity_words_ptr;
        // Calculate the size of the new portion in bytes
        size_t new_portion_size_bytes = (new_capacity_words - *capacity_words_ptr) * sizeof(uint32_t);
        // Fill the new portion with zeros
        memset(new_portion_start, 0, new_portion_size_bytes);
    }

    // Update the global segment pointer to the potentially new memory location
    *seg_ptr_ptr = new_ptr;
    // Update the global capacity variable
    *capacity_words_ptr = new_capacity_words;
    return 1; // Success
}

/**
 * @brief Reads a 32-bit word from the simulated memory at a given word-aligned address.
 *        Handles segmentation, bounds checking, and dynamic resizing for Heap/PPT.
 * @param address The 32-bit memory address to read from (must be word-aligned, checked by get_memory_segment_info).
 * @return The 32-bit value read from memory, or 0 on error (and sets run_bit to 0).
 */
uint32_t mem_read_32(uint32_t address)
{
    int seg_num;               // Determined segment number
    uint32_t offset;           // Byte offset within the segment
    uint32_t *base_ptr = NULL; // Pointer to the segment's memory array
    size_t capacity_words = 0; // Capacity of the array (in words)

    // Get segment and offset; also performs word-alignment check
    if (!get_memory_segment_info(address, &seg_num, &offset))
    {
        fprintf(stderr, "RUNTIME ERROR: Segmentation Fault or Alignment Error (read) at address 0x%08X (%s)\n",
                address, get_segment_name_from_number(seg_num));
        run_bit = 0;
        return 0; // Stop on error
    }

    // Convert the byte offset within the segment to a word index for the array
    uint32_t word_offset = offset / 4;

    // Determine the base pointer and capacity for the identified segment
    switch (seg_num)
    {
    case SEG_CODE:
        base_ptr = code_mem;
        capacity_words = code_capacity_words;
        break; // Code segment
    case SEG_DATA:
        base_ptr = data_mem;
        capacity_words = data_capacity_words;
        break; // Data segment
    case SEG_STACK:
        base_ptr = stack_mem;
        capacity_words = stack_capacity_words;
        // Calculate array index for downward-growing stack
        word_offset = (stack_capacity_words * 4 - 1 - offset) / 4;
        break;
    case SEG_HEAP: // Check/resize Heap before access
        if (!resize_segment(seg_num, offset))
        {
            run_bit = 0;
            return 0;
        }
        base_ptr = heap_mem;
        capacity_words = heap_capacity_words;
        break;
    case SEG_PPT: // Check/resize PPT before access
        if (!resize_segment(seg_num, offset))
        {
            run_bit = 0;
            return 0;
        }
        base_ptr = ppt_mem;
        capacity_words = ppt_capacity_words;
        break;
    default: // Should not happen if segment info is valid
        fprintf(stderr, "RUNTIME ERROR: Invalid segment number %d during read at 0x%08X\n", seg_num, address);
        run_bit = 0;
        return 0;
    }

    // Check if the calculated word index is within the bounds of the segment's allocated array
    if (word_offset >= capacity_words)
    {
        fprintf(stderr, "RUNTIME ERROR: Memory Read Out of Bounds in %s segment. Address: 0x%08X, Offset: 0x%X (Word Index: 0x%X), Capacity: 0x%zX words\n",
                get_segment_name_from_number(seg_num), address, offset, word_offset, capacity_words);
        run_bit = 0;
        return 0; // Stop on error
    }

    // Read and return the value from the calculated index in the memory array
    return base_ptr[word_offset];
}

/**
 * @brief Writes a 32-bit word to the simulated memory at a given word-aligned address.
 *        Handles segmentation, bounds checking, dynamic resizing, and prevents writes to code segment.
 * @param address The 32-bit memory address to write to (must be word-aligned, checked by get_memory_segment_info).
 * @param value The 32-bit value to write.
 */
void mem_write_32(uint32_t address, uint32_t value)
{
    int seg_num;               // Determined segment number
    uint32_t offset;           // Byte offset within the segment
    uint32_t *base_ptr = NULL; // Pointer to the segment's memory array
    size_t capacity_words = 0; // Capacity of the array (in words)

    // Get segment info; also performs word-alignment check
    if (!get_memory_segment_info(address, &seg_num, &offset))
    {
        fprintf(stderr, "RUNTIME ERROR: Segmentation Fault or Alignment Error (write) at address 0x%08X (%s)\n",
                address, get_segment_name_from_number(seg_num));
        run_bit = 0;
        return; // Stop on error
    }

    // Convert the byte offset within the segment to a word index for the array
    uint32_t word_offset = offset / 4;

    // Determine the base pointer and capacity for the identified segment
    switch (seg_num)
    {
    case SEG_CODE: // Cannot write to code segment at runtime
        fprintf(stderr, "RUNTIME WARNING: Attempted write to Code segment at 0x%08X. Ignored.\n", address);
        return; // Just return, do not write
    case SEG_DATA:
        base_ptr = data_mem;
        capacity_words = data_capacity_words;
        break; // Data segment
    case SEG_STACK:
        base_ptr = stack_mem;
        capacity_words = stack_capacity_words;
        // Calculate array index for downward-growing stack
        word_offset = (stack_capacity_words * 4 - 1 - offset) / 4;
        break;
    case SEG_HEAP: // Check/resize Heap before access
        if (!resize_segment(seg_num, offset))
        {
            run_bit = 0;
            return;
        }
        base_ptr = heap_mem;
        capacity_words = heap_capacity_words;
        break;
    case SEG_PPT: // Check/resize PPT before access
        if (!resize_segment(seg_num, offset))
        {
            run_bit = 0;
            return;
        }
        base_ptr = ppt_mem;
        capacity_words = ppt_capacity_words;
        break;
    default: // Should not happen if segment info is valid
        fprintf(stderr, "RUNTIME ERROR: Invalid segment number %d during write at 0x%08X\n", seg_num, address);
        run_bit = 0;
        return;
    }

    // Check if the calculated word index is within the bounds of the segment's allocated array
    if (word_offset >= capacity_words)
    {
        fprintf(stderr, "RUNTIME ERROR: Memory Write Out of Bounds in %s segment. Address: 0x%08X, Offset: 0x%X (Word Index: 0x%X), Capacity: 0x%zX words\n",
                get_segment_name_from_number(seg_num), address, offset, word_offset, capacity_words);
        run_bit = 0;
        return; // Stop on error
    }

    // Write the value to the calculated index in the memory array
    base_ptr[word_offset] = value;
}

// --- Register Setters ---
/**
 * @brief Sets the value of a General Purpose Register (GPR).
 *        Ignores writes to $zero (GPR[0]) and checks for invalid indices (>= 32).
 * @param index The index (0-31) of the GPR to attempt to set.
 * @param value The 32-bit value to write.
 */
void set_gpr(uint32_t index, uint32_t value)
{
    // Only perform write if index is valid (1 to 31)
    if (index > 0 && index < 32)
    {
        gpr[index] = value; // Update the register
    }
    // Warn if the index is invalid (>= 32) but allow attempt to write to $zero (index 0)
    else if (index >= 32)
    {
        fprintf(stderr, "RUNTIME WARNING: Attempt to write invalid GPR index %u\n", index);
    }
    // Always ensure GPR[0] ($zero) remains 0, regardless of attempted write
    gpr[0] = 0;
}

/**
 * @brief Sets the value of a Floating Point Register (FPR).
 *        Checks for invalid indices (>= 32).
 * @param index The index (0-31) of the FPR to set.
 * @param value The single-precision float value to write.
 */
void set_fpr(uint32_t index, float value)
{
    // Only perform write if index is valid (0 to 31)
    if (index < 32)
    {
        fpr[index] = value; // Update the register
    }
    else
    { // Warn if index is invalid
        fprintf(stderr, "RUNTIME WARNING: Attempt to write invalid FPR index %u\n", index);
    }
}

/**
 * @brief Initializes the quantum state vector to the |0...0> state.
 * Sets the amplitude of the |0> state to 1.0 + 0.0i and all others to 0.0 + 0.0i.
 * Should be called once during VM initialization.
 */
void q_init() {
    srand(time(NULL));
    memset(q_state, 0, sizeof(q_state));      // Fill the entire q_state array with zero bytes.
    q_state[0] = 1.0f + 0.0f * I;             // Set the amplitude of the |0...0> state (index 0) to 1.
}

/**
 * @brief Normalizes the global quantum state vector `q_state`.
 * Ensures the sum of the squared magnitudes of all amplitudes equals 1.
 * This is crucial after measurement or reset operations.
 */
void q_normalize() {
    float total_prob = 0.0f;                      // Initialize the sum of squared magnitudes (total probability).
    for (int i = 0; i < QSTATE_SIZE; ++i) {       // Iterate through all amplitudes in the state vector.
        float real_part = crealf(q_state[i]);     // Get the real part of the current amplitude.
        float imag_part = cimagf(q_state[i]);     // Get the imaginary part of the current amplitude.
        total_prob += real_part * real_part + imag_part * imag_part; // Add the squared magnitude to the total.
    }

    if (total_prob > 1e-9f) {                     // Check if the total probability is significantly greater than zero.
        float norm_factor = sqrtf(total_prob);    // Calculate the normalization factor (square root of total probability).
        for (int i = 0; i < QSTATE_SIZE; ++i) {   // Iterate through all amplitudes again.
            q_state[i] /= norm_factor;            // Divide each amplitude by the normalization factor.
        }
    } else {                                      // Handle the case where the state vector is essentially zero (should not happen in valid simulation).
       // This case might indicate an error or a state that has fully decohered to zero probability.
       // Depending on desired behavior, could log an error or re-initialize.
       // For now, we do nothing, leaving the state as zero.
       fprintf(stderr, "RUNTIME WARNING: Quantum state vector norm is near zero during normalization.\n"); // Log a warning.
       // Optionally, stop simulation: run_bit = 0;
    }
}

/**
 * @brief Applies the Hadamard gate to the specified qubit `k`.
 * Modifies the global `q_state` vector in place.
 * Assumes `k` is a valid qubit index (0 to NUM_QUBITS-1).
 *
 * @param k The index of the target qubit.
 */
void q_hadamard(int k) {
    if (k < 0 || k >= NUM_QUBITS) {               // Check if the qubit index is valid.
        fprintf(stderr, "RUNTIME ERROR: Invalid qubit index %d for Hadamard gate.\n", k); // Report error if invalid.
        run_bit = 0;                              // Stop simulation on error.
        return;                                   // Exit the function.
    }
    const int stride = 1 << k;                    // Calculate the stride for accessing pairs of states (2^k).
    const float inv_sqrt2 = 1.0f / sqrtf(2.0f);   // Pre-calculate 1/sqrt(2) for efficiency.

    for (int i = 0; i < QSTATE_SIZE; i += 2 * stride) { // Iterate through blocks where the target qubit `k` is 0.
        for (int j = 0; j < stride; ++j) {          // Iterate within each block.
            int idx0 = i + j;                       // Calculate the index where qubit `k` is 0.
            int idx1 = idx0 + stride;               // Calculate the index where qubit `k` is 1.

            complex float amp0 = q_state[idx0];     // Get the amplitude for the |...0...> state.
            complex float amp1 = q_state[idx1];     // Get the amplitude for the |...1...> state.

            q_state[idx0] = (amp0 + amp1) * inv_sqrt2; // Update the amplitude for the |...0...> state: (a0 + a1) / sqrt(2).
            q_state[idx1] = (amp0 - amp1) * inv_sqrt2; // Update the amplitude for the |...1...> state: (a0 - a1) / sqrt(2).
        }
    }
}

/**
 * @brief Applies the Pauli-X (NOT) gate to the specified qubit `k`.
 * Swaps the amplitudes of states differing only in qubit `k`.
 * Modifies the global `q_state` vector in place.
 * Assumes `k` is a valid qubit index (0 to NUM_QUBITS-1).
 *
 * @param k The index of the target qubit.
 */
void q_x(int k) {
    if (k < 0 || k >= NUM_QUBITS) {               // Check if the qubit index is valid.
        fprintf(stderr, "RUNTIME ERROR: Invalid qubit index %d for X gate.\n", k); // Report error if invalid.
        run_bit = 0;                              // Stop simulation on error.
        return;                                   // Exit the function.
    }
    const int stride = 1 << k;                    // Calculate the stride for accessing pairs of states (2^k).

    for (int i = 0; i < QSTATE_SIZE; i += 2 * stride) { // Iterate through blocks where the target qubit `k` is 0.
        for (int j = 0; j < stride; ++j) {          // Iterate within each block.
            int idx0 = i + j;                       // Calculate the index where qubit `k` is 0.
            int idx1 = idx0 + stride;               // Calculate the index where qubit `k` is 1.

            complex float temp = q_state[idx0];     // Store the amplitude of the |...0...> state temporarily.
            q_state[idx0] = q_state[idx1];          // Set the |...0...> amplitude to the original |...1...> amplitude.
            q_state[idx1] = temp;                   // Set the |...1...> amplitude to the original |...0...> amplitude.
        }
    }
}

/**
 * @brief Applies the Controlled-NOT (CNOT) gate.
 * Flips the target qubit `t` if the control qubit `c` is 1.
 * Modifies the global `q_state` vector in place.
 * Assumes `c` and `t` are valid and distinct qubit indices.
 *
 * @param c The index of the control qubit.
 * @param t The index of the target qubit.
 */
void q_cnot(int c, int t) {
    if (c < 0 || c >= NUM_QUBITS || t < 0 || t >= NUM_QUBITS) { // Check if qubit indices are valid.
        fprintf(stderr, "RUNTIME ERROR: Invalid qubit indices c=%d, t=%d for CNOT gate.\n", c, t); // Report error.
        run_bit = 0;                              // Stop simulation.
        return;                                   // Exit.
    }
    if (c == t) {                                 // Check if control and target are the same.
        fprintf(stderr, "RUNTIME WARNING: Control and target qubits are the same (%d) for CNOT. No effect.\n", c); // Warn if same.
        return;                                   // CNOT with same control/target has no effect.
    }

    const int control_mask = 1 << c;              // Create a bitmask for the control qubit.
    const int target_mask = 1 << t;               // Create a bitmask for the target qubit.

    for (int i = 0; i < QSTATE_SIZE; ++i) {       // Iterate through all basis states.
        if ((i & control_mask) != 0) {            // Check if the control qubit `c` is 1 in the current basis state `i`.
            int idx0 = i & ~target_mask;          // Calculate the index where target `t` is 0 (but control `c` is 1).
            int idx1 = i | target_mask;           // Calculate the index where target `t` is 1 (and control `c` is 1).

            // Ensure we only perform the swap once per pair by checking if idx0 < idx1
            if (idx0 < idx1 && i == idx1) {       // Only process when i is the state with the target bit set.
               complex float temp = q_state[idx0];  // Store the amplitude where target is 0 temporarily.
               q_state[idx0] = q_state[idx1];       // Set amplitude where target is 0 to original amplitude where target is 1.
               q_state[idx1] = temp;                // Set amplitude where target is 1 to original amplitude where target is 0.
            }
        }
    }
}

/**
 * @brief Measures the specified qubit `k` in the computational basis.
 * Collapses the global `q_state` vector based on the outcome.
 * Normalizes the state vector after collapse.
 * Assumes `k` is a valid qubit index (0 to NUM_QUBITS-1).
 * Requires srand() to be called once during VM initialization.
 *
 * @param k The index of the qubit to measure.
 * @return int The measurement outcome (0 or 1). Returns -1 on error.
 */
int q_measure(int k) {
    if (k < 0 || k >= NUM_QUBITS) {               // Check if the qubit index is valid.
        fprintf(stderr, "RUNTIME ERROR: Invalid qubit index %d for measurement.\n", k); // Report error if invalid.
        run_bit = 0;                              // Stop simulation on error.
        return -1;                                // Return error code.
    }

    float prob0 = 0.0f;                           // Initialize the probability of measuring 0.
    const int qubit_mask = 1 << k;                // Create a bitmask for the qubit being measured.

    for (int i = 0; i < QSTATE_SIZE; i++) {       // Iterate through all basis states.
        float real_part = crealf(q_state[i]); // Get the real part of the amplitude.
        float imag_part = cimagf(q_state[i]); // Get the imaginary part of the amplitude.
        if ((i & qubit_mask) == 0) {              // Check if qubit `k` is 0 in the current basis state `i`.
            prob0 += real_part * real_part + imag_part * imag_part; // Add squared magnitude to probability of 0.
        }
    }
    // Ensure probability is clamped between 0 and 1 due to potential float inaccuracies
    if (prob0 < 0.0f) prob0 = 0.0f;               // Clamp lower bound.
    if (prob0 > 1.0f) prob0 = 1.0f;               // Clamp upper bound.

    float random_val = (float)rand() / (float)RAND_MAX; // Generate a random float between 0.0 and 1.0.
    int outcome = (random_val < prob0) ? 0 : 1;   // Determine the measurement outcome based on probability of 0.

    float norm_factor_sq = (outcome == 0) ? prob0 : (1.0f - prob0); // Get the total probability for the chosen outcome.

    // Check for near-zero probability before normalization
    if (norm_factor_sq < 1e-9f) {                 // Check if the probability of the outcome is very close to zero.
       // This state is theoretically impossible or highly unlikely. Handle as an error or warning.
       fprintf(stderr, "RUNTIME WARNING: Measured outcome %d for qubit %d has near-zero probability. State might be invalid.\n", outcome, k); // Log a warning.
       // Force collapse to the measured state, but amplitudes will be zero.
       for (int i = 0; i < QSTATE_SIZE; ++i) {    // Iterate through all states.
           if (((i >> k) & 1) != outcome) {       // Check if the state matches the outcome for qubit k.
               q_state[i] = 0.0f + 0.0f * I;      // Zero out amplitudes that don't match the outcome.
           }
           // States matching the outcome are left as they are (likely zero already).
       }
       // No normalization needed if probability is zero.
    } else {
        float norm_factor = sqrtf(norm_factor_sq); // Calculate the normalization factor for the collapsed state.
        for (int i = 0; i < QSTATE_SIZE; ++i) {    // Iterate through all states.
            if (((i >> k) & 1) == outcome) {      // Check if the state matches the measurement outcome for qubit k.
                q_state[i] /= norm_factor;        // Normalize the amplitude of matching states.
            } else {
                q_state[i] = 0.0f + 0.0f * I;     // Zero out amplitudes of states that don't match the outcome.
            }
        }
    }

    // q_normalize(); // Optional: Call full normalization for robustness, though the specific collapse logic should suffice.

    return outcome;                               // Return the measurement outcome (0 or 1).
}

/**
 * @brief Resets the specified qubit `k` to the |0> state.
 * Achieved by measuring qubit `k` and applying an X gate if the outcome is 1.
 * Modifies the global `q_state` vector in place.
 * Assumes `k` is a valid qubit index (0 to NUM_QUBITS-1).
 *
 * @param k The index of the qubit to reset.
 */
void q_reset(int k) {
    if (k < 0 || k >= NUM_QUBITS) {               // Check if the qubit index is valid.
        fprintf(stderr, "RUNTIME ERROR: Invalid qubit index %d for reset.\n", k); // Report error if invalid.
        run_bit = 0;                              // Stop simulation on error.
        return;                                   // Exit the function.
    }
    int measurement_outcome = q_measure(k);       // Measure the qubit `k`.
    if (run_bit == 0) {                           // Check if measurement caused an error.
        return;                                   // Exit if measurement failed.
    }
    if (measurement_outcome == 1) {               // Check if the measurement outcome was 1.
        q_x(k);                                   // Apply the Pauli-X gate to flip the qubit back to 0.
    }
    // State is guaranteed to be |0> for qubit k and normalized after measure/X.
}

/**
 * @brief Applies the Controlled-Phase (CP) gate.
 * Applies a phase factor e^(i*angle) to basis states where the control
 * qubit `c` is 1 AND the target qubit `t` is 1.
 * Modifies the global `q_state` vector in place.
 * Assumes `c` and `t` are valid and distinct qubit indices.
 *
 * @param c The index of the control qubit.
 * @param t The index of the target qubit.
 * @param angle The phase angle in radians.
 */
void q_cp(int c, int t, float angle) {
    if (c < 0 || c >= NUM_QUBITS || t < 0 || t >= NUM_QUBITS) {
        fprintf(stderr, "RUNTIME ERROR: Invalid qubit indices c=%d, t=%d for CP gate.\n", c, t);
        run_bit = 0;
        return;
    }
    if (c == t) {
        fprintf(stderr, "RUNTIME WARNING: Control and target qubits are the same (%d) for CP. No effect.\n", c);
        return; // CP with same control/target has no effect on relative phase.
    }

    const int control_mask = 1 << c; // Bitmask for the control qubit.
    const int target_mask = 1 << t;  // Bitmask for the target qubit.
    const int condition_mask = control_mask | target_mask; // Mask for |11> state for these qubits.

    // Calculate the phase factor e^(i*angle)
    complex float phase_factor = cexpf(I * angle); // Requires complex.h

    // Iterate through all basis states
    for (int i = 0; i < QSTATE_SIZE; ++i) {
        // Check if both control and target qubits are 1 in the current state 'i'
        if ((i & condition_mask) == condition_mask) {
            // Apply the phase factor to the amplitude of the |..1..1..> state
            q_state[i] *= phase_factor;
        }
    }
    // No normalization needed as it's a unitary operation.
}


// --- Initialization ---
/**
 * @brief Initializes the virtual machine state.
 *        Allocates memory for all segments using calloc (zero-initialized).
 *        Zeroes all GPRs and FPRs. Sets initial PC and SP values.
 *        Resets profiling counters and the simulation run flag.
 */
void init_vm(int verbose)
{
    // Allocate zeroed memory for each segment
    code_mem = (uint32_t *)calloc(code_capacity_words, sizeof(uint32_t));
    data_mem = (uint32_t *)calloc(data_capacity_words, sizeof(uint32_t));
    stack_mem = (uint32_t *)calloc(stack_capacity_words, sizeof(uint32_t)); // Stack has fixed size
    heap_mem = (uint32_t *)calloc(heap_capacity_words, sizeof(uint32_t));
    ppt_mem = (uint32_t *)calloc(ppt_capacity_words, sizeof(uint32_t));
    
    // Check if any memory allocation failed
    if (!code_mem || !data_mem || !stack_mem || !heap_mem || !ppt_mem)
    {
        perror("FATAL ERROR: Failed to allocate initial memory for VM"); // Report system error
        exit(EXIT_FAILURE);                                              // Terminate simulation
    }

    // Initialize all GPRs, FPRs, and the quantum state placeholder to zero
    for (int i = 0; i < 32; ++i)
    {
        gpr[i] = 0;        // Zero out GPRs ($zero will stay zero)
        fpr[i] = 0.0f;     // Zero out FPRs
    }
    q_init();

    // Set initial Program Counter and standard MIPS register values
    pc = CODE_BASE;       // PC starts at the beginning of the code segment
    gpr[29] = STACK_BASE; // Stack Pointer ($sp) points *at* STACK_BASE (exclusive top)
    gpr[30] = 0;          // Frame Pointer ($fp / $s8) usually set later by code
    gpr[31] = 0;          // Return Address ($ra) initially zero

    // Initialize HI/LO registers used by mult/div
    hi = 0;
    lo = 0;
    // Set the simulation running flag
    run_bit = 1;

    // Reset all profiling counters
    instruction_count = r_type_count = i_type_count = j_type_count = cop1_count = cop2_count = syscall_count = other_count = 0;

    if(verbose){
        // Print confirmation message and memory layout
        printf("VM Initialized. PC=0x%08X, SP=0x%08X\n", pc, gpr[29]);
        printf(" Memory Regions:\n");
        printf("  Code : 0x%08X - 0x%08zX (%zu KB)\n", CODE_BASE, CODE_BASE + code_capacity_words * 4 - 1, code_capacity_words * 4 / 1024);
        printf("  Data : 0x%08X - 0x%08zX (%zu KB)\n", DATA_BASE, DATA_BASE + data_capacity_words * 4 - 1, data_capacity_words * 4 / 1024);
        printf("  Stack: 0x%08X - 0x%08X (%zu KB, Fixed, Grows Down)\n", STACK_LIMIT, STACK_BASE - 1, stack_capacity_words * 4 / 1024);
        printf("  Heap : 0x%08X - ... (%zu KB Initial, Grows Up)\n", HEAP_BASE, heap_capacity_words * 4 / 1024);
        printf("  PPT  : 0x%08X - ... (%zu KB Initial, Grows Up)\n", PARENT_TREE_BASE, ppt_capacity_words * 4 / 1024);
    }
}

/**
 * @brief Loads MIPS machine code instructions from a text file containing hex strings.
 *        Each line should contain exactly 8 hexadecimal characters representing one instruction.
 * @param filename Path to the input hex file.
 * @return int 1 on successful loading, 0 on failure (e.g., file not found, format error, program too large).
 */
int load_program(const char *filename)
{
    FILE *file = fopen(filename, "r"); // Open the hex file for reading
    if (!file)
    {
        perror("Error opening hex file");
        return 0;
    } // Handle file open error

    char line[12];                     // Buffer for one line (8 hex chars + newline + null)
    uint32_t current_addr = CODE_BASE; // Start loading address at code base
    char *endptr;                      // Used by strtoul to detect conversion errors
    int loaded_count = 0;              // Counter for successfully loaded instructions

    // Read the file line by line
    while (fgets(line, sizeof(line), file) != NULL)
    {
        line[strcspn(line, "\r\n")] = 0; // Remove trailing newline/CR characters

        // Validate line format: must be exactly 8 characters long
        if (strlen(line) != 8)
        {
            // Print warning only if line is not empty
            if (strlen(line) > 0)
                fprintf(stderr, "LOADER WARNING: Skipping malformed line (expected 8 hex chars): %s\n", line);
            continue; // Skip this line
        }

        // Convert the hex string on the line to an unsigned long integer
        unsigned long temp_val = strtoul(line, &endptr, 16); // Base 16 conversion

        // Check for conversion errors (non-hex characters) or value out of 32-bit range
        if (*endptr != '\0' || temp_val > 0xFFFFFFFFUL)
        {
            fprintf(stderr, "LOADER WARNING: Skipping invalid or out-of-range hex line: %s\n", line);
            continue; // Skip this line
        }

        // Cast the valid converted value to a 32-bit instruction word
        uint32_t instruction_word = (uint32_t)temp_val;
        // Calculate the word index within the code_mem array
        uint32_t word_offset = (current_addr - CODE_BASE) / 4;

        // Check if the calculated index exceeds the allocated code memory capacity
        if (word_offset >= code_capacity_words)
        {
            fprintf(stderr, "LOADER ERROR: Program exceeds allocated code segment capacity (0x%zX words).\n", code_capacity_words);
            fclose(file); // Close file before returning error
            return 0;     // Indicate loading failure
        }

        // Store the instruction word into the code memory array at the calculated index
        code_mem[word_offset] = instruction_word;
        // Advance the memory address for the next instruction
        current_addr += 4;
        // Increment the counter for loaded instructions
        loaded_count++;
    }

    fclose(file); // Close the input file
    // Print summary of loading process
    printf("Program loaded successfully. %d instructions (%.2f KB)\n",
           loaded_count, (float)(loaded_count * 4) / 1024.0);
    return 1; // Indicate successful loading
}

// --- Syscall Handler ---
/**
 * @brief Handles MIPS syscall operations based on the code provided in register $v0.
 *        Implements common SPIM-like syscalls (print int/float/string/char, read int, exit)
 *        and custom syscalls for printing hex (34) and binary (35).
 *        Ensures output buffers are flushed after printing.
 */
void handle_syscall()
{
    uint32_t code = gpr[2]; // Get syscall code from $v0
    syscall_count++;        // Increment syscall counter for profiling

    switch (code)
    {
    case 1:                            // print_int ($a0)
        printf("%d", (int32_t)gpr[4]); // Print integer in $a0
        fflush(stdout);                // Force output to display
        break;
    case 2:                    // print_float ($f12)
        printf("%f", fpr[12]); // Print float in $f12
        fflush(stdout);        // Force output to display
        break;
    case 4:
    {                           // print_string ($a0)
        uint32_t addr = gpr[4]; // Get starting address from $a0
        char c;                 // Character buffer
        do
        {                                           // Loop to read and print bytes until null terminator
            uint32_t word_addr = addr & ~3u;        // Align address down to word boundary
            uint32_t word = mem_read_32(word_addr); // Read the containing word
            if (!run_bit)
                return; // Check for memory read error
            // Extract the correct byte based on address offset within the word (assuming little-endian)
            c = (char)((word >> ((addr % 4) * 8)) & 0xFF);
            if (c != '\0')
            {               // If not the null terminator
                putchar(c); // Print the character
            }
            addr++; // Move to the next byte address
        } while (c != '\0' && run_bit); // Continue until null or simulation stops
        fflush(stdout); // Force output to display
    }
    break;
    case 5:
    {                   // read_int (result -> $v0)
        int val;        // Variable to store read integer
        fflush(stdout); // Ensure any prompts are shown before waiting
        // Try to read an integer from standard input
        if (scanf("%d", &val) == 1)
        {
            set_gpr(2, (uint32_t)val); // Store successfully read integer in $v0
        }
        else
        { // Handle invalid input
            fprintf(stderr, "RUNTIME WARNING: Invalid integer input.\n");
            // Clear remaining characters from the input buffer until newline or EOF
            int ch;
            while ((ch = getchar()) != '\n' && ch != EOF)
                ;
            set_gpr(2, 0); // Store 0 in $v0 to indicate error/default
        }
    }
    break;
    case 10: // exit
        printf("--- Program exited via syscall 10 ---\n");
        run_bit = 0; // Clear the run flag to stop the simulation loop
        break;
    case 11: // print_char ($a0)
        // Print the character in $a0 as a single character
        putchar((char)(gpr[4] & 0xFF)); // Print the lower byte of $a0 as a character
        fflush(stdout);                 // Force output to display
        break;
    // New Syscalls
    case 34:                      // print_hex ($a0)
        printf("0x%08X", gpr[4]); // Print value in $a0 as 8-digit zero-padded hex
        fflush(stdout);
        break;
    case 35:                  // print_binary ($a0)
        print_binary(gpr[4]); // Call helper to print value in $a0 as binary
        fflush(stdout);
        break;
    default: // Unsupported syscall code
        fprintf(stderr, "\nRUNTIME WARNING: Unsupported syscall code %u\n", code);
        // Optional: Treat as fatal error by setting run_bit = 0;
        break;
    }
}

// --- Execution Functions ---
// Each function simulates the effect of a specific MIPS instruction or group.

// -- R-Type Execution --
/** @brief Executes R-type ALU instructions (add, sub, and, or, nor, slt, sllv, srlv). Updates GPR[rd]. */
void exec_r_type_alu(uint32_t rd, uint32_t rs, uint32_t rt, uint32_t funct)
{
    uint32_t v_rs = gpr[rs], v_rt = gpr[rt], res = 0;
    int64_t t64;
    switch (funct)
    {
    case 0x20:
        res = (uint32_t)((int32_t)v_rs + (int32_t)v_rt);
        break;
    case 0x22:
        res = (uint32_t)((int32_t)v_rs - (int32_t)v_rt);
        break;
    case 0x24:
        res = v_rs & v_rt;
        break;
    case 0x25:
        res = v_rs | v_rt;
        break;
    case 0x27:
        res = ~(v_rs | v_rt);
        break;
    case 0x2A:
        res = ((int32_t)v_rs < (int32_t)v_rt) ? 1 : 0;
        break;
    case 0x04:
        t64 = (uint64_t)v_rt << (v_rs & 0x1F);
        res = (uint32_t)t64;
        break;
    case 0x06:
        res = v_rt >> (v_rs & 0x1F);
        break;
    }
    set_gpr(rd, res);
}
/** @brief Executes R-type shift instructions using immediate shamt (sll, srl). Updates GPR[rd]. */
void exec_r_sh_type(uint32_t rd, uint32_t rt, uint32_t shamt, uint32_t funct)
{
    uint32_t v_rt = gpr[rt], res = 0;
    int64_t t64;
    switch (funct)
    {
    case 0x00:
        t64 = (uint64_t)v_rt << shamt;
        res = (uint32_t)t64;
        break;
    case 0x02:
        res = v_rt >> shamt;
        break;
    }
    set_gpr(rd, res);
}
/** @brief Executes the jr (Jump Register) instruction. Updates the next PC value. Checks alignment. */
void exec_r_jr(uint32_t rs, uint32_t *next_pc)
{
    *next_pc = gpr[rs];
    if ((*next_pc % 4) != 0)
    {
        fprintf(stderr, "RUNTIME ERROR: JR target 0x%08X unaligned.\n", *next_pc);
        run_bit = 0;
    }
}
/** @brief Executes mfhi/mflo instructions, moving value from HI/LO to GPR[rd]. */
void exec_r_mf(uint32_t rd, uint32_t funct) { set_gpr(rd, (funct == 0x10) ? hi : lo); }
/** @brief Executes the mult (signed multiply) instruction. Stores 64-bit result in HI and LO registers. */
void exec_r_m(uint32_t rs, uint32_t rt)
{
    int64_t p = (int64_t)(int32_t)gpr[rs] * (int64_t)(int32_t)gpr[rt];
    hi = (uint32_t)(p >> 32);
    lo = (uint32_t)p;
}
/**
 * @brief Executes the div (signed integer divide) instruction.
 * Performs GPR[rs] / GPR[rt]. Stores quotient in LO, remainder in HI.
 * Handles division by zero.
 * @param rs Index of the source register (dividend), e.g., 8 for $t0.
 * @param rt Index of the source register (divisor), e.g., 9 for $t1.
 */
void exec_r_div(uint32_t rs, uint32_t rt) {
    int32_t dividend = (int32_t)gpr[rs]; // Get signed dividend from GPR[rs]
    int32_t divisor = (int32_t)gpr[rt]; // Get signed divisor from GPR[rt]

    // --- Handle Division by Zero ---
    // Check if the divisor is zero before performing the division [6][7].
    if (divisor == 0) {
        // Print warning using register indices directly, preceded by '$'.
        fprintf(stderr, "RUNTIME WARNING: Division by zero (div $%u, $%u) at PC 0x%08X.\n",
                rs, // Print the numeric index for the rs register
                rt, // Print the numeric index for the rt register
                pc); // Use current PC for context

        // MIPS hardware behavior on integer div-by-zero is undefined [4].
        // For simulation, we'll set LO=0 and HI=dividend as a plausible behavior.
        lo = 0;
        hi = (uint32_t)dividend;
        // Note: We are NOT setting run_bit = 0 here, just warning and setting HI/LO.
        // If a fatal error is desired, uncomment the next line:
        // run_bit = 0;
        return; // Stop execution for this instruction
    }

    // --- Perform Signed Division using C's div() function ---
    // div() handles potential INT_MIN / -1 overflow correctly.
    // Requires <stdlib.h>, which should already be included.
    div_t result = div(dividend, divisor); // [3] is about C++ float, but div() is standard C

    // Store quotient in LO and remainder in HI
    lo = (uint32_t)result.quot; // Store quotient
    hi = (uint32_t)result.rem;  // Store remainder
}


// -- J-Type Execution --
/**
 * @brief Executes j (Jump) and jal (Jump And Link) instructions.
 *        Updates `next_pc` pointer. For jal in single-cycle model, saves PC+4 into $ra.
 * @param target_addr The absolute target memory address to jump to.
 * @param op The opcode (0x02 for j, 0x03 for jal).
 * @param pc_plus_4 The address of the instruction immediately following the current one (PC + 4).
 * @param next_pc Pointer to the variable holding the next PC value, which will be updated to target_addr.
 */
void exec_j_type(uint32_t target_addr, uint32_t op, uint32_t pc_plus_4, uint32_t *next_pc)
{
    // If the instruction is Jump And Link (jal)...
    if (op == 0x03)
    {
        // ...save the return address (PC+4 for single-cycle) into GPR 31 ($ra).
        set_gpr(31, pc_plus_4);
    }
    // Set the next program counter to the calculated jump target address.
    *next_pc = target_addr;
}

// -- I-Type Execution --
/** @brief Executes branch instructions (beq, bne). Updates next PC pointer if the branch condition is met. */
void exec_i_branch(uint32_t rs, uint32_t rt, uint32_t target_addr, uint32_t op, uint32_t *next_pc)
{
    int take = (op == 0x04) ? (gpr[rs] == gpr[rt]) : (gpr[rs] != gpr[rt]);
    if (take)
    {
        *next_pc = target_addr;
    }
} // Update PC if condition met
/** @brief Executes I-type ALU instructions (addi, andi, ori, xori). Updates GPR[rt]. */
void exec_i_alu(uint32_t rt, uint32_t rs, int32_t imm, uint32_t op)
{
    uint32_t v_rs = gpr[rs], res = 0, imm_u = (uint32_t)(imm & 0xFFFF);
    switch (op)
    {
    case 0x08:
        res = (uint32_t)((int32_t)v_rs + imm);
        break;
    case 0x0C:
        res = v_rs & imm_u;
        break;
    case 0x0D:
        res = v_rs | imm_u;
        break;
    case 0x0E:
        res = v_rs ^ imm_u;
        break;
    }
    set_gpr(rt, res);
}
/** @brief Executes memory access instructions (lw, sw, lb, sb). Checks alignment for lw/sw. Reads/writes memory. */
void exec_i_mem(uint32_t rt, int32_t off, uint32_t rs, uint32_t op)
{
    uint32_t addr = gpr[rs] + off, word, byte;
    switch (op)
    {
    case 0x23:
        if (addr % 4 != 0)
        {
            fprintf(stderr, "RUNTIME ERROR: Unaligned lw at 0x%08X\n", addr);
            run_bit = 0;
            return;
        }
        word = mem_read_32(addr);
        if (run_bit)
            set_gpr(rt, word);
        break;
    case 0x2B:
        if (addr % 4 != 0)
        {
            fprintf(stderr, "RUNTIME ERROR: Unaligned sw at 0x%08X\n", addr);
            run_bit = 0;
            return;
        }
        mem_write_32(addr, gpr[rt]);
        break;
    case 0x20:
        word = mem_read_32(addr & ~3u);
        if (!run_bit)
            return;
        byte = (word >> ((addr % 4) * 8)) & 0xFF;
        set_gpr(rt, (uint32_t)(int8_t)byte);
        break;
    case 0x28:
        word = mem_read_32(addr & ~3u);
        if (!run_bit)
            return;
        byte = gpr[rt] & 0xFF;
        word &= ~(0xFF << ((addr % 4) * 8));
        word |= (byte << ((addr % 4) * 8));
        mem_write_32(addr & ~3u, word);
        break;
    }
}
/** @brief Executes the lui (Load Upper Immediate) instruction. Updates GPR[rt]. */
void exec_i_lui(uint32_t rt, uint32_t imm) { set_gpr(rt, imm << 16); } // Shift immediate left 16 bits

// -- COP1 (FPU) Execution --
/** @brief Executes mfc1 (FPR->GPR) and mtc1 (GPR->FPR) instructions. */
void exec_cop1_m(uint32_t rt, uint32_t fs, uint32_t fmt)
{
    float_uint_union c;
    if (fmt == 0x00)
    {
        c.f = fpr[fs];
        set_gpr(rt, c.u);
    }
    else if (fmt == 0x04)
    {
        c.u = gpr[rt];
        set_fpr(fs, c.f);
    }
} // Move between GPR and FPR bit patterns
/** @brief Executes FPU load/store instructions (l.s, s.s). Checks alignment. */
void exec_cop1_ls(uint32_t ft, int32_t off, uint32_t rs, uint32_t op)
{
    uint32_t addr = gpr[rs] + off;
    float_uint_union c;
    if (addr % 4 != 0)
    {
        fprintf(stderr, "RUNTIME ERROR: Unaligned FPU access at 0x%08X\n", addr);
        run_bit = 0;
        return;
    }
    if (op == 0x31)
    {
        c.u = mem_read_32(addr);
        if (run_bit)
            set_fpr(ft, c.f);
    }
    else if (op == 0x39)
    {
        c.f = fpr[ft];
        mem_write_32(addr, c.u);
    }
} // Load/Store word Coprocessor 1
/** @brief Executes FPU R-type arithmetic instructions (add.s, sub.s, mul.s, div.s). Updates FPR[fd]. Handles div by zero. */
void exec_cop1_r(uint32_t fd, uint32_t fs, uint32_t ft, uint32_t funct)
{
    float vfs = fpr[fs], vft = fpr[ft], res = 0.0f;
    switch (funct)
    {
    case 0x00:
        res = vfs + vft;
        break;
    case 0x01:
        res = vfs - vft;
        break;
    case 0x02:
        res = vfs * vft;
        break;
    case 0x03:
        if (fabsf(vft) < 1e-9f)
        {
            fprintf(stderr, "RUNTIME WARNING: div.s by zero\n");
            res = NAN;
        }
        else
        {
            res = vfs / vft;
        }
        break;
    }
    set_fpr(fd, res);
}
/** @brief Executes FPU conversion instructions (cvt.s.w: int bits->float, cvt.w.s: float->int bits). Updates FPR[fd]. */
void exec_cop1_r_cvt(uint32_t fd, uint32_t fs, uint32_t funct)
{
    float_uint_union s, d;
    s.f = fpr[fs];
    if (funct == 0x20)
    {
        d.f = (float)((int32_t)s.u);
        set_fpr(fd, d.f);
    }
    else if (funct == 0x24)
    {
        d.u = (uint32_t)((int32_t)truncf(s.f));
        set_fpr(fd, d.f);
    }
} // Convert Word/Single
/** @brief Executes the FPU move instruction (mov.s). Updates FPR[fd]. */
void exec_cop1_r_mov(uint32_t fd, uint32_t fs) { set_fpr(fd, fpr[fs]); } // Move Single

// -- COP2 (Quantum) Execution (Placeholder) --
/**
 * @brief Placeholder function for executing COP2 (Quantum) instructions.
 *        Prints info, increments profile counter, and performs dummy modification for 'measure'.
 * @param instruction The 32-bit COP2 instruction word.
 */
void exec_cop2_q(uint32_t instruction)
{
    uint32_t funct = get_funct(instruction); // Get specific quantum operation code
    uint32_t rd_idx = get_rd(instruction);   // Get GPR index holding target qubit ID
    uint32_t rs_idx = get_rs(instruction);   // Get GPR index holding control qubit ID (for CNOT)
    
    //const char *mnemonic = "unknown_qop";    // Default mnemonic if funct is unknown
    int qd = gpr[rd_idx];
    int qs = gpr[rs_idx];

    // Determine mnemonic string based on funct code
    switch (funct)
    {
    case 0x00:
        //mnemonic = "h";
        q_hadamard(qd);
        break;
    case 0x01:
        //mnemonic = "x";
        q_x(qd);
        break;
    case 0x02:
        //mnemonic = "cnot";
        q_cnot(qs,qd);
        break;
    case 0x03:
        //mnemonic = "measure";
        uint32_t b = q_measure(qd);
        if(run_bit){ gpr[9] = (gpr[9] & ~1u)|b;} // $t1
        break;
    case 0x04:
        //mnemonic = "reset";
        q_reset(qd);
        break;
    case 0x05: // cp
    { // Use braces for scope
        uint32_t rt_idx = get_rt(instruction);   // Get GPR index holding control qubit ID (for CNOT)
        uint32_t angle_bits = gpr[rt_idx]; // Get angle bits from GPR[rt]
        float_uint_union converter;
        converter.u = angle_bits; // Reinterpret bits as float
        float angle = converter.f;
        q_cp(qs, qd, angle); // Control=qs, Target=qd, Angle=angle
    }
    break;
    }

    cop2_count++; // Increment profiling counter for COP2 instructions
}

// --- Debugging & Profiling Functions ---


/**
 * @brief Prints the current quantum state (basis states, amplitudes, probabilities).
 * Only prints states with probability significantly greater than zero.
 *
 * @param mode Controls output detail:
 *             - 0: Truncated output (2 decimal places, suitable for profiling).
 *             - 1: Full output (6 decimal places, suitable for debugging).
 */
void print_quantum_state_details(int mode) {
    // Removed the print for NUM_QUBITS and QSTATE_SIZE
    int printed_count = 0; // Counter for non-zero states printed
    float total_prob_check = 0.0f; // To verify normalization

    // Iterate through all basis states in the state vector
    for (int i = 0; i < QSTATE_SIZE; ++i) {
        complex float amp = q_state[i]; // Get the complex amplitude
        float real_part = crealf(amp);   // Get the real part
        float imag_part = cimagf(amp);   // Get the imaginary part
        float probability = real_part * real_part + imag_part * imag_part; // Calculate probability

        total_prob_check += probability; // Add to normalization check sum

        // Only print states with significant probability to avoid clutter
        if (probability > 1e-9f) {
            printf(" |");
            // Print index 'i' as a binary string of length NUM_QUBITS
            for (int j = NUM_QUBITS - 1; j >= 0; j--) {
                putchar((i >> j) & 1 ? '1' : '0'); // Print '1' or '0' for each qubit bit
            }
            printf("> : "); // Separator

            // Adjust precision based on mode
            // --- MODIFY THIS IF CONDITION ---
            if (mode == 0) { // Use literal 0 for truncated mode
                // Truncated output: 2 decimal places
                printf("Amp = %+.2f %+.2fi, Prob = %.2f\n", real_part, imag_part, probability);
            } else { // Default to full precision (mode == 1 or other non-zero)
                // Full output: 6 decimal places
                printf("Amp = %+.6f %+.6fi, Prob = %.6f\n", real_part, imag_part, probability);
            }
            // --- END MODIFICATION ---
            printed_count++;
        }
    }

    // If no states had significant probability (state might be zero)
    if (printed_count == 0) {
         printf(" (State vector appears to be zero or below threshold)\n");
    }

    // Print the sum of probabilities as a sanity check (using consistent precision)
    printf(" (Normalization Check: Sum(Prob) = %.8f)\n", total_prob_check);
}

/**
 * @brief Prints the current state of the VM (PC, instruction, GPRs, HI/LO) to standard output.
 *        Called automatically when debug_mode is enabled, before executing each instruction.
 * @param current_instruction_pc The memory address of the instruction about to be executed.
 * @param instruction_word The 32-bit word of the instruction about to be executed.
 */
void print_state(uint32_t current_instruction_pc, uint32_t instruction_word)
{
    // Array of standard MIPS register names for user-friendly output
    const char *reg_names[32] = {
        "zero", "at", "v0", "v1", "a0", "a1", "a2", "a3",
        "t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7",
        "s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7",
        "t8", "t9", "k0", "k1", "gp", "sp", "fp", "ra"};

    // Print header for debug output section
    printf("------------------------------------[DEBUG]------------------------------------\n");
    // Print current Program Counter and the instruction fetched
    printf("PC: 0x%08X   Instruction: 0x%08X\n", current_instruction_pc, instruction_word);
    // Print header for General Purpose Registers
    printf("GPRs:\n");
    // Loop through GPRs, printing 4 per line with index, name, and hex value
    for (int i = 0; i < 32; i += 4)
    {
        printf("  $%d (%s):\t0x%08X", i, reg_names[i], gpr[i]);               // Print GPR i
        printf("  $%d (%s):\t0x%08X", i + 1, reg_names[i + 1], gpr[i + 1]);   // Print GPR i+1
        printf("  $%d (%s):\t0x%08X", i + 2, reg_names[i + 2], gpr[i + 2]);   // Print GPR i+2
        printf("  $%d (%s):\t0x%08X\n", i + 3, reg_names[i + 3], gpr[i + 3]); // Print GPR i+3
    }
    // Print current values of HI and LO registers
    printf("HI: 0x%08X   LO: 0x%08X\n", hi, lo);

    // print quantum state
    print_quantum_state_details(0); // Use literal 1 for full detail

    // Print footer for debug output section
    printf("-------------------------------------------------------------------------------\n");
    // Optional pause for interactive step-by-step debugging
    // printf("Press Enter to continue..."); getchar();
}

/**
 * @brief Prints a summary of execution profiling statistics to standard output.
 *        Includes total instructions, wall time, estimated N64 time (based on simple CPI),
 *        and the mix of different instruction types executed.
 * @param cpu_time_used The total wall-clock time consumed by the simulation loop, in seconds.
 */
void print_profiling_summary(double cpu_time_used)
{
    // Print header for profiling summary
    printf("\n--- Profiling Summary ---\n");
    // Print total number of instructions executed (use cast for %llu format specifier)
    printf("Total Instructions Executed: %llu\n", (unsigned long long)instruction_count);
    // Print the measured wall-clock execution time
    printf("Execution Wall Time: %.6f seconds\n", cpu_time_used);

    // Estimate execution time on a reference MIPS machine (Nintendo 64 R4300i @ 93.75 MHz)
    double average_cpi = 1.0;                // Very simplistic assumption: Average 1 Cycle Per Instruction
    double n64_clock_speed_hz = 93.75 * 1e6; // N64 CPU clock speed in Hz
    // Calculate total estimated cycles based on instruction count and assumed CPI
    double estimated_cycles = (double)instruction_count * average_cpi;
    // Calculate estimated time = total cycles / clock frequency
    double estimated_n64_time = estimated_cycles / n64_clock_speed_hz;
    // Print the estimated time
    printf("Estimated N64 Time (@%.2f MHz, CPI=%.1f): ~%.6f seconds\n",
           n64_clock_speed_hz / 1e6, average_cpi, estimated_n64_time);

    // Print the breakdown (mix) of different instruction types executed
    printf("Instruction Mix:\n");
    // For each type, print count and percentage (handle division by zero if total count is 0)
    printf("  R-Type   : %llu (%.2f%%)\n", (unsigned long long)r_type_count, instruction_count ? (double)r_type_count * 100.0 / instruction_count : 0.0);
    printf("  I-Type   : %llu (%.2f%%)\n", (unsigned long long)i_type_count, instruction_count ? (double)i_type_count * 100.0 / instruction_count : 0.0);
    printf("  J-Type   : %llu (%.2f%%)\n", (unsigned long long)j_type_count, instruction_count ? (double)j_type_count * 100.0 / instruction_count : 0.0);
    printf("  COP1     : %llu (%.2f%%)\n", (unsigned long long)cop1_count, instruction_count ? (double)cop1_count * 100.0 / instruction_count : 0.0);
    printf("  COP2     : %llu (%.2f%%)\n", (unsigned long long)cop2_count, instruction_count ? (double)cop2_count * 100.0 / instruction_count : 0.0);
    printf("  Syscall  : %llu (%.2f%%)\n", (unsigned long long)syscall_count, instruction_count ? (double)syscall_count * 100.0 / instruction_count : 0.0);
    printf("  Other/NOP: %llu (%.2f%%)\n", (unsigned long long)other_count, instruction_count ? (double)other_count * 100.0 / instruction_count : 0.0);
    // Print footer for summary
    printf("-------------------------\n");
}

// --- Main Simulation Loop ---
/**
 * @brief Runs the main fetch-decode-execute cycle of the MIPS simulation.
 *        Fetches instruction at PC, increments profiling counters, calls debug print if enabled,
 *        decodes opcode, dispatches to appropriate execution function, updates PC.
 *        Continues until the global run_bit flag is cleared (by exit syscall or runtime error).
 */
void run_simulation()
{
    // Record simulation start time for profiling duration calculation
    clock_t start_time = clock();
    // Print start message, indicating if Debug or Profile modes are active
    printf("--- Starting Execution %s%s---\n",
           debug_mode ? "[DEBUG MODE] " : "",      // Add indicator if debug mode is on
           profile_mode ? "[PROFILE MODE] " : ""); // Add indicator if profile mode is on

    // Main simulation loop: continues as long as the run_bit is set
    while (run_bit)
    {
        // --- Fetch Stage ---
        // 1. Check PC Alignment: MIPS instructions must be word-aligned.
        if (pc % 4 != 0)
        {
            fprintf(stderr, "RUNTIME ERROR: PC unaligned (0x%08X) before fetch.\n", pc);
            run_bit = 0;
            break; // Stop simulation on alignment error
        }
        // 2. Fetch Instruction: Read 32-bit word from memory at current PC.
        uint32_t instruction = mem_read_32(pc);
        // 3. Check for Memory Error: mem_read_32 sets run_bit to 0 on failure.
        if (!run_bit)
            break; // Stop simulation if fetch failed

        // Store PC value of the *current* instruction for debugging and $ra calculation
        uint32_t current_instruction_pc = pc;
        // Calculate potential next PC values
        uint32_t pc_plus_4 = pc + 4; // For sequential execution, branches, etc.

        // Set the default next PC value (assuming no jump/branch taken)
        uint32_t pc_to_set = pc_plus_4;

        // --- Debug Stage ---
        // If debug mode is active, print the current state *before* executing
        if (debug_mode)
        {
            print_state(current_instruction_pc, instruction);
        }

        // --- Decode Stage ---
        // Extract instruction fields using helper functions
        uint32_t op = get_opcode(instruction);
        uint32_t rs = get_rs(instruction);
        uint32_t rt = get_rt(instruction);
        uint32_t rd = get_rd(instruction);
        uint32_t shamt = get_shamt(instruction);
        uint32_t funct = get_funct(instruction);
        uint32_t imm_u = get_immediate(instruction);       // Unsigned immediate
        int32_t imm_s = get_signed_immediate(instruction); // Signed immediate
        uint32_t target = get_target(instruction);         // Jump target
        uint32_t fmt = get_fmt(instruction);               // COP1 format

        // --- Profile Instruction Type Stage ---
        // Increment appropriate counter based on opcode/funct for profiling summary
        if (op == 0x00)
        { // R-Type (includes syscall, jr, NOP)
            if (funct == 0x0C)
            { /* Syscall counted in handler */
            } // Don't double-count syscalls
            else if (instruction == 0)
            {
                other_count++;
            } // Specifically count NOPs
            else
            {
                r_type_count++;
            } // Count other R-type instructions
        }
        else if (op == 0x02 || op == 0x03)
        { // J-Type (j, jal)
            j_type_count++;
        }
        else if (op == 0x11 || op == 0x31 || op == 0x39)
        { // COP1 (FPU)
            cop1_count++;
        }
        else if (op == 0x12)
        { // COP2 (Quantum)
            /* Counted within exec_cop2_q function */;
        }
        else if ((op >= 0x04 && op <= 0x0F) || (op >= 0x20 && op <= 0x2B))
        { // I-Type (Branches, ALU Imm, Mem, Lui)
            i_type_count++;
        }
        else
        { // Opcode not recognized above
            other_count++;
        }

        // --- Execute Stage ---
        // Dispatch to the appropriate execution function based on the primary opcode
        switch (op)
        {
        // --- R-Type Instructions (opcode = 0x00) ---
        case 0x00:
            switch (funct)
            { // Dispatch based on function code
            case 0x00:
                if (instruction != 0)
                    exec_r_sh_type(rd, rt, shamt, funct);
                break; // sll (Ignore NOP execution)
            case 0x02:
                exec_r_sh_type(rd, rt, shamt, funct);
                break; // srl
            case 0x04:
            case 0x06:
            case 0x20:
            case 0x22:
            case 0x24:
            case 0x25:
            case 0x27:
            case 0x2A:
                exec_r_type_alu(rd, rs, rt, funct);
                break; // add, sub, and, or, nor, slt, sllv, srlv
            case 0x08:
                exec_r_jr(rs, &pc_to_set);
                break; // jr
            case 0x0C:
                handle_syscall();
                break; // syscall
            case 0x10:
            case 0x12:
                exec_r_mf(rd, funct);
                break; // mfhi, mflo
            case 0x18:
                exec_r_m(rs, rt);
                break; // mult
            case 0x1A:
                exec_r_div(rs, rt);
                break;
            default:
                fprintf(stderr, "RUNTIME WARNING: Unknown R-type funct 0x%X at 0x%08X\n", funct, current_instruction_pc);
                break;
            }
            break; // End R-type block

        // --- J-Type Instructions (opcode = 0x02, 0x03) ---
        case 0x02:
        case 0x03: // j, jal
        {
            uint32_t target_addr = (pc_plus_4 & 0xF0000000) | (target << 2); // Calculate absolute target
            exec_j_type(target_addr, op, pc_plus_4, &pc_to_set);
        }
        break; // Execute jump

        // --- I-Type Branch Instructions (opcode = 0x04, 0x05) ---
        case 0x04:
        case 0x05: // beq, bne
        {
            uint32_t target_addr = pc_plus_4 + (imm_s << 2); // Calculate relative target
            exec_i_branch(rs, rt, target_addr, op, &pc_to_set);
        }
        break; // Execute branch

        // --- I-Type ALU Immediate Instructions ---
        case 0x08:
        case 0x0C:
        case 0x0D:
        case 0x0E: // addi, andi, ori, xori
            exec_i_alu(rt, rs, imm_s, op);
            break;

        // --- I-Type Load Upper Immediate ---
        case 0x0F: // lui
            exec_i_lui(rt, imm_u);
            break;

        // --- I-Type Memory Access Instructions ---
        case 0x20:
        case 0x23:
        case 0x28:
        case 0x2B: // lb, lw, sb, sw
            exec_i_mem(rt, imm_s, rs, op);
            break;

        // --- COP1 (FPU) Instructions (opcode = 0x11) ---
        case 0x11:
            switch (fmt)
            { // Dispatch based on fmt field
            case 0x00:
            case 0x04:
                exec_cop1_m(rt, rd, fmt);
                break; // mfc1, mtc1 (fs = rd field)
            case 0x10: // S-format R-type -> Dispatch based on funct
                switch (funct)
                {
                case 0x00:
                case 0x01:
                case 0x02:
                case 0x03:
                    exec_cop1_r(shamt, rd, rt, funct);
                    break; // add/sub/mul/div.s
                case 0x06:
                    exec_cop1_r_mov(shamt, rd);
                    break; // mov.s
                case 0x24:
                    exec_cop1_r_cvt(shamt, rd, funct);
                    break; // cvt.w.s
                default:
                    fprintf(stderr, "RUNTIME WARNING: Unknown COP1 S-fmt funct 0x%X at 0x%08X\n", funct, current_instruction_pc);
                    break;
                }
                break;
            case 0x14: // W-format R-type -> Dispatch based on funct
                switch (funct)
                {
                case 0x20:
                    exec_cop1_r_cvt(shamt, rd, funct);
                    break; // cvt.s.w
                default:
                    fprintf(stderr, "RUNTIME WARNING: Unknown COP1 W-fmt funct 0x%X at 0x%08X\n", funct, current_instruction_pc);
                    break;
                }
                break;
            default:
                fprintf(stderr, "RUNTIME WARNING: Unknown COP1 fmt 0x%X at 0x%08X\n", fmt, current_instruction_pc);
                break;
            }
            break; // End COP1 block

        // --- COP1 Load/Store (opcode = 0x31, 0x39) ---
        case 0x31:
        case 0x39: // l.s, s.s
            exec_cop1_ls(rt, imm_s, rs, op);
            break; // ft = rt field

        // --- COP2 (Quantum) Instructions (opcode = 0x12) ---
        case 0x12:
            exec_cop2_q(instruction);
            break; // Execute placeholder

        // --- Unknown Opcode ---
        default:
            fprintf(stderr, "RUNTIME WARNING: Unknown opcode 0x%X at 0x%08X\n", op, current_instruction_pc);
            break;
        } // End main instruction dispatch switch

        // --- Update PC ---
        pc = pc_to_set; // Set Program Counter for the next fetch cycle

        // --- Enforce $zero ---
        gpr[0] = 0; // Ensure $zero register is always zero

        // Increment total instruction counter
        instruction_count++;

        // Check run_bit again in case execution logic cleared it (e.g., error during memory write)
        if (!run_bit)
            break;

    } // End while(run_bit) loop

    // --- Post-Simulation ---
    clock_t end_time = clock(); // Record simulation end time
    // Calculate total wall-clock time used by the simulation loop
    double cpu_time_used = ((double)(end_time - start_time)) / CLOCKS_PER_SEC;

    printf("--- Execution Ended ---\n"); // Print end message
    // If profiling is enabled, print the summary
    if (profile_mode)
    {
        print_profiling_summary(cpu_time_used);
    }
    else
    { // Otherwise, just print the total instruction count
        // Cast to unsigned long long for %llu format specifier
        printf("Total instructions executed: %llu\n", (unsigned long long)instruction_count);
    }
}

// --- Cleanup ---
/**
 * @brief Frees all dynamically allocated memory segments used by the VM.
 *        Should be called before the program exits.
 */
void cleanup_vm()
{
    // Free each allocated block if the pointer is not NULL
    if (code_mem)
        free(code_mem);
    if (data_mem)
        free(data_mem);
    if (stack_mem)
        free(stack_mem);
    if (heap_mem)
        free(heap_mem);
    if (ppt_mem)
        free(ppt_mem);
    // Set pointers to NULL to prevent accidental use after free
    code_mem = data_mem = stack_mem = heap_mem = ppt_mem = NULL;
    printf("VM Memory Freed.\n"); // Confirmation message
}

// --- Main Function ---
/**
 * @brief Main entry point for the MIPS simulator executable.
 *        Handles command-line argument parsing (-d for debug, -p for profile),
 *        initializes the VM, loads the specified hex program file, runs the simulation,
 *        and performs cleanup.
 * @param argc Number of command-line arguments.
 * @param argv Array of command-line argument strings.
 * @return int 0 on successful completion, 1 on any error (argument parsing, file loading, etc.).
 */
int main(int argc, char *argv[])
{
    const char *hex_filename = NULL; // Initialize filename pointer to NULL

    // Parse command-line arguments (skip program name at argv[0])
    for (int i = 1; i < argc; ++i)
    {
        if (strcmp(argv[i], "-d") == 0 || strcmp(argv[i], "--debug") == 0)
        {                   // Check for debug flag
            debug_mode = 1; // Enable debug mode
        }
        else if (strcmp(argv[i], "-p") == 0 || strcmp(argv[i], "--profile") == 0)
        {                     // Check for profile flag
            profile_mode = 1; // Enable profile mode
        }
        else if (argv[i][0] == '-')
        { // Handle unknown flags
            fprintf(stderr, "Unknown option: %s\n", argv[i]);
            return 1; // Exit with error
        }
        else if (hex_filename == NULL)
        { // Assume first non-flag argument is the input filename
            hex_filename = argv[i];
        }
        else
        { // Handle case where more than one filename is provided
            fprintf(stderr, "Error: Too many filenames provided.\n");
            return 1; // Exit with error
        }
    }

    // Check if a filename was provided
    if (hex_filename == NULL)
    {
        // Print usage instructions if no filename was found
        fprintf(stderr, "Usage: %s [-d] [-p] <input_hex_file>\n", argv[0]);
        fprintf(stderr, "  -d, --debug    Enable debug mode (print state per instruction)\n");
        fprintf(stderr, "  -p, --profile  Enable profiling mode (print summary at end)\n");
        return 1; // Exit with error
    }

    // --- Simulation Setup ---
    init_vm(0); // Initialize VM state (memory, registers)

    // Load program instructions from the specified hex file
    if (!load_program(hex_filename))
    {
        cleanup_vm(); // Cleanup allocated memory if loading fails
        return 1;     // Exit with loading error
    }

    // --- Run Simulation ---
    run_simulation(); // Start the main fetch-decode-execute loop

    // --- Cleanup ---
    cleanup_vm(); // Free allocated VM memory

    return 0; // Indicate successful completion
}
