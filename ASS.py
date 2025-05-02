#!/usr/bin/env python3

import sys
import re
import os
import traceback
import struct # For float conversion

# --- Configuration ---
CODE_BASE_ADDRESS = 0x00400000
DATA_BASE_ADDRESS = 0x10010000 # Standard start for data segment

# --- ANSI Color Codes ---
COLOR = {
    "RESET": "\033[0m",
    "OPCODE": "\033[91m",
    "RS": "\033[92m",
    "RT": "\033[94m",
    "RD": "\033[93m",
    "SHAMT": "\033[95m",
    "FUNCT": "\033[96m",
    "IMM": "\033[97m",
    "TARGET": "\033[97m",
    "COP": "\033[91m",
    "FMT": "\033[92m",
    "FT": "\033[94m",
    "FS": "\033[93m",
    "FD": "\033[96m",
    "QOP": "\033[96m",
    "QRD": "\033[93m",
    "QRS": "\033[92m",
}

# --- Register Mapping ---
REG_MAP = {f"${i}": i for i in range(32)}
REG_MAP.update({
    "$zero": 0, "$at": 1, "$v0": 2, "$v1": 3, "$a0": 4, "$a1": 5, "$a2": 6, "$a3": 7,
    "$t0": 8, "$t1": 9, "$t2": 10, "$t3": 11, "$t4": 12, "$t5": 13, "$t6": 14, "$t7": 15,
    "$s0": 16, "$s1": 17, "$s2": 18, "$s3": 19, "$s4": 20, "$s5": 21, "$s6": 22, "$s7": 23,
    "$t8": 24, "$t9": 25, "$k0": 26, "$k1": 27, "$gp": 28, "$sp": 29, "$fp": 30, "$s8": 30,
    "$ra": 31, "$f0": 0, "$f1": 1, "$f2": 2, "$f3": 3, "$f4": 4, "$f5": 5, "$f6": 6, "$f7": 7,
    "$f8": 8, "$f9": 9, "$f10": 10, "$f11": 11, "$f12": 12, "$f13": 13, "$f14": 14, "$f15": 15,
    "$f16": 16, "$f17": 17, "$f18": 18, "$f19": 19, "$f20": 20, "$f21": 21, "$f22": 22, "$f23": 23,
    "$f24": 24, "$f25": 25, "$f26": 26, "$f27": 27, "$f28": 28, "$f29": 29, "$f30": 30, "$f31": 31,
})

# --- Instruction Encoding Information ---
INSTR_MAP = {
    'add': ('R', 0x00, 0x20, {}),'sub': ('R', 0x00, 0x22, {}),'and': ('R', 0x00, 0x24, {}),
    'or': ('R', 0x00, 0x25, {}),'nor': ('R', 0x00, 0x27, {}),'slt': ('R', 0x00, 0x2A, {}),
    'sll': ('R_sh', 0x00, 0x00, {}),'srl': ('R_sh', 0x00, 0x02, {}),
    'sllv': ('R', 0x00, 0x04, {}),'srlv': ('R', 0x00, 0x06, {}),
    'jr': ('R_jr', 0x00, 0x08, {}),'mult': ('R_m', 0x00, 0x18, {}),'div': ('R_m', 0x00, 0x1A, {}),
    'mfhi': ('R_mf', 0x00, 0x10, {}),'mflo': ('R_mf', 0x00, 0x12, {}),
    'syscall': ('R_syscall', 0x00, 0x0C, {}),
    'addi': ('I', 0x08, None, {'signed_imm': True}),'andi': ('I', 0x0C, None, {'signed_imm': False}),
    'ori': ('I', 0x0D, None, {'signed_imm': False}),'xori': ('I', 0x0E, None, {'signed_imm': False}),
    'lw': ('I_mem', 0x23, None, {'signed_imm': True}),'sw': ('I_mem', 0x2B, None, {'signed_imm': True}),
    'lb': ('I_mem', 0x20, None, {'signed_imm': True}),'sb': ('I_mem', 0x28, None, {'signed_imm': True}),
    'beq': ('I_branch', 0x04, None, {'signed_imm': True}),'bne': ('I_branch', 0x05, None, {'signed_imm': True}),
    'lui': ('I_lui', 0x0F, None, {'signed_imm': False}),
    'j': ('J', 0x02, None, {}),'jal': ('J', 0x03, None, {}),
    'mtc1': ('COP1_M', 0x11, 0x04, {}),'mfc1': ('COP1_M', 0x11, 0x00, {}),
    'l.s': ('COP1_LS', 0x31, None, {}),'s.s': ('COP1_LS', 0x39, None, {}),
    'add.s': ('COP1_R', 0x11, 0x00, {'fmt': 0x10}),'sub.s': ('COP1_R', 0x11, 0x01, {'fmt': 0x10}),
    'mul.s': ('COP1_R', 0x11, 0x02, {'fmt': 0x10}),'div.s': ('COP1_R', 0x11, 0x03, {'fmt': 0x10}),
    'cvt.s.w':('COP1_R_CVT', 0x11, 0x20, {'fmt': 0x14}),'cvt.w.s':('COP1_R_CVT', 0x11, 0x24, {'fmt': 0x10}),
    'mov.s': ('COP1_R_MOV', 0x11, 0x06, {'fmt': 0x10}),
    'h': ('COP2_Q_RD', 0x12, 0x00, {}),'x': ('COP2_Q_RD', 0x12, 0x01, {}),
    'cnot': ('COP2_Q_RD_RS', 0x12, 0x02, {}),'measure': ('COP2_Q_RD', 0x12, 0x03, {}),
    'reset': ('COP2_Q_RD', 0x12, 0x04, {}),
    'cp': ('COP2_Q_RD_RS_RT', 0x12, 0x05, {}),
}

# --- Helper Functions ---

