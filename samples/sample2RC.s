main:
lx00400000: j lx0040000C # -> Code+0xC
lx00400004: add $t1, $ra, $zero
lx00400008: jr $ra
lx0040000C: lui $s7, 0x6000
lx00400010: ori $sp, $s7, 0x0
lx00400014: addi $s0, $sp, 0
lx00400018: addi $s5, $sp, 4
lx0040001C: addi $s1, $s0, -20
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
lx00400060: j lx00400154 # -> Code+0x154
lx00400064: addi $t8, $zero, 1
lx00400068: addi $t9, $zero, 1
lx0040006C: addi $s1, $s0, -20
lx00400070: add $t0, $s0, $zero
lx00400074: addi $s1, $s1, -4
lx00400078: lw $t1, -20($t0)
lx0040007C: sw $t1, 0($s1)
lx00400080: lw $t0, 0($s1)
lx00400084: srl $t1, $t0, 29
lx00400088: addi $t3, $zero, 7
lx0040008C: addi $t4, $zero, 4
lx00400090: beq $t1, $zero, lx00400124 # -> Code+0x124
lx00400094: beq $t1, $t3, lx00400124 # -> Code+0x124
lx00400098: beq $t1, $t4, lx004000D8 # -> Code+0xD8
lx0040009C: addi $t3, $zero, 3
lx004000A0: bne $t1, $t3, lx004000C8 # -> Code+0xC8
lx004000A4: lw $t1, 0($t0)
lx004000A8: addi $v0, $zero, 11
lx004000AC: slt $t3, $zero, $t1
lx004000B0: beq $t3, $zero, lx00400130 # -> Code+0x130
lx004000B4: addi $t0, $t0, 4
lx004000B8: lw $a0, 0($t0)
lx004000BC: syscall
lx004000C0: addi $t1, $t1, -4
lx004000C4: j lx004000AC # -> Code+0xAC
lx004000C8: addi $v0, $zero, 2
lx004000CC: mtc1 $t0, $f12
lx004000D0: syscall
lx004000D4: j lx00400130 # -> Code+0x130
lx004000D8: addi $v0, $zero, 11
lx004000DC: addi $a0, $zero, 97
lx004000E0: syscall
lx004000E4: addi $a0, $zero, 108
lx004000E8: syscall
lx004000EC: addi $a0, $zero, 103
lx004000F0: syscall
lx004000F4: addi $a0, $zero, 32
lx004000F8: syscall
lx004000FC: addi $a0, $zero, 97
lx00400100: syscall
lx00400104: addi $a0, $zero, 116
lx00400108: syscall
lx0040010C: addi $a0, $zero, 32
lx00400110: syscall
lx00400114: addi $v0, $zero, 1
lx00400118: add $a0, $t0, $zero
lx0040011C: syscall
lx00400120: j lx00400130 # -> Code+0x130
lx00400124: addi $v0, $zero, 1
lx00400128: add $a0, $t0, $zero
lx0040012C: syscall
lx00400130: addi $s1, $s1, 4
lx00400134: addi $a0, $zero, 10
lx00400138: addi $v0, $zero, 11
lx0040013C: syscall
lx00400140: lw $t0, 0($s0)
lx00400144: addi $t9, $zero, 0
lx00400148: add $s1, $s0, $zero
lx0040014C: add $s0, $zero, $t0
lx00400150: jr $ra
lx00400154: lw $t2, -8($s0)
lx00400158: lui $s7, 0x7f00
lx0040015C: ori $t5, $s7, 0x0
lx00400160: lui $s7, 0x1fff
lx00400164: ori $t6, $s7, 0xffff
lx00400168: and $t1, $t1, $t6
lx0040016C: or $t1, $t1, $t5
lx00400170: sw $t2, 0($t1)
lx00400174: sw $zero, 4($t1)
lx00400178: lw $t1, 0($s1)
lx0040017C: addi $t0, $s0, -16
lx00400180: sw $t1, 0($t0)
lx00400184: addi $s1, $s1, 4
lx00400188: addi $s1, $s1, -4
lx0040018C: addi $t1, $zero, 1
lx00400190: sw $t1, 0($s1)
lx00400194: lw $t1, 0($s1)
lx00400198: addi $t0, $s0, -20
lx0040019C: sw $t1, 0($t0)
lx004001A0: addi $s1, $s1, 4
lx004001A4: add $t0, $s0, $zero
lx004001A8: addi $s1, $s1, -4
lx004001AC: lw $t1, -16($t0)
lx004001B0: sw $t1, 0($s1)
lx004001B4: lw $t1, 0($s1)
lx004001B8: srl $t1, $t1, 29
lx004001BC: addi $t2, $zero, 4
lx004001C0: beq $t1, $t2, lx004001C8 # -> Code+0x1C8
lx004001C4: j lx00400278 # -> Code+0x278
lx004001C8: lw $t1, 0($s1)
lx004001CC: lui $s7, 0x1fff
lx004001D0: ori $t2, $s7, 0xffff
lx004001D4: and $t1, $t1, $t2
lx004001D8: sw $t1, 0($s1)
lx004001DC: sw $ra, -4($s1)
lx004001E0: addi $s1, $s1, -4
lx004001E4: addi $s1, $s1, -4
lx004001E8: sw $t0, 0($s1)
lx004001EC: addi $s1, $s1, -4
lx004001F0: sw $t1, 0($s1)
lx004001F4: addi $s1, $s1, -4
lx004001F8: sw $zero, 0($s1)
lx004001FC: add $t0, $s0, $zero
lx00400200: addi $s1, $s1, -4
lx00400204: lw $t1, -20($t0)
lx00400208: sw $t1, 0($s1)
lx0040020C: add $t0, $s5, $zero
lx00400210: addi $s5, $s5, 12
lx00400214: addi $t1, $zero, 8
lx00400218: sw $t1, 0($t0)
lx0040021C: addi $t1, $zero, 97
lx00400220: sw $t1, 4($t0)
lx00400224: addi $t1, $zero, 98
lx00400228: sw $t1, 8($t0)
lx0040022C: addi $s1, $s1, -4
lx00400230: sw $t0, 0($s1)
lx00400234: addi $s1, $s1, 20
lx00400238: lw $t2, 4($s1)
lx0040023C: lw $t1, 0($s1)
lx00400240: sw $t1, 4($s1)
lx00400244: sw $s0, 0($s1)
lx00400248: add $s0, $s1, $zero
lx0040024C: addi $s1, $s1, -20
lx00400250: jal lx00400004 # -> Code+0x4
lx00400254: addi $ra, $t1, 8
lx00400258: jr $t2
lx0040025C: addi $s1, $s1, 8
lx00400260: lw $ra, -4($s1)
lx00400264: addi $a0, $zero, 10
lx00400268: addi $v0, $zero, 11
lx0040026C: syscall
lx00400270: addi $v0, $zero, 10
lx00400274: syscall
lx00400278: addi $v0, $zero, 11
lx0040027C: addi $a0, $zero, 69
lx00400280: syscall
lx00400284: addi $a0, $zero, 82
lx00400288: syscall
lx0040028C: addi $a0, $zero, 82
lx00400290: syscall
lx00400294: addi $a0, $zero, 79
lx00400298: syscall
lx0040029C: addi $a0, $zero, 82
lx004002A0: syscall
lx004002A4: addi $a0, $zero, 10
lx004002A8: syscall
lx004002AC: addi $v0, $zero, 10
lx004002B0: syscall
