| Instruction        | Format Type    | Opcode (Hex) | Fields                                     | Funct/Fmt/COP (Hex) | Notes                                                                              |
| :----------------- | :------------- | :----------- | :----------------------------------------- | :------------------ | :--------------------------------------------------------------------------------- |
| **Base R-Type** |                |              | op(6) rs(5) rt(5) rd(5) shamt(5) funct(6)  |                     |                                                                                    |
| `sll` | R_sh           | `0x00`       | op(6) 0(5) rt(5) rd(5) shamt(5) funct(6)   | `funct=0x00`        |                                                                    |
| `srl` | R_sh           | `0x00`       | op(6) 0(5) rt(5) rd(5) shamt(5) funct(6)   | `funct=0x02`        |                                                                    |
| `sllv` | R              | `0x00`       | op(6) rs(5) rt(5) rd(5) shamt(5) funct(6)  | `funct=0x04`        |                                                                    |
| `srlv` | R              | `0x00`       | op(6) rs(5) rt(5) rd(5) shamt(5) funct(6)  | `funct=0x06`        |                                                                    |
| `jr` | R_jr           | `0x00`       | op(6) rs(5) 0(5) 0(5) 0(5) funct(6)        | `funct=0x08`        |                                                                    |
| `syscall` | R_syscall      | `0x00`       | op(6) code(20) funct(6)                    | `funct=0x0C`        |                                                                    |
| `mfhi` | R_mf           | `0x00`       | op(6) 0(5) 0(5) rd(5) 0(5) funct(6)        | `funct=0x10`        |                                                                    |
| `mflo` | R_mf           | `0x00`       | op(6) 0(5) 0(5) rd(5) 0(5) funct(6)        | `funct=0x12`        |                                                                    |
| `mult` | R_m            | `0x00`       | op(6) rs(5) rt(5) 0(5) 0(5) funct(6)       | `funct=0x18`        |                                                                    |
| `add` | R              | `0x00`       | op(6) rs(5) rt(5) rd(5) shamt(5) funct(6)  | `funct=0x20`        |                                                                    |
| `sub` | R              | `0x00`       | op(6) rs(5) rt(5) rd(5) shamt(5) funct(6)  | `funct=0x22`        |                                                                    |
| `and` | R              | `0x00`       | op(6) rs(5) rt(5) rd(5) shamt(5) funct(6)  | `funct=0x24`        |                                                                    |
| `or` | R              | `0x00`       | op(6) rs(5) rt(5) rd(5) shamt(5) funct(6)  | `funct=0x25`        |                                                                    |
| `nor` | R              | `0x00`       | op(6) rs(5) rt(5) rd(5) shamt(5) funct(6)  | `funct=0x27`        |                                                                    |
| `slt` | R              | `0x00`       | op(6) rs(5) rt(5) rd(5) shamt(5) funct(6)  | `funct=0x2A`        |                                                                    |
| **...**          | ...            | ...          | ...                                        | ...                 | ...                                                                                |
| **Base J-Type** |                |              | op(6) target_address(26)                   |                     |                                                                                    |
| `j` | J              | `0x02`       | op(6) target_address(26)                   | N/A                 | target is word address * 4 (shifted)                               |
| `jal` | J              | `0x03`       | op(6) target_address(26)                   | N/A                 | target is word address * 4 (shifted), `$ra = PC + 8`               |
| **...**          | ...            | ...          | ...                                        | ...                 | ...                                                                                |
| **Base I-Type** |                |              | op(6) rs(5) rt(5) immediate(16)            |                     |                                                                                    |
| `beq` | I_branch       | `0x04`       | op(6) rs(5) rt(5) offset(16)               | N/A                 | imm sign-extended, offset PC-relative, word-scaled                 |
| `bne` | I_branch       | `0x05`       | op(6) rs(5) rt(5) offset(16)               | N/A                 | imm sign-extended, offset PC-relative, word-scaled                 |
| `addi` | I              | `0x08`       | op(6) rs(5) rt(5) immediate(16)            | N/A                 | imm sign-extended                                                  |
| `andi` | I              | `0x0C`       | op(6) rs(5) rt(5) immediate(16)            | N/A                 | imm zero-extended                                                  |
| `ori` | I              | `0x0D`       | op(6) rs(5) rt(5) immediate(16)            | N/A                 | imm zero-extended                                                  |
| `xori` | I              | `0x0E`       | op(6) rs(5) rt(5) immediate(16)            | N/A                 | imm zero-extended                                                  |
| `lui` | I_lui          | `0x0F`       | op(6) 0(5) rt(5) imm(16)                   | N/A                 | imm zero-extended, `rs = $zero`                                    |
| **...**          | ...            | ...          | ...                                        | ...                 | ...                                                                                |
| **COP1 (FPU)** |                |              | Unknown Format                             |                     |                                                                                    |
| `add.s` | COP1_R         | `0x11`       | op(6) fmt(5) ft(FPR)(5) fs(FPR)(5) fd(FPR)(5) funct(6) | `fmt=0x10, funct=0x00` | Uses FPRs                                                          |
| `mfc1` | COP1_M         | `0x11`       | op(6) fmt(5) rt(GPR)(5) rd(FPR)(5) 0(11)   | `fmt=0x00`          | Uses FPRs                                                          |
| `sub.s` | COP1_R         | `0x11`       | op(6) fmt(5) ft(FPR)(5) fs(FPR)(5) fd(FPR)(5) funct(6) | `fmt=0x10, funct=0x01` | Uses FPRs                                                          |
| `mul.s` | COP1_R         | `0x11`       | op(6) fmt(5) ft(FPR)(5) fs(FPR)(5) fd(FPR)(5) funct(6) | `fmt=0x10, funct=0x02` | Uses FPRs                                                          |
| `div.s` | COP1_R         | `0x11`       | op(6) fmt(5) ft(FPR)(5) fs(FPR)(5) fd(FPR)(5) funct(6) | `fmt=0x10, funct=0x03` | Uses FPRs                                                          |
| `mtc1` | COP1_M         | `0x11`       | op(6) fmt(5) rt(GPR)(5) rd(FPR)(5) 0(11)   | `fmt=0x04`          | Uses FPRs                                                          |
| `mov.s` | COP1_R_MOV     | `0x11`       | op(6) fmt(5) 0(5) fs(FPR)(5) fd(FPR)(5) funct(6) | `fmt=0x10, funct=0x06` | Uses FPRs                                                          |
| `cvt.s.w` | COP1_R_CVT     | `0x11`       | op(6) fmt(src)(5) 0(5) fs(FPR)(5) fd(FPR)(5) funct(6) | `fmt=0x14, funct=0x20` | Uses FPRs                                                          |
| `cvt.w.s` | COP1_R_CVT     | `0x11`       | op(6) fmt(src)(5) 0(5) fs(FPR)(5) fd(FPR)(5) funct(6) | `fmt=0x10, funct=0x24` | Uses FPRs                                                          |
| **...**          | ...            | ...          | ...                                        | ...                 | ...                                                                                |
| **COP2 (Quantum)** |                |              | Unknown Format                             |                     |                                                                                    |
| `H` | COP2_Q_RD      | `0x12`       | op(6) rs=1(5) rt=0(5) rd(Qubit)(5) shamt=0(5) funct(6) | `funct=0x00`        | Uses Qubit Regs (GPR index)                                        |
| `X` | COP2_Q_RD      | `0x12`       | op(6) rs=1(5) rt=0(5) rd(Qubit)(5) shamt=0(5) funct(6) | `funct=0x01`        | Uses Qubit Regs (GPR index)                                        |
| `CNOT` | COP2_Q_RD_RS   | `0x12`       | op(6) rs(Ctrl)(5) rt=0(5) rd(Tgt)(5) shamt=0(5) funct(6) | `funct=0x02`        | Uses Qubit Regs (GPR index)                                        |
| `measure` | COP2_Q_RD      | `0x12`       | op(6) rs=1(5) rt=0(5) rd(Qubit)(5) shamt=0(5) funct(6) | `funct=0x03`        | Uses Qubit Regs (GPR index), Result -> `$s9`?                      |
| `reset` | COP2_Q_RD      | `0x12`       | op(6) rs=1(5) rt=0(5) rd(Qubit)(5) shamt=0(5) funct(6) | `funct=0x04`        | Uses Qubit Regs (GPR index)                                        |
| **...**          | ...            | ...          | ...                                        | ...                 | ...                                                                                |
| **Base I-Type** |                |              | op(6) rs(5) rt(5) immediate(16)            |                     |                                                                                    |
| `lb` | I_mem          | `0x20`       | op(6) rs(base)(5) rt(data)(5) offset(16)   | N/A                 | imm sign-extended                                                  |
| `lw` | I_mem          | `0x23`       | op(6) rs(base)(5) rt(data)(5) offset(16)   | N/A                 | imm sign-extended                                                  |
| `sb` | I_mem          | `0x28`       | op(6) rs(base)(5) rt(data)(5) offset(16)   | N/A                 | imm sign-extended                                                  |
| `sw` | I_mem          | `0x2B`       | op(6) rs(base)(5) rt(data)(5) offset(16)   | N/A                 | imm sign-extended                                                  |
| **...**          | ...            | ...          | ...                                        | ...                 | ...                                                                                |
| **COP1 (FPU)** |                |              | Unknown Format                             |                     |                                                                                    |
| `l.s` | COP1_LS        | `0x31`       | op(6) rs(GPR)(5) ft(FPR)(5) offset(16)     | N/A                 | Uses FPRs                                                          |
| `s.s` | COP1_LS        | `0x39`       | op(6) rs(GPR)(5) ft(FPR)(5) offset(16)     | N/A                 | Uses FPRs                                                          |
| **...**          | ...            | ...          | ...                                        | ...                 | ...                                                                                |
| **Pseudo Instr** |                |              | (N/A - Expanded by Assembler)              |                     |                                                                                    |
| `li`             | Pseudo         | N/A          | Expands to `addi` or (`lui` + `ori`)       | N/A                 | Load Immediate                                                                     |
| `la`             | Pseudo         | N/A          | Expands to `lui` + `ori`                   | N/A                 | Load Address                                                                       |
| `move`           | Pseudo         | N/A          | Expands to `add rd, rs, $zero`             | N/A                 | Copy Register                                                                      |
| `sgt`            | Pseudo         | N/A          | Expands to `slt rd, rt, rs`                | N/A                 | Set if Greater Than                                                              |