def to_binary(n, bits, signed=False):
    """Converts integer n to a binary string of 'bits' width."""
    mask = (1 << bits) - 1
    if not isinstance(n, int):
        raise TypeError(f"Value '{n}' is not an integer for to_binary")

    if signed:
        min_signed = -(1 << (bits - 1))
        max_signed = (1 << (bits - 1)) - 1
        if not min_signed <= n <= max_signed:
            raise ValueError(f"Signed value {n} out of range [{min_signed}, {max_signed}] for {bits} bits")
        # Compute two's complement if needed
        if n < 0:
            n = (1 << bits) + n
        # Apply mask
        result_bin = format(n & mask, f'0{bits}b')
    else:
        # Stricter unsigned check
        max_unsigned = (1 << bits) - 1
        if not 0 <= n <= max_unsigned:
            raise ValueError(f"Unsigned value {n} out of range [0, {max_unsigned}] for {bits} bits")
        # Apply mask (redundant but safe)
        result_bin = format(n & mask, f'0{bits}b')
    return result_bin

def parse_immediate(imm_str):
    """Parses immediate string (dec/hex/oct/bin) AND 'c' char literals."""
    imm_str = imm_str.strip()
    if not imm_str:
        raise ValueError("Empty immediate value")

    # --- Char Literal Handling ---
    is_char = False
    str_len = len(imm_str)
    if str_len >= 3:
        starts_ok = imm_str.startswith("'")
        if starts_ok:
            ends_ok = imm_str.endswith("'")
            if ends_ok:
                is_char = True

    if is_char:
        content = imm_str[1:-1]
        if content == '\\n':
            return ord('\n')
        elif content == '\\t':
            return ord('\t')
        elif content == '\\0':
            return ord('\0')
        elif content == '\\\\':
            return ord('\\')
        elif content == "\\'":
            return ord("'")
        elif content == ' ':
            return ord(' ')
        elif len(content) == 1:
            return ord(content)
        else:
            raise ValueError(f"Invalid char literal content: '{content}'")
    # --- Integer Handling ---
    else:
        try:
            if imm_str.lower().startswith('0b'):
                val = 0
                base_str = imm_str
                is_neg = False
                if imm_str.startswith('-'):
                    is_neg = True
                    base_str = imm_str[1:]
                elif imm_str.startswith('+'):
                    is_neg = False
                    base_str = imm_str[1:]

                if base_str.lower().startswith('0b'):
                    val_abs = int(base_str[2:], 2)
                    val = -val_abs if is_neg else val_abs
                else:
                    raise ValueError("Internal binary parse error")
                return val
            else:
                # int(base=0) handles decimal, '0x' hex, '0' or '0o' octal
                return int(imm_str, 0)
        except ValueError:
            raise ValueError(f"Invalid integer immediate value format: '{imm_str}'")

