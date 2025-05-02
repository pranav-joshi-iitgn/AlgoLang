/**
 * @file DAS.c
 * @brief MIPS Disassembler. Converts 32-bit hex machine code to assembly.
 *        Includes optional SPIM-runnable output mode (-spim flag) which adds
 *        labels, directives, substitutes $s7 for $at, defines and calls a
 *        routine (__print_registers) to dump GPRs/FPRs as integers before each instruction,
 *        using specified registers only (no stack) for saving state within the routine.
 * @version 5.0
 */

// --- Includes ---
#include <stdio.h>      // For file I/O (fopen, fprintf, etc.) and standard I/O (stderr)
#include <stdlib.h>     // For general utilities (exit, strtoul)
#include <stdint.h>     // For standard integer types (uint32_t, int32_t, int16_t, uint64_t)
#include <string.h>     // For string manipulation (strcmp, strcspn, strlen)
#include <stdbool.h>    // To use bool type for flags

// --- Global Variables ---
/** @brief Global variable holding the current program counter address during disassembly. */
uint32_t current_pc = 0x00400000;
/** @brief Global file pointer for the input hex instruction file. */
FILE *inputFile = NULL;
/** @brief Global file pointer for the output disassembled assembly file. */
FILE *outputFile = NULL;
/** @brief Global flag to enable SPIM-specific output format (set via -spim argument). */
bool spim_mode = false;

// --- Segment Definitions ---
// Identifiers for different memory segments and error conditions
#define SEG_CODE 0
#define SEG_DATA 1
#define SEG_STACK 2
#define SEG_HEAP 3
#define SEG_PPT 4
#define SEG_INVALID_ALIGN 5
#define SEG_INVALID_RANGE 6
#define NUM_SEGMENTS 7 // Total number of defined segment types

// Base Addresses for memory segments based on typical MIPS/SPIM layout
#define CODE_BASE 0x00400000
#define DATA_BASE 0x10010000
#define DATA_END 0x10040000 // Assumed end for simple segment calculations
#define STACK_BASE 0x60000000 // Top of stack (grows down)
#define STACK_LIMIT (STACK_BASE - (128 * 1024 * 4)) // Assuming 512KB stack for get_segment_info
#define HEAP_BASE 0x60000004 // Start of heap (grows up)
#define PARENT_TREE_BASE 0x7F400000
#define USER_SPACE_END 0x7FFFFFFF

// --- Segment Table (Read-only data about segments) ---
/** @brief Array storing the base address corresponding to each segment number identifier. */
const uint32_t segment_bases[NUM_SEGMENTS] = {
    CODE_BASE, DATA_BASE, STACK_BASE, HEAP_BASE, PARENT_TREE_BASE, 0, 0
};
/** @brief Array indicating growth direction (0=Static, 1=Up, -1=Down). Used for comments. */
const int segment_directions[NUM_SEGMENTS] = {
     0,  0, -1,  1,  1,  0,  0
};

/**
 * @brief Returns a descriptive string name for a given segment number identifier.
 *        Used for comments in non-SPIM mode and error messages.
 * @param seg_num The segment number identifier (e.g., SEG_CODE, SEG_INVALID_ALIGN).
 * @return Pointer to a constant string representing the segment name or error condition.
 */
const char* get_segment_name_from_number(int seg_num) {
    switch (seg_num) { // Select string based on segment number
        case SEG_CODE: return "Code";
        case SEG_DATA: return "Data";
        case SEG_STACK: return "Stack";
        case SEG_HEAP: return "Heap";
        case SEG_PPT: return "PPT";
        case SEG_INVALID_ALIGN: return "Invalid/Unaligned";
        case SEG_INVALID_RANGE: return "Invalid/Reserved/Kernel";
        default: return "Unknown Segment";
    }
}

// --- Register Name Arrays (Global, Read-only) ---
/** @brief Array mapping GPR index (0-31) to its standard MIPS name string (e.g., "$zero", "$sp"). */
const char *gpr_names[32] = {
    "$zero", "$at", "$v0", "$v1", "$a0", "$a1", "$a2", "$a3",
    "$t0", "$t1", "$t2", "$t3", "$t4", "$t5", "$t6", "$t7",
    "$s0", "$s1", "$s2", "$s3", "$s4", "$s5", "$s6", "$s7", // $s7 is index 23
    "$t8", "$t9", "$k0", "$k1", "$gp", "$sp", "$fp", "$ra"
};
/** @brief Array mapping FPR index (0-31) to its standard MIPS name string (e.g., "$f0", "$f12"). */
const char *fpr_names[32] = {
    "$f0", "$f1", "$f2", "$f3", "$f4", "$f5", "$f6", "$f7",
    "$f8", "$f9", "$f10", "$f11", "$f12", "$f13", "$f14", "$f15",
    "$f16", "$f17", "$f18", "$f19", "$f20", "$f21", "$f22", "$f23",
    "$f24", "$f25", "$f26", "$f27", "$f28", "$f29", "$f30", "$f31"
};

