main:
lx00400000: j lx0040000C # -> Code+0xC
lx00400004: add $t1, $ra, $zero
lx00400008: jr $ra
lx0040000C: lui $s7, 0x6000
lx00400010: ori $sp, $s7, 0x0
lx00400014: addi $s0, $sp, 0
lx00400018: addi $s5, $sp, 4
lx0040001C: addi $s1, $s0, -16
lx00400020: jal lx00400004 # -> Code+0x4
lx00400024: addi $t1, $t1, 16
lx00400028: lui $s7, 0x8000
lx0040002C: ori $t2, $s7, 0x0
lx00400030: or $t1, $t1, $t2
lx00400034: sw $t1, -8($s0)
lx00400038: addi $t8, $zero, 1
lx0040003C: addi $t9, $zero, 1
lx00400040: add $t2, $ra, $zero
lx00400044: jal lx00400004 # -> Code+0x4
lx00400048: add $ra, $t2, $zero
lx0040004C: addi $t1, $t1, 28
lx00400050: sll $t2, $t8, 31
lx00400054: or $t1, $t1, $t2
lx00400058: addi $s1, $s1, -4
lx0040005C: sw $t1, 0($s1)
lx00400060: j lx00400078 # -> Code+0x78
lx00400064: lw $t0, 0($s0)
lx00400068: addi $t9, $zero, 0
lx0040006C: add $s1, $s0, $zero
lx00400070: add $s0, $zero, $t0
lx00400074: jr $ra
lx00400078: lw $t2, -8($s0)
lx0040007C: lui $s7, 0x7f00
lx00400080: ori $t5, $s7, 0x0
lx00400084: lui $s7, 0x1fff
lx00400088: ori $t6, $s7, 0xffff
lx0040008C: and $t1, $t1, $t6
lx00400090: or $t1, $t1, $t5
lx00400094: sw $t2, 0($t1)
lx00400098: sw $zero, 4($t1)
lx0040009C: lw $t1, 0($s1)
lx004000A0: addi $t0, $s0, -16
lx004000A4: sw $t1, 0($t0)
lx004000A8: addi $s1, $s1, 4
lx004000AC: add $t0, $s0, $zero
lx004000B0: addi $s1, $s1, -4
lx004000B4: lw $t1, -16($t0)
lx004000B8: sw $t1, 0($s1)
lx004000BC: lw $t1, 0($s1)
lx004000C0: srl $t1, $t1, 29
lx004000C4: addi $t2, $zero, 4
lx004000C8: beq $t1, $t2, lx004000D0 # -> Code+0xD0
lx004000CC: j lx00400148 # -> Code+0x148
lx004000D0: lw $t1, 0($s1)
lx004000D4: lui $s7, 0x1fff
lx004000D8: ori $t2, $s7, 0xffff
lx004000DC: and $t1, $t1, $t2
lx004000E0: sw $t1, 0($s1)
lx004000E4: sw $ra, -4($s1)
lx004000E8: addi $s1, $s1, -4
lx004000EC: addi $s1, $s1, -4
lx004000F0: sw $t0, 0($s1)
lx004000F4: addi $s1, $s1, -4
lx004000F8: sw $t1, 0($s1)
lx004000FC: addi $s1, $s1, -4
lx00400100: sw $zero, 0($s1)
lx00400104: addi $s1, $s1, 12
lx00400108: lw $t2, 4($s1)
lx0040010C: lw $t1, 0($s1)
lx00400110: sw $t1, 4($s1)
lx00400114: sw $s0, 0($s1)
lx00400118: add $s0, $s1, $zero
lx0040011C: addi $s1, $s1, -12
lx00400120: jal lx00400004 # -> Code+0x4
lx00400124: addi $ra, $t1, 8
lx00400128: jr $t2
lx0040012C: addi $s1, $s1, 8
lx00400130: lw $ra, -4($s1)
lx00400134: addi $a0, $zero, 10
lx00400138: addi $v0, $zero, 11
lx0040013C: syscall
lx00400140: addi $v0, $zero, 10
lx00400144: syscall
lx00400148: addi $v0, $zero, 11
lx0040014C: addi $a0, $zero, 69
lx00400150: syscall
lx00400154: addi $a0, $zero, 82
lx00400158: syscall
lx0040015C: addi $a0, $zero, 82
lx00400160: syscall
lx00400164: addi $a0, $zero, 79
lx00400168: syscall
lx0040016C: addi $a0, $zero, 82
lx00400170: syscall
lx00400174: addi $a0, $zero, 10
lx00400178: syscall
lx0040017C: addi $v0, $zero, 10
lx00400180: syscall