def format_binary(instr_bin, instr_type, fields):
    """Formats the 32-bit binary string with ANSI colors based on type."""
    parts = []
    reset = COLOR["RESET"]

    if instr_type == 'R':
        parts.append(f"{COLOR['OPCODE']}{instr_bin[0:6]}{reset}")
        parts.append(f"{COLOR['RS']}{instr_bin[6:11]}{reset}")
        parts.append(f"{COLOR['RT']}{instr_bin[11:16]}{reset}")
        parts.append(f"{COLOR['RD']}{instr_bin[16:21]}{reset}")
        parts.append(f"{COLOR['SHAMT']}{instr_bin[21:26]}{reset}")
        parts.append(f"{COLOR['FUNCT']}{instr_bin[26:32]}{reset}")
    elif instr_type == 'R_sh':
        parts.append(f"{COLOR['OPCODE']}{instr_bin[0:6]}{reset}")
        parts.append(f"{COLOR['RS']}{instr_bin[6:11]}{reset}")
        parts.append(f"{COLOR['RT']}{instr_bin[11:16]}{reset}")
        parts.append(f"{COLOR['RD']}{instr_bin[16:21]}{reset}")
        parts.append(f"{COLOR['SHAMT']}{instr_bin[21:26]}{reset}")
        parts.append(f"{COLOR['FUNCT']}{instr_bin[26:32]}{reset}")
    elif instr_type == 'R_jr':
        parts.append(f"{COLOR['OPCODE']}{instr_bin[0:6]}{reset}")
        parts.append(f"{COLOR['RS']}{instr_bin[6:11]}{reset}")
        parts.append(f"{COLOR['RT']}{instr_bin[11:16]}{reset}")
        parts.append(f"{COLOR['RD']}{instr_bin[16:21]}{reset}")
        parts.append(f"{COLOR['SHAMT']}{instr_bin[21:26]}{reset}")
        parts.append(f"{COLOR['FUNCT']}{instr_bin[26:32]}{reset}")
    elif instr_type == 'R_m':
        parts.append(f"{COLOR['OPCODE']}{instr_bin[0:6]}{reset}")
        parts.append(f"{COLOR['RS']}{instr_bin[6:11]}{reset}")
        parts.append(f"{COLOR['RT']}{instr_bin[11:16]}{reset}")
        parts.append(f"{COLOR['RD']}{instr_bin[16:21]}{reset}")
        parts.append(f"{COLOR['SHAMT']}{instr_bin[21:26]}{reset}")
        parts.append(f"{COLOR['FUNCT']}{instr_bin[26:32]}{reset}")
    elif instr_type == 'R_mf':
        parts.append(f"{COLOR['OPCODE']}{instr_bin[0:6]}{reset}")
        parts.append(f"{COLOR['RS']}{instr_bin[6:11]}{reset}")
        parts.append(f"{COLOR['RT']}{instr_bin[11:16]}{reset}")
        parts.append(f"{COLOR['RD']}{instr_bin[16:21]}{reset}")
        parts.append(f"{COLOR['SHAMT']}{instr_bin[21:26]}{reset}")
        parts.append(f"{COLOR['FUNCT']}{instr_bin[26:32]}{reset}")
    elif instr_type == 'R_syscall':
        parts.append(f"{COLOR['OPCODE']}{instr_bin[0:6]}{reset}")
        parts.append(f"{COLOR['IMM']}{instr_bin[6:26]}{reset}")
        parts.append(f"{COLOR['FUNCT']}{instr_bin[26:32]}{reset}")
    elif instr_type in ('I', 'I_mem', 'I_branch', 'I_lui'):
        parts.append(f"{COLOR['OPCODE']}{instr_bin[0:6]}{reset}")
        parts.append(f"{COLOR['RS']}{instr_bin[6:11]}{reset}")
        parts.append(f"{COLOR['RT']}{instr_bin[11:16]}{reset}")
        parts.append(f"{COLOR['IMM']}{instr_bin[16:32]}{reset}")
    elif instr_type == 'J':
        parts.append(f"{COLOR['OPCODE']}{instr_bin[0:6]}{reset}")
        parts.append(f"{COLOR['TARGET']}{instr_bin[6:32]}{reset}")
    elif instr_type == 'COP1_M':
        parts.append(f"{COLOR['COP']}{instr_bin[0:6]}{reset}")
        parts.append(f"{COLOR['FMT']}{instr_bin[6:11]}{reset}")
        parts.append(f"{COLOR['RT']}{instr_bin[11:16]}{reset}")
        parts.append(f"{COLOR['FD']}{instr_bin[16:21]}{reset}")
        parts.append(f"{COLOR['IMM']}{instr_bin[21:32]}{reset}")
    elif instr_type == 'COP1_LS':
        parts.append(f"{COLOR['COP']}{instr_bin[0:6]}{reset}")
        parts.append(f"{COLOR['RS']}{instr_bin[6:11]}{reset}")
        parts.append(f"{COLOR['FT']}{instr_bin[11:16]}{reset}")
        parts.append(f"{COLOR['IMM']}{instr_bin[16:32]}{reset}")
    elif instr_type == 'COP1_R':
        parts.append(f"{COLOR['COP']}{instr_bin[0:6]}{reset}")
        parts.append(f"{COLOR['FMT']}{instr_bin[6:11]}{reset}")
        parts.append(f"{COLOR['FT']}{instr_bin[11:16]}{reset}")
        parts.append(f"{COLOR['FS']}{instr_bin[16:21]}{reset}")
        parts.append(f"{COLOR['FD']}{instr_bin[21:26]}{reset}")
        parts.append(f"{COLOR['FUNCT']}{instr_bin[26:32]}{reset}")
    elif instr_type == 'COP1_R_CVT':
        parts.append(f"{COLOR['COP']}{instr_bin[0:6]}{reset}")
        parts.append(f"{COLOR['FMT']}{instr_bin[6:11]}{reset}")
        parts.append(f"{COLOR['RT']}{instr_bin[11:16]}{reset}")
        parts.append(f"{COLOR['FS']}{instr_bin[16:21]}{reset}")
        parts.append(f"{COLOR['FD']}{instr_bin[21:26]}{reset}")
        parts.append(f"{COLOR['FUNCT']}{instr_bin[26:32]}{reset}")
    elif instr_type == 'COP1_R_MOV':
        parts.append(f"{COLOR['COP']}{instr_bin[0:6]}{reset}")
        parts.append(f"{COLOR['FMT']}{instr_bin[6:11]}{reset}")
        parts.append(f"{COLOR['RT']}{instr_bin[11:16]}{reset}")
        parts.append(f"{COLOR['FS']}{instr_bin[16:21]}{reset}")
        parts.append(f"{COLOR['FD']}{instr_bin[21:26]}{reset}")
        parts.append(f"{COLOR['FUNCT']}{instr_bin[26:32]}{reset}")
    elif instr_type == 'COP2_Q_RD':
        parts.append(f"{COLOR['COP']}{instr_bin[0:6]}{reset}")
        parts.append(f"{COLOR['RS']}{instr_bin[6:11]}{reset}")
        parts.append(f"{COLOR['RT']}{instr_bin[11:16]}{reset}")
        parts.append(f"{COLOR['QRD']}{instr_bin[16:21]}{reset}")
        parts.append(f"{COLOR['SHAMT']}{instr_bin[21:26]}{reset}")
        parts.append(f"{COLOR['QOP']}{instr_bin[26:32]}{reset}")
    elif instr_type == 'COP2_Q_RD_RS':
        parts.append(f"{COLOR['COP']}{instr_bin[0:6]}{reset}")
        parts.append(f"{COLOR['QRS']}{instr_bin[6:11]}{reset}")
        parts.append(f"{COLOR['RT']}{instr_bin[11:16]}{reset}")
        parts.append(f"{COLOR['QRD']}{instr_bin[16:21]}{reset}")
        parts.append(f"{COLOR['SHAMT']}{instr_bin[21:26]}{reset}")
        parts.append(f"{COLOR['QOP']}{instr_bin[26:32]}{reset}")
    elif instr_type == 'COP2_Q_RD_RS_RT': # Handle cp
        parts.append(f"{COLOR['COP']}{instr_bin[0:6]}{reset}")   # Opcode (COP2)
        parts.append(f"{COLOR['QRS']}{instr_bin[6:11]}{reset}")  # rs (Control Qubit GPR)
        parts.append(f"{COLOR['RT']}{instr_bin[11:16]}{reset}") # rt (Angle GPR)
        parts.append(f"{COLOR['QRD']}{instr_bin[16:21]}{reset}") # rd (Target Qubit GPR)
        parts.append(f"{COLOR['SHAMT']}{instr_bin[21:26]}{reset}")# shamt (unused, 0)
        parts.append(f"{COLOR['QOP']}{instr_bin[26:32]}{reset}") # QOP (funct code for cp)
    else:
         parts.append(instr_bin)
    return " ".join(parts)

# --- Assembler Core Logic ---

labels={}