// --- Helper Function for Register Name Substitution ---
/**
 * @brief Returns the appropriate register name string, substituting "$s7" for "$at" (GPR 1).
 *        This substitution applies only when spim_mode is true.
 * @param index The numerical index (0-31) of the GPR.
 * @return Pointer to the constant string for the register name ("$s7" or standard name).
 */
const char* get_safe_gpr_name(uint32_t index) {
    if (spim_mode && index == 1) { // If SPIM mode is active AND the register index is 1 ($at)
        return "$s7"; // Return "$s7" instead of "$at"
    }
    if (index < 32) { // For all other valid indices (including 0) or if not in SPIM mode
        return gpr_names[index]; // Return the standard name from the array
    }
    return "$INVALID"; // Return placeholder for invalid index (should not normally happen)
}


// --- Helper Functions for Field Extraction ---
/** @brief Extracts the 6-bit opcode (bits 31-26) from an instruction word. */
uint32_t get_opcode(uint32_t i) { return (i >> 26) & 0x3F; }
/** @brief Extracts the 5-bit 'rs' register index (bits 25-21). */
uint32_t get_rs(uint32_t i) { return (i >> 21) & 0x1F; }
/** @brief Extracts the 5-bit 'rt' register index (bits 20-16). */
uint32_t get_rt(uint32_t i) { return (i >> 16) & 0x1F; }
/** @brief Extracts the 5-bit 'rd' register index (bits 15-11). */
uint32_t get_rd(uint32_t i) { return (i >> 11) & 0x1F; }
/** @brief Extracts the 5-bit shift amount 'shamt' (bits 10-6). */
uint32_t get_shamt(uint32_t i) { return (i >> 6) & 0x1F; }
/** @brief Extracts the 6-bit function code 'funct' (bits 5-0) for R-type instructions. */
uint32_t get_funct(uint32_t i) { return i & 0x3F; }
/** @brief Extracts the 16-bit immediate value (bits 15-0) without sign extension. */
uint32_t get_immediate(uint32_t i) { return i & 0xFFFF; }
/** @brief Extracts and sign-extends the 16-bit immediate value (bits 15-0) to 32 bits. */
int32_t get_signed_immediate(uint32_t i) { int16_t imm16 = (int16_t)(i & 0xFFFF); return (int32_t)imm16; }
/** @brief Extracts the 26-bit target address field (bits 25-0) for J-type instructions. */
uint32_t get_target(uint32_t i) { return i & 0x03FFFFFF; }
/** @brief Extracts the 5-bit format field 'fmt' (bits 25-21) for COP1 instructions (overlaps 'rs'). */
uint32_t get_fmt(uint32_t i) { return (i >> 21) & 0x1F; }

// --- Memory Segmentation Function ---
/**
 * @brief Determines the memory segment number and byte offset for a given MIPS address.
 *        Also performs a word-alignment check. Used for comments only in DAS.
 * @param address The 32-bit memory address to analyze.
 * @param out_segment_number Pointer to an integer where the determined segment number (SEG_...) will be stored.
 * @param out_offset Pointer to a uint32_t where the byte offset from the segment's base address will be stored.
 * @return int 1 if the address is valid (within a known segment and word-aligned), 0 otherwise.
 */
int get_memory_segment_info(uint32_t address, int *out_segment_number, uint32_t *out_offset) {
    if (address % 4 != 0) { *out_segment_number = SEG_INVALID_ALIGN; *out_offset = 0; return 0; } // Alignment check
    // Check ranges from highest to lowest addresses.
    if (address >= segment_bases[SEG_PPT] && address <= USER_SPACE_END) { *out_segment_number = SEG_PPT; *out_offset = address - segment_bases[SEG_PPT]; return 1; }
    else if (address >= segment_bases[SEG_HEAP] && address < segment_bases[SEG_PPT]) { *out_segment_number = SEG_HEAP; *out_offset = address - segment_bases[SEG_HEAP]; return 1; }
    else if (address >= STACK_LIMIT && address < segment_bases[SEG_STACK]) { *out_segment_number = SEG_STACK; *out_offset = segment_bases[SEG_STACK] - 1 - address; return 1; }
    else if (address >= segment_bases[SEG_DATA] && address < DATA_END) { *out_segment_number = SEG_DATA; *out_offset = address - segment_bases[SEG_DATA]; return 1; }
    else if (address >= segment_bases[SEG_CODE] && address < segment_bases[SEG_DATA]) { *out_segment_number = SEG_CODE; *out_offset = address - segment_bases[SEG_CODE]; return 1; }
    else { *out_segment_number = SEG_INVALID_RANGE; *out_offset = 0; return 0; } // Invalid range
}

// --- Disassembly Output Functions ---
// These functions format and print specific instruction types to the outputFile.
// Uses get_safe_gpr_name() for GPR output to handle $at substitution.

/** @brief Prints R-type instructions with 3 register operands (rd, rs, rt) like add, sub, etc. Substitutes $s7 for $at in SPIM mode. */
void dis_r_type(uint32_t rd, uint32_t rs, uint32_t rt, const char* mnemonic) { fprintf(outputFile, "%s %s, %s, %s", mnemonic, get_safe_gpr_name(rd), get_safe_gpr_name(rs), get_safe_gpr_name(rt)); }
/** @brief Prints R-type shift instructions with immediate shamt (rd, rt, shamt) like sll, srl. Substitutes $s7 for $at in SPIM mode. */
void dis_r_sh_type(uint32_t rd, uint32_t rt, uint32_t shamt, const char* mnemonic) { fprintf(outputFile, "%s %s, %s, %u", mnemonic, get_safe_gpr_name(rd), get_safe_gpr_name(rt), shamt); }
/** @brief Prints the jr instruction (jr rs). Substitutes $s7 for $at in SPIM mode. */
void dis_r_jr(uint32_t rs) { fprintf(outputFile, "jr %s", get_safe_gpr_name(rs)); }
/** @brief Prints the syscall instruction. */
void dis_syscall() { fprintf(outputFile, "syscall"); }
/** @brief Prints mfhi/mflo instructions (mfhi/mflo rd). Substitutes $s7 for $at in SPIM mode. */
void dis_r_mf(uint32_t rd, const char* mnemonic) { fprintf(outputFile, "%s %s", mnemonic, get_safe_gpr_name(rd)); }
/** @brief Prints the mult instruction (mult rs, rt). Substitutes $s7 for $at in SPIM mode. */
void dis_r_m(uint32_t rs, uint32_t rt) { fprintf(outputFile, "mult %s, %s", get_safe_gpr_name(rs), get_safe_gpr_name(rt)); }

/**
 * @brief Prints a J-type instruction (j, jal). Uses label format for target address in SPIM mode, hex otherwise.
 * @param target_address The calculated absolute 32-bit target address.
 * @param mnemonic The instruction mnemonic ("j" or "jal").
 */
void dis_j_type(uint32_t target_address, const char* mnemonic) {
    if (spim_mode) { fprintf(outputFile, "%s label0x%08X", mnemonic, target_address); } // Print label target in SPIM mode
    else { fprintf(outputFile, "%s 0x%08X", mnemonic, target_address); } // Print hex address otherwise
}

/**
 * @brief Prints an I-type branch instruction (beq, bne). Uses label format in SPIM mode. Substitutes $s7 for $at.
 * @param rs Index of the first source register.
 * @param rt Index of the second source register.
 * @param target_address The calculated absolute 32-bit target address.
 * @param mnemonic The instruction mnemonic ("beq" or "bne").
 */
void dis_i_branch(uint32_t rs, uint32_t rt, uint32_t target_address, const char* mnemonic) {
    if (spim_mode) { fprintf(outputFile, "%s %s, %s, label0x%08X", mnemonic, get_safe_gpr_name(rs), get_safe_gpr_name(rt), target_address); } // SPIM mode uses label
    else { fprintf(outputFile, "%s %s, %s, 0x%08X", mnemonic, get_safe_gpr_name(rs), get_safe_gpr_name(rt), target_address); } // Original mode uses hex
}

/** @brief Prints I-type ALU instructions (addi, andi, ori, xori). Uses hex immediate for logical ops. Substitutes $s7 for $at. */
void dis_i_alu(uint32_t rt, uint32_t rs, int32_t immediate, const char* mnemonic, bool use_hex_imm) {
    if (use_hex_imm) { fprintf(outputFile, "%s %s, %s, 0x%x", mnemonic, get_safe_gpr_name(rt), get_safe_gpr_name(rs), (uint32_t)immediate & 0xFFFF); } // Hex for logical
    else { fprintf(outputFile, "%s %s, %s, %d", mnemonic, get_safe_gpr_name(rt), get_safe_gpr_name(rs), immediate); } // Decimal for arithmetic
}
/** @brief Prints I-type memory instructions (lw, lb, sw, sb) using offset(base) format. Substitutes $s7 for $at. */
void dis_i_mem(uint32_t rt, int32_t offset, uint32_t rs, const char* mnemonic) { fprintf(outputFile, "%s %s, %d(%s)", mnemonic, get_safe_gpr_name(rt), offset, get_safe_gpr_name(rs)); }
/** @brief Prints the lui instruction (lui rt, immediate). Immediate shown in hex. Substitutes $s7 for $at. */
void dis_i_lui(uint32_t rt, uint32_t immediate) { fprintf(outputFile, "lui %s, 0x%x", get_safe_gpr_name(rt), immediate); }