def assemble(assembly_code,giv_hex=True):
    """Assembles MIPS assembly code into binary strings for the .text segment."""
    global labels
    lines = assembly_code.splitlines()
    labels = {}
    global_labels = set()
    parsed_lines = []
    current_segment = ".text"

    # --- Pre-Pass ---
    print("--- Pre-Pass: Stripping Comments & Basic Parsing ---")
    for line_num, line in enumerate(lines):
        original_line = line
        comment_pos = line.find('#')
        if comment_pos != -1:
            line = line[:comment_pos]
        line = line.strip()

        if not line:
            continue

        # Handle directives that affect parsing flow immediately
        if line == ".text":
            current_segment = ".text"
            print(f"  Line {line_num+1}: Switched to .text segment")
            continue
        elif line == ".data":
            current_segment = ".data"
            print(f"  Line {line_num+1}: Switched to .data segment")
            continue
        elif line.startswith(".globl"):
            parts = line.split()
            if len(parts) == 2:
                label_name = parts[1].strip()
                global_labels.add(label_name)
                print(f"  Line {line_num+1}: Declared '{label_name}' as global")
            else:
                print(f"Warning line {line_num+1}: Malformed .globl directive: {line}")
            continue

        # Store line info for Pass 1
        parsed_lines.append({
            'line_num': line_num + 1,
            'text': line,
            'segment': current_segment,
            'original': original_line
            })

    # --- Pass 1 ---
    print("--- Pass 1: Calculating Addresses & Expanding Pseudo-Instructions ---")
    expanded_instructions = []
    current_text_address_offset = 0 # Offset in words from CODE_BASE_ADDRESS
    current_data_address = DATA_BASE_ADDRESS

    for item in parsed_lines:
        line_num = item['line_num']
        line = item['text']
        original_line = item['original']
        segment = item['segment']

        # --- Data Segment Address Calculation ---
        if segment == ".data":
            label = None
            directive_part = line
            if ':' in line:
                parts = line.split(':', 1)
                label_part = parts[0].strip()
                is_valid_label = (label_part and
                                 (label_part[0].isalpha() or label_part[0] == '_') and
                                 all(c.isalnum() or c == '_' for c in label_part))
                if is_valid_label:
                    label = label_part
                    directive_part = parts[1].strip()
                else:
                    label = None
                    directive_part = line

            # Align *before* placing label if needed by directive
            parts = directive_part.split(None, 1)
            directive = parts[0].lower() if parts else ""
            value_str = parts[1] if len(parts) > 1 else ""

            align_needed = 0 # Default byte alignment
            if directive in [".word", ".float"]:
                align_needed = 2 # Align to 4 bytes (2^2)
            elif directive == ".align":
                try:
                    align_needed = parse_immediate(value_str)
                    if align_needed < 0: raise ValueError("Align value cannot be negative")
                except ValueError as e:
                    print(f"Error processing .align line {line_num}: {e}")
                    align_needed = 0 # Default on error

            if align_needed > 0:
                alignment = 1 << align_needed
                mask = alignment - 1
                if current_data_address & mask:
                    padding = alignment - (current_data_address & mask)
                    current_data_address += padding
                    print(f"    (Added {padding} bytes padding for alignment {align_needed})")

            # Place label *after* potential alignment
            if label:
                if label in labels:
                    print(f"Warning line {line_num}: Duplicate label '{label}'")
                labels[label] = current_data_address
                print(f"  Data Label '{label}' found at address 0x{current_data_address:08X}")

            if not directive_part:
                continue # Label only line after alignment

            # Calculate size and advance data address
            try:
                if directive in [".word", ".float"]:
                    current_data_address += 4
                elif directive == ".byte":
                    # Assume one value for simplicity here, real assembler handles lists
                    current_data_address += 1
                elif directive == ".asciiz":
                    match = re.search(r'"(.*)"', value_str)
                    str_len = 0
                    if match:
                        raw_str = match.group(1)
                        i = 0
                        while i < len(raw_str):
                            if raw_str[i] == '\\' and i + 1 < len(raw_str):
                                str_len += 1
                                i += 2
                            else:
                                str_len += 1
                                i += 1
                        str_len += 1 # Null terminator
                    else:
                         print(f"Warning line {line_num}: Bad .asciiz for size: {value_str}")
                    current_data_address += str_len
                elif directive == ".space":
                    size = parse_immediate(value_str)
                    if size < 0: raise ValueError("Space size negative")
                    current_data_address += size
                elif directive == ".align":
                    pass # Alignment handled above, no size increase here
                else:
                     print(f"Warning line {line_num}: Unhandled data directive: {directive}")

            except ValueError as e:
                 print(f"Error processing data directive size line {line_num}: {e}")

        # --- Text Segment Address Calculation & Expansion ---
        elif segment == ".text":
            label = None
            instruction_part = line
            if ':' in line:
                parts = line.split(':', 1)
                label_part = parts[0].strip()
                is_valid_label = (label_part and
                                 (label_part[0].isalpha() or label_part[0] == '_') and
                                 all(c.isalnum() or c == '_' for c in label_part))
                if is_valid_label:
                    label = label_part
                    instruction_part = parts[1].strip()
                else:
                    label = None
                    instruction_part = line

            instr_address = CODE_BASE_ADDRESS + current_text_address_offset * 4
            if label:
                if label in labels:
                    print(f"Warning line {line_num}: Duplicate label '{label}'")
                labels[label] = instr_address
                print(f"  Text Label '{label}' found at address 0x{instr_address:08X}")

            if not instruction_part:
                continue # Label only line

            parts = instruction_part.split(None, 1)
            mnemonic = parts[0].lower()
            operands_str = parts[1] if len(parts) > 1 else ""
            operand_regex = r"'(?:\\.|[^'])*'|-?\d+\(\$\w+\)|\$\w+|-?\b(?:0x[0-9a-fA-F]+|0b[01]+|0o[0-7]+|\d+)\b|\b\w+\b"
            operands = [op.strip() for op in re.findall(operand_regex, operands_str)]

            original_line_display = f"0x{instr_address:08X}: {instruction_part}"

            expanded_current_instr = []
            try:
                if mnemonic == 'move':
                    if len(operands)!=2: raise ValueError(f"Invalid 'move' operands: {operands}")
                    expanded_current_instr.append({'op':'add','args':[operands[0],operands[1],'$zero']})
                elif mnemonic == 'li':
                    if len(operands)!=2: raise ValueError(f"Invalid 'li' operands: {operands}")
                    imm=parse_immediate(operands[1])
                    if -32768<=imm<=32767: expanded_current_instr.append({'op':'addi','args':[operands[0],'$zero',str(imm)]})
                    else:
                        # For large immediates, expand into LUI and ORI without carry adjustment
                        upper = (imm >> 16) & 0xFFFF  # Extract upper 16 bits
                        lower = imm & 0xFFFF          # Extract lower 16 bits

                        # Load upper half into $at
                        expanded_current_instr.append({
                            'op': 'lui',
                            'args': ['$at', hex(upper)]
                        })

                        # Load lower half into target register
                        expanded_current_instr.append({
                            'op': 'ori',
                            'args': [operands[0], '$at', hex(lower)]
                        })
                elif mnemonic == 'la':
                    if len(operands)!=2: raise ValueError(f"Invalid 'la' operands: {operands}")
                    ln=operands[1]; expanded_current_instr.append({'op':'lui','args':['$at',f'upper({ln})']}); expanded_current_instr.append({'op':'ori','args':[operands[0],'$at',f'lower({ln})']})
                elif mnemonic == 'sgt':
                     if len(operands)!=3: raise ValueError(f"Invalid 'sgt' operands: {operands}")
                     expanded_current_instr.append({'op':'slt','args':[operands[0],operands[2],operands[1]]})
                else: # Base instruction
                    expanded_current_instr.append({'op':mnemonic,'args':operands})

                instr_count_in_expansion = 0
                for instr_data in expanded_current_instr:
                     current_expanded_addr = CODE_BASE_ADDRESS + (current_text_address_offset + instr_count_in_expansion) * 4
                     display_line = original_line_display
                     if len(expanded_current_instr) > 1:
                         display_line += f" ({'lui' if instr_count_in_expansion == 0 else 'ori'} part)"

                     expanded_instructions.append({
                         'addr': current_expanded_addr,
                         'line': display_line,
                         'op': instr_data['op'],
                         'args': instr_data['args'],
                         'line_num': line_num
                     })
                     instr_count_in_expansion += 1
                current_text_address_offset += len(expanded_current_instr)

            except ValueError as e:
                 print(f"Error expanding/parsing line {line_num}: {e}")

    # --- Pass 2: Encoding ---
    print("--- Pass 2: Encoding Instructions ---")
    binary_instructions = []
    final_output_lines = []

    for instr_info in expanded_instructions:
        current_addr = instr_info['addr']
        mnemonic = instr_info['op']
        operands = instr_info['args']
        original_line = instr_info['line']
        line_num = instr_info['line_num']
        instr_bin = "0" * 32
        instr_type = '?'
        fields = {}

        try:
            if mnemonic not in INSTR_MAP:
                # Handle placeholders from 'la' expansion
                if mnemonic == 'lui' and len(operands) == 2 and operands[1].startswith('upper('):
                    label_name = operands[1][6:-1]
                    if label_name not in labels: raise ValueError(f"Label '{label_name}' NF for LA")
                    label_addr = labels[label_name]
                    upper_imm = (label_addr >> 16) & 0xFFFF
                    opcode_info=INSTR_MAP['lui']; instr_type=opcode_info[0]
                    op=to_binary(opcode_info[1],6); rs=to_binary(0,5); rt=to_binary(REG_MAP['$at'],5); imm=to_binary(upper_imm,16)
                    instr_bin=op+rs+rt+imm; fields={'op':op, 'rs':rs, 'rt':rt, 'imm':imm}
                elif mnemonic == 'ori' and len(operands) == 3 and operands[2].startswith('lower('):
                    label_name = operands[2][6:-1]
                    if label_name not in labels: raise ValueError(f"Label '{label_name}' NF for LA")
                    label_addr = labels[label_name]
                    lower_imm = label_addr & 0xFFFF
                    opcode_info=INSTR_MAP['ori']; instr_type=opcode_info[0]
                    rd_reg_idx=REG_MAP[operands[0]]; at_reg_idx=REG_MAP['$at']
                    op=to_binary(opcode_info[1],6); rs=to_binary(at_reg_idx,5); rt=to_binary(rd_reg_idx,5); imm=to_binary(lower_imm,16,signed=False)
                    instr_bin=op+rs+rt+imm; fields={'op':op, 'rs':rs, 'rt':rt, 'imm':imm}
                else:
                     raise ValueError(f"Unknown instruction mnemonic: '{mnemonic}'")
            else:
                # --- Encoding logic for base instructions ---
                opcode_info = INSTR_MAP[mnemonic]
                instr_type, op_val, funct_fmt_cop, info = opcode_info
                op = to_binary(op_val, 6)
                rs_bin=rt_bin=rd_bin=shamt_bin=funct_bin=imm_bin=target_bin=""
                rs=rt=rd=shamt=funct=imm=target=None

                # R-Type
                if instr_type == 'R':
                    if len(operands)!=3: raise ValueError(f"{mnemonic} 3ops")
                    rd = REG_MAP[operands[0]]; rs = REG_MAP[operands[1]]; rt = REG_MAP[operands[2]]
                    rd_bin=to_binary(rd,5); rs_bin=to_binary(rs,5); rt_bin=to_binary(rt,5); shamt_bin=to_binary(0,5); funct_bin=to_binary(funct_fmt_cop,6)
                    instr_bin=op+rs_bin+rt_bin+rd_bin+shamt_bin+funct_bin; fields={'op':op,'rs':rs_bin,'rt':rt_bin,'rd':rd_bin,'shamt':shamt_bin,'funct':funct_bin}
                # R_sh Type
                elif instr_type == 'R_sh':
                    if len(operands)!=3: raise ValueError(f"{mnemonic} 3ops")
                    rd = REG_MAP[operands[0]]; rt = REG_MAP[operands[1]]; shamt = parse_immediate(operands[2])
                    rd_bin=to_binary(rd,5); rt_bin=to_binary(rt,5); shamt_bin=to_binary(shamt,5); rs_bin=to_binary(0,5); funct_bin=to_binary(funct_fmt_cop,6)
                    instr_bin=op+rs_bin+rt_bin+rd_bin+shamt_bin+funct_bin; fields={'op':op,'rs':rs_bin,'rt':rt_bin,'rd':rd_bin,'shamt':shamt_bin,'funct':funct_bin}
                # R_jr Type
                elif instr_type == 'R_jr':
                    if len(operands)!=1: raise ValueError(f"{mnemonic} 1op")
                    rs = REG_MAP[operands[0]]
                    rs_bin=to_binary(rs,5); rt_bin=rd_bin=shamt_bin=to_binary(0,5); funct_bin=to_binary(funct_fmt_cop,6)
                    instr_bin=op+rs_bin+rt_bin+rd_bin+shamt_bin+funct_bin; fields={'op':op,'rs':rs_bin,'rt':rt_bin,'rd':rd_bin,'shamt':shamt_bin,'funct':funct_bin}
                # R_m Type (mult)
                elif instr_type == 'R_m':
                    if len(operands)!=2: raise ValueError(f"{mnemonic} 2ops")
                    rs = REG_MAP[operands[0]]; rt = REG_MAP[operands[1]]
                    rs_bin=to_binary(rs,5); rt_bin=to_binary(rt,5); rd_bin=shamt_bin=to_binary(0,5); funct_bin=to_binary(funct_fmt_cop,6)
                    instr_bin=op+rs_bin+rt_bin+rd_bin+shamt_bin+funct_bin; fields={'op':op,'rs':rs_bin,'rt':rt_bin,'rd':rd_bin,'shamt':shamt_bin,'funct':funct_bin}
                # R_mf Type (mfhi, mflo)
                elif instr_type == 'R_mf':
                    if len(operands)!=1: raise ValueError(f"{mnemonic} 1op")
                    rd = REG_MAP[operands[0]]
                    rd_bin=to_binary(rd,5); rs_bin=rt_bin=shamt_bin=to_binary(0,5); funct_bin=to_binary(funct_fmt_cop,6)
                    instr_bin=op+rs_bin+rt_bin+rd_bin+shamt_bin+funct_bin; fields={'op':op,'rs':rs_bin,'rt':rt_bin,'rd':rd_bin,'shamt':shamt_bin,'funct':funct_bin}
                # R_syscall Type
                elif instr_type == 'R_syscall':
                    rs_bin=rt_bin=rd_bin=shamt_bin=to_binary(0,5); funct_bin=to_binary(funct_fmt_cop,6); code_bin=to_binary(0,20)
                    instr_bin=op+code_bin+funct_bin; fields={'op':op,'imm':code_bin,'funct':funct_bin}
                # I Types (I, I_mem, I_branch, I_lui)
                elif instr_type in ('I','I_mem','I_branch','I_lui'):
                    signed=info.get('signed_imm',False); imm_val=0; rs=rt=0; rs_bin=rt_bin=to_binary(0,5)
                    # Inside Pass 2 encoding logic in ASS.py

                    if instr_type == 'I_lui': # Handles the base LUI instruction (rt, imm)
                        # Validate operand count
                        if len(operands) != 2: # Expecting register and immediate
                            raise ValueError(f"lui requires 2 operands (rt, immediate), got: {operands}") # Error if not 2 operands

                        # Get target register name and immediate string
                        rt_reg_name = operands[0] # First operand is the target register name
                        imm_str = operands[1] # Second operand is the immediate string

                        # Get encoding details from INSTR_MAP
                        opcode_info = INSTR_MAP['lui'] # Fetch 'lui' details
                        op_val = opcode_info[1] # Opcode value (0x0F)

                        # --- Resolve Immediate ---
                        # Check if this lui comes from 'la' expansion (e.g., 'upper(label)')
                        if imm_str.startswith('upper(') and imm_str.endswith(')'): # Check for 'upper(label)' format
                            label_name = imm_str[6:-1] # Extract the label name
                            if label_name not in labels: # Ensure the label was defined in Pass 1
                                raise ValueError(f"Label '{label_name}' not found for 'la' expansion") # Error if label missing
                            label_addr = labels[label_name] # Get the label's address
                            imm_val = (label_addr >> 16) & 0xFFFF # Calculate the upper 16 bits of the label's address
                        else: # Standard 'lui' or from 'li' expansion
                            imm_val = parse_immediate(imm_str) # Parse the immediate string normally

                        # --- Get Register Indices ---
                        try: # Use try-except for robust register name lookup
                            rt = REG_MAP[rt_reg_name] # Get the numerical index for the target register 'rt'
                        except KeyError: # Handle case where register name is invalid
                            raise ValueError(f"Invalid target register name for lui: '{rt_reg_name}'") # Error for bad register name

                        rs = 0 # The 'rs' field for LUI *must* always be 0 according to MIPS ISA

                        # --- Convert fields to binary strings ---
                        op_bin = to_binary(op_val, 6) # Convert opcode to 6-bit binary string
                        rs_bin = to_binary(rs, 5) # Convert rs index (0) to 5-bit binary string ('00000')
                        rt_bin = to_binary(rt, 5) # Convert rt index to 5-bit binary string
                        imm_bin = to_binary(imm_val, 16, signed=False) # Convert immediate to 16-bit unsigned binary string

                        # --- Assemble final binary instruction string ---
                        # Correct MIPS LUI format: opcode | rs (0) | rt | immediate
                        instr_bin = op_bin + rs_bin + rt_bin + imm_bin # Concatenate fields in the correct order

                        # Store field breakdown for optional formatted binary output
                        fields = {'op': op_bin, 'rs': rs_bin, 'rt': rt_bin, 'imm': imm_bin} # Store for formatting function

                    elif instr_type == 'I':
                        if len(operands)!=3: raise ValueError(f"{mnemonic} 3ops")
                        rt=REG_MAP[operands[0]]; rs=REG_MAP[operands[1]]; imm_val=parse_immediate(operands[2])
                        rt_bin=to_binary(rt,5); rs_bin=to_binary(rs,5)
                    elif instr_type == 'I_mem':
                        if len(operands)!=2: raise ValueError(f"{mnemonic} 2ops")
                        rt=REG_MAP[operands[0]]; m=re.match(r'(-?\d+)\((\$\w+)\)',operands[1])
                        if not m: raise ValueError(f"Bad offset: {operands[1]}")
                        imm_val=parse_immediate(m.group(1)); rs=REG_MAP[m.group(2)]
                        rt_bin=to_binary(rt,5); rs_bin=to_binary(rs,5)
                    elif instr_type == 'I_branch':
                        if len(operands)!=3: raise ValueError(f"{mnemonic} 3ops")
                        rs=REG_MAP[operands[0]]; rt=REG_MAP[operands[1]]; ln=operands[2]
                        if ln not in labels: raise ValueError(f"Label '{ln}' NF")
                        la=labels[ln]; offset=(la-(current_addr+4))
                        if offset%4!=0: raise ValueError(f"Branch target {hex(la)} misaligned from {hex(current_addr+4)}")
                        imm_val=offset>>2
                        rs_bin=to_binary(rs,5); rt_bin=to_binary(rt,5)
                    # Encode immediate
                    imm_bin=to_binary(imm_val,16,signed=signed)
                    instr_bin=op+rs_bin+rt_bin+imm_bin; fields={'op':op,'rs':rs_bin,'rt':rt_bin,'imm':imm_bin}
                # J Type
                elif instr_type == 'J':
                    if len(operands)!=1: raise ValueError(f"{mnemonic} 1op")
                    ln=operands[0];
                    if ln not in labels: raise ValueError(f"Label '{ln}' NF")
                    la=labels[ln]; target_val=(la>>2)&0x3FFFFFF
                    target_bin=to_binary(target_val,26)
                    instr_bin=op+target_bin; fields={'op':op,'target':target_bin}
                # COP1_M Type
                elif instr_type == 'COP1_M':
                     if len(operands)!=2: raise ValueError(f"{mnemonic} 2ops")
                     rt=REG_MAP[operands[0]]; rd=REG_MAP[operands[1]]
                     rt_bin=to_binary(rt,5); rd_bin=to_binary(rd,5); fmt_bin=to_binary(funct_fmt_cop,5); zeros_bin=to_binary(0,11)
                     instr_bin=op+fmt_bin+rt_bin+rd_bin+zeros_bin; fields={'op':op,'fmt':fmt_bin,'rt':rt_bin,'fd':rd_bin}
                # COP1_LS Type
                elif instr_type == 'COP1_LS':
                    if len(operands)!=2: raise ValueError(f"{mnemonic} 2ops")
                    ft=REG_MAP[operands[0]]; m=re.match(r'(-?\d+)\((\$\w+)\)',operands[1])
                    if not m: raise ValueError(f"Bad offset: {operands[1]}")
                    imm_val=parse_immediate(m.group(1)); rs=REG_MAP[m.group(2)]
                    ft_bin=to_binary(ft,5); rs_bin=to_binary(rs,5); imm_bin=to_binary(imm_val,16,signed=True)
                    instr_bin=op+rs_bin+ft_bin+imm_bin; fields={'op':op,'rs':rs_bin,'ft':ft_bin,'imm':imm_bin}
                # COP1_R Type
                elif instr_type == 'COP1_R':
                    if len(operands)!=3: raise ValueError(f"{mnemonic} 3ops")
                    fd=REG_MAP[operands[0]]; fs=REG_MAP[operands[1]]; ft=REG_MAP[operands[2]]
                    fd_bin=to_binary(fd,5); fs_bin=to_binary(fs,5); ft_bin=to_binary(ft,5); fmt_bin=to_binary(info['fmt'],5); funct_bin=to_binary(funct_fmt_cop,6)
                    instr_bin=op+fmt_bin+ft_bin+fs_bin+fd_bin+funct_bin; fields={'op':op,'fmt':fmt_bin,'ft':ft_bin,'fs':fs_bin,'fd':fd_bin,'funct':funct_bin}
                # COP1_R_CVT Type
                elif instr_type == 'COP1_R_CVT':
                    if len(operands)!=2: raise ValueError(f"{mnemonic} 2ops")
                    fd=REG_MAP[operands[0]]; fs=REG_MAP[operands[1]]
                    fd_bin=to_binary(fd,5); fs_bin=to_binary(fs,5); fmt_bin=to_binary(info['fmt'],5); ft_bin=to_binary(0,5); funct_bin=to_binary(funct_fmt_cop,6)
                    instr_bin=op+fmt_bin+ft_bin+fs_bin+fd_bin+funct_bin; fields={'op':op,'fmt':fmt_bin,'rt':ft_bin,'fs':fs_bin,'fd':fd_bin,'funct':funct_bin}
                # COP1_R_MOV Type
                elif instr_type == 'COP1_R_MOV':
                     if len(operands)!=2: raise ValueError(f"{mnemonic} 2ops")
                     fd=REG_MAP[operands[0]]; fs=REG_MAP[operands[1]]
                     fd_bin=to_binary(fd,5); fs_bin=to_binary(fs,5); fmt_bin=to_binary(info['fmt'],5); ft_bin=to_binary(0,5); funct_bin=to_binary(funct_fmt_cop,6)
                     instr_bin=op+fmt_bin+ft_bin+fs_bin+fd_bin+funct_bin; fields={'op':op,'fmt':fmt_bin,'rt':ft_bin,'fs':fs_bin,'fd':fd_bin,'funct':funct_bin}
                # COP2_Q_RD Type
                elif instr_type == 'COP2_Q_RD':
                    if len(operands)!=1: raise ValueError(f"{mnemonic} 1op")
                    rd=REG_MAP[operands[0]]
                    rd_bin=to_binary(rd,5); rs_bin=to_binary(1,5); rt_bin=shamt_bin=to_binary(0,5); funct_bin=to_binary(funct_fmt_cop,6)
                    instr_bin=op+rs_bin+rt_bin+rd_bin+shamt_bin+funct_bin; fields={'op':op,'rs':rs_bin,'rt':rt_bin,'qrd':rd_bin,'shamt':shamt_bin,'qop':funct_bin}
                # COP2_Q_RD_RS Type
                elif instr_type == 'COP2_Q_RD_RS':
                    if len(operands)!=2: raise ValueError(f"{mnemonic} 2ops")
                    rs=REG_MAP[operands[0]]; rd=REG_MAP[operands[1]]
                    rd_bin=to_binary(rd,5); rs_bin=to_binary(rs,5); rt_bin=shamt_bin=to_binary(0,5); funct_bin=to_binary(funct_fmt_cop,6)
                    instr_bin=op+rs_bin+rt_bin+rd_bin+shamt_bin+funct_bin; fields={'op':op,'qrs':rs_bin,'rt':rt_bin,'qrd':rd_bin,'shamt':shamt_bin,'qop':funct_bin}
                # --- ADD THIS ELIF BLOCK for cp ---
                # COP2_Q_RD_RS_RT Type
                elif instr_type == 'COP2_Q_RD_RS_RT': # Handle cp $r_angle, $r_control, $r_target
                    if len(operands) != 3:
                        raise ValueError(f"cp requires 3 GPR operands (angle, control, target), got: {operands}")

                    rt = REG_MAP[operands[0]] # Angle GPR index
                    rs = REG_MAP[operands[1]] # Control Qubit GPR index
                    rd = REG_MAP[operands[2]] # Target Qubit GPR index
                    shamt = 0

                    rs_bin = to_binary(rs, 5)
                    rt_bin = to_binary(rt, 5)
                    rd_bin = to_binary(rd, 5)
                    shamt_bin = to_binary(shamt, 5)
                    funct_bin = to_binary(funct_fmt_cop, 6) # funct_fmt_cop is 0x05 for cp

                    # Format: op | rs | rt | rd | shamt | funct
                    instr_bin = op + rs_bin + rt_bin + rd_bin + shamt_bin + funct_bin
                    fields = {'op': op, 'qrs': rs_bin, 'rt': rt_bin, 'qrd': rd_bin, 'shamt': shamt_bin, 'qop': funct_bin}
                # --- END ADDITION ---
                else:
                    raise ValueError(f"Encoding NYI: '{instr_type}'")

            # Append results
            binary_instructions.append(instr_bin)
            formatted_bin = format_binary(instr_bin, instr_type, fields)
            final_output_lines.append(f"{original_line:<40} # {formatted_bin}")

        except ValueError as e:
            error_msg = f"ERROR (ValueError): {e}"
            final_output_lines.append(f"{original_line:<40} # {error_msg}")
            binary_instructions.append("0"*32) # Append NOP on error
            print(f"Error assembling line {line_num}: {original_line}\n  >> {e}", file=sys.stderr)
        except KeyError as e:
            error_msg = f"ERROR (KeyError): Invalid register {e}"
            final_output_lines.append(f"{original_line:<40} # {error_msg}")
            binary_instructions.append("0"*32)
            print(f"Error assembling line {line_num}: {original_line}\n  >> Invalid register {e}", file=sys.stderr)
        except Exception as e:
            error_msg = f"ERROR ({type(e).__name__}): {e}"
            final_output_lines.append(f"{original_line:<40} # {error_msg}")
            binary_instructions.append("0"*32)
            print(f"Unexpected error assembling line {line_num}: {original_line}\n  >> {e}", file=sys.stderr)

    # Print formatted lines to standard output
    print("\n--- Assembled Code (.text segment) ---")
    for line in final_output_lines:
        print(line)

    # Return newline-separated binary strings
    hex_output = "\n".join([f"{int(instr_bin, 2):08X}" for instr_bin in binary_instructions])
    if giv_hex:return hex_output
    # Return binary strings for each instruction
    return "\n".join(binary_instructions)

# --- Main execution block ---
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: python {sys.argv[0]} <input_assembly_file.s>")
        sys.exit(1)

    file_path = sys.argv[1]
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' not found.")
        sys.exit(1)

    try:
        f = open(file_path, 'r')
        assembly_code = f.read()
        f.close()

        #binary_output = assemble(assembly_code)
        hex_output = assemble(assembly_code,giv_hex=True)

        # Check for 'main' label and print its address to stderr
        if 'main' in labels:
            main_addr = labels['main']
            print(f"\nINFO: 'main' label found at address: 0x{main_addr:08X}")
        else:
            print("\nWARNING: 'main' label not found in the assembly code.")

        # Example: Write binary output to file
        #output_file = os.path.splitext(file_path)[0] + ".bin"
        output_file = os.path.splitext(file_path)[0] + ".hex"
        f_out = open(output_file, 'w')
        #f_out.write(binary_output)
        f_out.write(hex_output)
        f_out.close()
        #print(f"\nBinary output optionally written to {output_file}")
        print(f"\nHex output optionally written to {output_file}")

    except Exception as e:
        print(f"\n--- Assembly Failed ---")
        print(f"Error: {e}")
        traceback.print_exc()
        sys.exit(1)