/** @brief Prints COP1 move instructions (mfc1 rt, fs; mtc1 rt, fs). rt=GPR, fs=FPR. Substitutes $s7 for GPR $at. */
void dis_cop1_m(uint32_t rt, uint32_t fs, const char* mnemonic) { fprintf(outputFile, "%s %s, %s", mnemonic, get_safe_gpr_name(rt), fpr_names[fs]); }
/** @brief Prints COP1 load/store instructions (l.s ft, offset(rs); s.s ft, offset(rs)). ft=FPR, rs=GPR. Substitutes $s7 for GPR $at. */
void dis_cop1_ls(uint32_t ft, int32_t offset, uint32_t rs, const char* mnemonic) { fprintf(outputFile, "%s %s, %d(%s)", mnemonic, fpr_names[ft], offset, get_safe_gpr_name(rs)); }
/** @brief Prints COP1 R-type arithmetic instructions (e.g., add.s fd, fs, ft). All registers are FPRs. */
void dis_cop1_r(uint32_t fd, uint32_t fs, uint32_t ft, const char* mnemonic) { fprintf(outputFile, "%s %s, %s, %s", mnemonic, fpr_names[fd], fpr_names[fs], fpr_names[ft]); }
/** @brief Prints COP1 R-type conversion instructions (e.g., cvt.w.s fd, fs). All registers are FPRs. */
void dis_cop1_r_cvt(uint32_t fd, uint32_t fs, const char* mnemonic) { fprintf(outputFile, "%s %s, %s", mnemonic, fpr_names[fd], fpr_names[fs]); }
/** @brief Prints the COP1 move instruction (mov.s fd, fs). All registers are FPRs. */
void dis_cop1_r_mov(uint32_t fd, uint32_t fs) { fprintf(outputFile, "mov.s %s, %s", fpr_names[fd], fpr_names[fs]); }

/** @brief Prints COP2 Quantum instructions with one GPR operand (e.g., h $t0). Substitutes $s7 for $at. */
void dis_cop2_q_rd(uint32_t rd_idx, const char* mnemonic) { fprintf(outputFile, "%s %s", mnemonic, get_safe_gpr_name(rd_idx)); }
/** @brief Prints the COP2 Quantum CNOT instruction (cnot rd, rs). Both operands are GPRs. Substitutes $s7 for $at. */
void dis_cop2_q_rd_rs(uint32_t rd_idx, uint32_t rs_idx) { fprintf(outputFile, "cnot %s, %s", get_safe_gpr_name(rd_idx), get_safe_gpr_name(rs_idx)); }
/**
 * @brief Prints the cp (Controlled Phase) instruction (cp $rt_angle, $rs_control, $rd_target).
 * Uses GPR names, substituting $s7 for $at in SPIM mode.
 */
void dis_cop2_q_cp(uint32_t rs, uint32_t rt, uint32_t rd) {
    fprintf(outputFile, "cp %s, %s, %s",
            get_safe_gpr_name(rt), // Angle GPR ($rt)
            get_safe_gpr_name(rs), // Control Qubit GPR ($rs)
            get_safe_gpr_name(rd)  // Target Qubit GPR ($rd)
           );
}


/** @brief Prints the nop instruction. */
void dis_nop() { fprintf(outputFile, "nop"); }
/** @brief Prints a placeholder message for unknown instructions. */
void dis_unknown(uint32_t instruction, const char* reason) { fprintf(outputFile, "unknown instruction (%s, word=0x%08X)", reason, instruction); }


// --- Register Dump Routine Generation ---
/**
 * @brief Generates MIPS assembly code for a standard routine named "__print_registers".
 *        Prints GPRs 0-31 and FPRs $f1, $f2, $f12 as integers, comma-separated,
 *        followed by TWO newlines for separation.
 *        Uses syscall 1 (print int) and syscall 4 (print string).
 *        Saves original caller's $a0, $v0 into $s3, $s4 before use and restores them before return.
 *        Uses $t0, $t1 as internal temporaries WITHOUT saving/restoring them.
 * @param fp The output file pointer where the MIPS code should be written.
 */
void generate_spim_register_dump_routine(FILE* fp) {
    if (!fp) return; // Safety check for file pointer

    // --- Define Strings in .data section ---
    // This block is printed only ONCE when the routine is defined.
    fprintf(fp, "\n.data\n");                     // Switch to data segment
    fprintf(fp, ".align 2\n");                  // Align data (good practice)
    fprintf(fp, "__d_gpr_prefix:   .asciiz \" $ \"\n"); // String for "$ " before GPR index
    fprintf(fp, "__d_colon_space:  .asciiz \": \"\n");  // String for ": " after index/name
    fprintf(fp, "__d_comma_space:  .asciiz \", \"\n"); // String for ", " separator
    fprintf(fp, "__d_fpr1_prefix:  .asciiz \" $f1: \"\n"); // String for "$f1: "
    fprintf(fp, "__d_fpr2_prefix:  .asciiz \" $f2: \"\n"); // String for "$f2: "
    fprintf(fp, "__d_fpr12_prefix: .asciiz \" $f12: \"\n");// String for "$f12: "
    fprintf(fp, "__d_newline:      .asciiz \"\\n\"\n");   // String for newline character

    // --- Define the Routine in .text section ---
    fprintf(fp, "\n.text\n");                     // Switch back to text segment
    fprintf(fp, "#---------------------------------------------------\n");
    fprintf(fp, "# Routine: __print_registers\n");
    fprintf(fp, "# Prints GPRs 0-31 and FPRs $f1,$f2,$f12 as integers.\n");
    fprintf(fp, "# Preserves caller's $a0, $v0 using $s3, $s4.\n");
    fprintf(fp, "# Clobbers $t0, $t1 (used as temporaries).\n");
    fprintf(fp, "#---------------------------------------------------\n");
    fprintf(fp, "__print_registers:      # Routine label\n");

    // 1. Save Caller's $a0 and $v0 using $s3 and $s4
    fprintf(fp, "    move $s3, $a0         # Save caller's $a0\n");
    fprintf(fp, "    move $s4, $v0         # Save caller's $v0\n");
    // $ra is saved/restored by the CALLER using $s6 now.
    // $t0, $t1 are intentionally clobbered as allowed by requirement.

    // First, print a newline before the GPRs
    fprintf(fp, "\n    li $v0, 4           # syscall print_string\n");
    fprintf(fp, "    la $a0, __d_newline # Load address of newline string\n");
    fprintf(fp, "    syscall             # Print newline before GPRs\n");


    // 2. GPR Printing Loop (Explicitly unrolled for simplicity)
    fprintf(fp, "\n    # --- Print GPRs 2-31 ---\n");
    for (int i = 2; i < 32; ++i) {
        // Print "$ i: " prefix
        fprintf(fp, "    li $v0, 4           # syscall print_string\n");
        fprintf(fp, "    la $a0, __d_gpr_prefix\n");
        fprintf(fp, "    syscall\n");             // Print "$ "
        fprintf(fp, "    li $v0, 1           # syscall print_int\n");
        fprintf(fp, "    li $a0, %d          # Load GPR index i\n", i);
        fprintf(fp, "    syscall\n");             // Print index
        fprintf(fp, "    li $v0, 4           # syscall print_string\n");
        fprintf(fp, "    la $a0, __d_colon_space\n");
        fprintf(fp, "    syscall\n");             // Print ": "

        // Print GPR[i] value (using syscall 1)
        // Note: get_safe_gpr_name handles $at -> $s7 substitution IF the value itself came from $at.
        // Here we print the *current* value, regardless of its original source.
        // We need the name just to generate the correct 'move' instruction source.
        fprintf(fp, "    li $v0, 1           # syscall print_int\n");
        fprintf(fp, "    move $a0, %s     # Move GPR $%d value to $a0\n", gpr_names[i], i); // Use original name for MOVE source
        fprintf(fp, "    syscall\n");             // Print GPR value

        // Print ", " separator (except after last GPR)
        if (i < 31) {
            fprintf(fp, "    li $v0, 4           # syscall print_string\n");
            fprintf(fp, "    la $a0, __d_comma_space\n");
            fprintf(fp, "    syscall\n");         // Print ", "
        }
    } // End GPR loop

    // 3. Print Separator Before FPRs
    fprintf(fp, "\n    li $v0, 4           # syscall print_string\n");
    fprintf(fp, "    la $a0, __d_newline # Load address of newline string\n");
    fprintf(fp, "    syscall             # Print newline before FPRs\n");

    // 4. Print Specific FPRs (as integers using mfc1)
    fprintf(fp, "\n    # --- Print FPRs ($f1, $f2, $f12 as int) ---\n");

    // Print $f1
    fprintf(fp, "    li $v0, 4\n");             // syscall print_string
    fprintf(fp, "    la $a0, __d_fpr1_prefix\n"); // Load address of "$f1: "
    fprintf(fp, "    syscall\n");                 // Print prefix
    fprintf(fp, "    mfc1 $a0, $f1         # Move bits of $f1 into GPR $t1\n");
    fprintf(fp, "    li $v0, 1\n");             // syscall print_int
    //fprintf(fp, "    move $a0, $t1         # Move value from $t1 into $a0\n");
    fprintf(fp, "    syscall\n");                 // Print integer representation
    fprintf(fp, "    li $v0, 4\n");             // syscall print_string
    fprintf(fp, "    la $a0, __d_comma_space\n"); // Load address of ", "
    fprintf(fp, "    syscall\n");                 // Print separator

    // Print $f2
    fprintf(fp, "    li $v0, 4\n");             // syscall print_string
    fprintf(fp, "    la $a0, __d_fpr2_prefix\n"); // Load address of "$f2: "
    fprintf(fp, "    syscall\n");                 // Print prefix
    fprintf(fp, "    mfc1 $a0, $f2         # Move bits of $f2 into GPR $t1\n");
    fprintf(fp, "    li $v0, 1\n");             // syscall print_int
    //fprintf(fp, "    move $a0, $t1         # Move value from $t1 into $a0\n");
    fprintf(fp, "    syscall\n");                 // Print integer representation
    fprintf(fp, "    li $v0, 4\n");             // syscall print_string
    fprintf(fp, "    la $a0, __d_comma_space\n"); // Load address of ", "
    fprintf(fp, "    syscall\n");                 // Print separator

    // Print $f12
    fprintf(fp, "    li $v0, 4\n");             // syscall print_string
    fprintf(fp, "    la $a0, __d_fpr12_prefix\n");// Load address of "$f12: "
    fprintf(fp, "    syscall\n");                 // Print prefix
    fprintf(fp, "    mfc1 $a0, $f12        # Move bits of $f12 into GPR $t1\n");
    fprintf(fp, "    li $v0, 1\n");             // syscall print_int
    //fprintf(fp, "    move $a0, $t1         # Move value from $t1 into $a0\n");
    fprintf(fp, "    syscall\n");                 // Print integer representation

    // 5. Print Final TWO Newlines (Requirement 9: Distinguish output)
    fprintf(fp, "\n    li $v0, 4           # syscall print_string\n");
    fprintf(fp, "    la $a0, __d_newline # Load address of newline string\n");
    fprintf(fp, "    syscall             # Print first newline\n");
    fprintf(fp, "    syscall             # Print second newline for separation\n");

    // 6. Restore Caller's $a0 and $v0
    fprintf(fp, "\n    # --- Restore Registers ---\n");
    fprintf(fp, "    move $a0, $s3         # Restore caller's $a0 from $s3\n");
    fprintf(fp, "    move $v0, $s4         # Restore caller's $v0 from $s4\n");
    // $ra is restored by caller from $s6
    // $t0, $t1 were intentionally clobbered

    // 7. Return to caller
    fprintf(fp, "    jr $ra                # Return\n");
    fprintf(fp, "#---------------------------------------------------\n\n"); // End marker
}


// --- Main Disassembly Dispatcher Function ---
/**
 * @brief Disassembles a single 32-bit MIPS instruction word.
 *        Prints the label (SPIM mode) or address prefix (normal mode).
 *        If in SPIM mode, prints code to save $ra to $s6, calls the register dump routine,
 *        then restores $ra from $s6.
 *        Prints the disassembled MIPS instruction, substituting $s7 for $at in SPIM mode.
 *        Appends comments about jump/branch targets (normal mode only).
 * @param instruction The 32-bit MIPS instruction word to disassemble.
 */
void disassemble_instruction(uint32_t instruction) {
    // Extract primary opcode to determine instruction type/format.
    uint32_t opcode = get_opcode(instruction);
    // Declare variables for various instruction fields.
    uint32_t rs, rt, rd, fs, ft, fd, shamt, target_field, funct, fmt;
    int32_t immediate_s; // Signed immediate value.
    uint32_t target_address = 0; // Calculated target address for jumps/branches.
    bool is_branch_or_jump = false; // Flag used for appending comments in non-SPIM mode.

    // Calculate PC+4, used for PC-relative branch calculations.
    uint32_t pc_plus_4 = current_pc + 4;

    // --- SPIM Mode Output: Label and Register Dump Call ---
    if (spim_mode) {
        // Print the label for the current instruction address on its own line.
        fprintf(outputFile, "label0x%08X:\n", current_pc);

        // --- Insert Call to Register Dump Routine, saving/restoring $ra around it ---
        fprintf(outputFile, "    move $s6, $ra         # Save original $ra before dump call\n");
        fprintf(outputFile, "    jal __print_registers # Call routine to dump GPRs/FPRs\n");
        fprintf(outputFile, "    move $ra, $s6         # Restore original $ra after dump call\n\n"); // Add newline for clarity

        // Add indentation for the actual disassembled instruction that follows the dump call.
        fprintf(outputFile, "    "); // e.g., 4 spaces indentation.

    } else {
        // --- Original Mode: Print Address Prefix ---
        // Print the memory address prefix like "0x00400000: ".
        fprintf(outputFile, "0x%08X: ", current_pc);
    }

    // --- Decode and Print Actual Disassembled Instruction ---
    // Main switch statement to decode based on primary opcode.
    // Uses get_safe_gpr_name() for all GPR operands.
    switch (opcode) {
        case 0x00: // R-type instructions -> dispatch based on funct field.
            rs = get_rs(instruction); rt = get_rt(instruction); rd = get_rd(instruction);
            shamt = get_shamt(instruction); funct = get_funct(instruction);
            switch (funct) {
                case 0x00: if (instruction == 0) dis_nop(); else dis_r_sh_type(rd, rt, shamt, "sll"); break;
                case 0x02: dis_r_sh_type(rd, rt, shamt, "srl"); break;
                case 0x04: dis_r_type(rd, rt, rs, "sllv"); break;
                case 0x06: dis_r_type(rd, rt, rs, "srlv"); break;
                case 0x08: dis_r_jr(rs); is_branch_or_jump = true; target_address = 0; break;
                case 0x0C: dis_syscall(); break;
                case 0x10: dis_r_mf(rd, "mfhi"); break;
                case 0x12: dis_r_mf(rd, "mflo"); break;
                case 0x18: dis_r_m(rs, rt); break;
                case 0x20: dis_r_type(rd, rs, rt, "add"); break;
                case 0x22: dis_r_type(rd, rs, rt, "sub"); break;
                case 0x24: dis_r_type(rd, rs, rt, "and"); break;
                case 0x25: dis_r_type(rd, rs, rt, "or"); break;
                case 0x27: dis_r_type(rd, rs, rt, "nor"); break;
                case 0x2A: dis_r_type(rd, rs, rt, "slt"); break;
                default: dis_unknown(instruction, "R-type funct"); break;
            }
            break;

        case 0x02: // j (Jump).
            target_field = get_target(instruction);
            target_address = (pc_plus_4 & 0xF0000000) | (target_field << 2);
            dis_j_type(target_address, "j");
            is_branch_or_jump = true;
            break;
        case 0x03: // jal (Jump And Link).
            target_field = get_target(instruction);
            target_address = (pc_plus_4 & 0xF0000000) | (target_field << 2);
            dis_j_type(target_address, "jal");
            is_branch_or_jump = true;
            break;

        // --- I-Type Instructions ---
        case 0x04: // beq (Branch on Equal).
            rs = get_rs(instruction); rt = get_rt(instruction); immediate_s = get_signed_immediate(instruction);
            target_address = pc_plus_4 + (immediate_s << 2);
            dis_i_branch(rs, rt, target_address, "beq");
            is_branch_or_jump = true;
            break;
        case 0x05: // bne (Branch on Not Equal).
            rs = get_rs(instruction); rt = get_rt(instruction); immediate_s = get_signed_immediate(instruction);
            target_address = pc_plus_4 + (immediate_s << 2);
            dis_i_branch(rs, rt, target_address, "bne");
            is_branch_or_jump = true;
            break;
        case 0x08: dis_i_alu(get_rt(instruction), get_rs(instruction), get_signed_immediate(instruction), "addi", false); break;
        case 0x0C: dis_i_alu(get_rt(instruction), get_rs(instruction), get_immediate(instruction), "andi", true); break;
        case 0x0D: dis_i_alu(get_rt(instruction), get_rs(instruction), get_immediate(instruction), "ori", true); break;
        case 0x0E: dis_i_alu(get_rt(instruction), get_rs(instruction), get_immediate(instruction), "xori", true); break;
        case 0x0F: dis_i_lui(get_rt(instruction), get_immediate(instruction)); break;
        case 0x20: dis_i_mem(get_rt(instruction), get_signed_immediate(instruction), get_rs(instruction), "lb"); break;
        case 0x23: dis_i_mem(get_rt(instruction), get_signed_immediate(instruction), get_rs(instruction), "lw"); break;
        case 0x28: dis_i_mem(get_rt(instruction), get_signed_immediate(instruction), get_rs(instruction), "sb"); break;
        case 0x2B: dis_i_mem(get_rt(instruction), get_signed_immediate(instruction), get_rs(instruction), "sw"); break;

        // --- COP1 (FPU) Instructions ---
        case 0x11: // COP1 primary opcode.
            fmt = get_fmt(instruction);
            rt = get_rt(instruction); fs = get_rd(instruction); ft = get_rt(instruction);
            fd = get_shamt(instruction); funct = get_funct(instruction);
            switch (fmt) {
                case 0x00: dis_cop1_m(rt, fs, "mfc1"); break;
                case 0x04: dis_cop1_m(rt, fs, "mtc1"); break;
                case 0x10: // S-format R-type.
                    switch (funct) {
                        case 0x00: dis_cop1_r(fd, fs, ft, "add.s"); break;
                        case 0x01: dis_cop1_r(fd, fs, ft, "sub.s"); break;
                        case 0x02: dis_cop1_r(fd, fs, ft, "mul.s"); break;
                        case 0x03: dis_cop1_r(fd, fs, ft, "div.s"); break;
                        case 0x06: dis_cop1_r_mov(fd, fs); break;
                        case 0x24: dis_cop1_r_cvt(fd, fs, "cvt.w.s"); break;
                        default: dis_unknown(instruction, "COP1 R S-fmt funct"); break;
                    } break;
                case 0x14: // W-format R-type.
                     switch (funct) {
                        case 0x20: dis_cop1_r_cvt(fd, fs, "cvt.s.w"); break;
                        default: dis_unknown(instruction, "COP1 R W-fmt funct"); break;
                     } break;
                default: dis_unknown(instruction, "COP1 fmt"); break;
            } break;

        // --- COP1 Load/Store Instructions ---
        case 0x31: dis_cop1_ls(get_rt(instruction), get_signed_immediate(instruction), get_rs(instruction), "l.s"); break;
        case 0x39: dis_cop1_ls(get_rt(instruction), get_signed_immediate(instruction), get_rs(instruction), "s.s"); break;

        // --- COP2 (Quantum) Instructions (Placeholders) ---
        case 0x12: // COP2 primary opcode.
            funct = get_funct(instruction);
            rd = get_rd(instruction);
            rs = get_rs(instruction);
            rt = get_rt(instruction);
            switch (funct) {
                case 0x00: dis_cop2_q_rd(rd, "h"); break;
                case 0x01: dis_cop2_q_rd(rd, "x"); break;
                case 0x02: dis_cop2_q_rd_rs(rd, rs); break;
                case 0x03: dis_cop2_q_rd(rd, "measure"); break;
                case 0x04: dis_cop2_q_rd(rd, "reset"); break;
                case 0x05: dis_cop2_q_cp(rs, rt, rd); break; // cp $rt, $rs, $rd
                default: dis_unknown(instruction, "COP2 funct"); break;
            } break;

        // --- Unknown Opcode ---
        default: // Handle primary opcodes not recognized above.
            dis_unknown(instruction, "opcode");
            break;
    } // End main opcode switch.

    // --- Append Segment Comment (Original Mode Only) ---
    if (!spim_mode && is_branch_or_jump && target_address != 0) {
        int segment_number = -1; uint32_t offset = 0;
        int seg_result = get_memory_segment_info(target_address, &segment_number, &offset);
        fprintf(outputFile, " # -> %s", get_segment_name_from_number(segment_number));
        if (seg_result == 1 && segment_number != SEG_INVALID_ALIGN && segment_number != SEG_INVALID_RANGE) {
             fprintf(outputFile, "+0x%X", offset);
        }
    }

    // Final newline after each disassembled instruction line (for both modes).
    fprintf(outputFile, "\n");

    // If in SPIM mode, add an extra newline for visual separation before the next label.
    if (spim_mode) {
        fprintf(outputFile, "\n");
    }
}


// --- Main Function ---
/**
 * @brief Main entry point for the MIPS Disassembler executable.
 *        Parses arguments (-spim flag, input/output files).
 *        Opens files, prints SPIM headers and dump routine if needed.
 *        Reads hex instructions, calls disassembler for each.
 *        Performs cleanup.
 * @param argc Number of command-line arguments provided.
 * @param argv Array of command-line argument strings.
 * @return int 0 on successful completion, 1 on any error (argument parsing, file I/O).
 */
int main(int argc, char *argv[]) {
    // --- Argument Parsing ---
    char *input_filename = NULL;  // Input filename pointer.
    char *output_filename = NULL; // Output filename pointer.

    // Parse command-line arguments.
    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "-spim") == 0) { // Check for "-spim" flag.
            spim_mode = true; // Enable SPIM mode.
        } else if (input_filename == NULL) { // First non-flag is input file.
            input_filename = argv[i];
        } else if (output_filename == NULL) { // Second non-flag is output file.
            output_filename = argv[i];
        } else { // Handle too many arguments or unknown options.
            fprintf(stderr, "Error: Too many file arguments or unknown option: %s\n", argv[i]);
            fprintf(stderr, "Usage: %s [-spim] <input_hex_file> <output_asm_file>\n", argv[0]);
            return 1; // Exit with error.
        }
    }

    // Validate filenames.
    if (input_filename == NULL || output_filename == NULL) {
        fprintf(stderr, "Error: Input and output filenames are required.\n");
        fprintf(stderr, "Usage: %s [-spim] <input_hex_file> <output_asm_file>\n", argv[0]);
        return 1; // Exit with error.
    }

    // --- File Handling ---
    // Open input hex file.
    inputFile = fopen(input_filename, "r");
    if (!inputFile) { // Check for open error.
        perror("Error opening input file");
        return 1; // Exit.
    }

    // Open output assembly file.
    outputFile = fopen(output_filename, "w");
    if (!outputFile) { // Check for open error.
        perror("Error opening output file");
        fclose(inputFile); // Close input file before exiting.
        return 1; // Exit.
    }

    // --- Initial Setup ---
    current_pc = 0x00400000; // Reset PC to default code start address.

    // If SPIM mode enabled, print data section, text section, global directive, dump routine, and main label.
    if (spim_mode) {
        // Print directives and define the __print_registers routine FIRST
        generate_spim_register_dump_routine(outputFile); // Includes .data, .text, routine code

        // Ensure we are back in .text section and print .globl main / main: AFTER the routine
        fprintf(outputFile, "\n.text\n");           // Ensure we are in text segment
        fprintf(outputFile, ".globl main\n\n");     // Declare main as global entry point
        fprintf(outputFile, "main:\n");           // Add the main label for SPIM's starting point
    }

    // --- Disassembly Loop ---
    char line[12];             // Line buffer.
    uint32_t instruction_word; // Instruction storage.
    char *endptr;              // For strtoul error check.

    // Read hex file line by line.
    while (fgets(line, sizeof(line), inputFile) != NULL) {
        line[strcspn(line, "\r\n")] = 0; // Remove newline.

        // Validate line format.
        if (strlen(line) != 8) {
            if (strlen(line) > 0) fprintf(stderr, "Warning: Skipping malformed line: %s\n", line);
            continue; // Skip.
        }

        // Convert hex to instruction word.
        unsigned long temp_val = strtoul(line, &endptr, 16);
        if (*endptr != '\0' || temp_val > 0xFFFFFFFFUL) {
            fprintf(stderr, "Warning: Skipping invalid hex line: %s\n", line);
            continue; // Skip.
        }
        instruction_word = (uint32_t)temp_val;

        // Call main disassembly function for the instruction.
        disassemble_instruction(instruction_word);

        // Increment PC for the next instruction.
        current_pc += 4;
    }

    // Check for file read errors.
    if (ferror(inputFile)) {
        perror("Error reading input file");
    }

    // --- Cleanup ---
    fclose(inputFile);  // Close input file.
    fclose(outputFile); // Close output file.
    printf("Disassembly complete. Output written to %s\n", output_filename); // Confirmation.
    return 0; // Success.
}
