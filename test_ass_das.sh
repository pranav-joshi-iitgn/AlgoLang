#!/bin/bash

# Usage: ./check_all.sh path/to/folder

FOLDER="$1"
if [ -z "$FOLDER" ]; then
    echo "Usage: $0 path/to/folder"
    exit 1
fi

# Compile DAS.c
gcc DAS.c -o DAS -lm -std=c99 -Wall
if [ $? -ne 0 ]; then
    echo "Compilation of DAS.c failed. Exiting."
    exit 1
fi


# Compile EXE.c
gcc EXE.c -o EXE -lm -std=c99 -Wall
if [ $? -ne 0 ]; then
    echo "Compilation of EXE.c failed. Exiting."
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

for alglfile in "$FOLDER"/*.algl; do
    base="${alglfile%.algl}"
    sfile="$base.s"
    hexfile="$base.hex"
    rc_sfile="$base.rc.s"
    cleaned_rc_sfile="$base.rc.s" # Assuming clean.py overwrites the file
    s_outfile="$base.s.out"
    rc_s_outfile="$base.rc.s.out"
    ass_output="$base.ass.out"
    das_output="$base.das.out"
    exe_outout="$base.vm.out"

    printf "Processing $alglfile..."

    # Step 1: Generate .s file
    python3 COM.py "$alglfile" > /dev/null
    if [ $? -ne 0 ]; then
        echo -e "${RED}FAIL${NC} (COM.py failed)"
        continue
    fi

    # Step 2: Assemble to .hex
    python3 ASS.py "$sfile" > "$ass_output"
    if [ $? -ne 0 ]; then
        echo -e "${RED}FAIL${NC} (ASS.py failed)"
        continue
    fi

    # Step 3: Disassemble to reconstructed .s
    ./DAS "$hexfile" "$rc_sfile" > "$das_output"
    if [ $? -ne 0 ]; then
        echo -e "${RED}FAIL${NC} (DAS failed)"
        continue
    fi

    # Step 4: Clean reconstructed .s
    python3 clean.py "$rc_sfile"
    if [ $? -ne 0 ]; then
        echo -e "${RED}FAIL${NC} (clean.py failed)"
        continue
    fi

    # Step 5: Run original .s with SPIM
    spim -st 33554431 -ss 1577058305 -f "$sfile" > "$s_outfile"
    if [ $? -ne 0 ]; then
        echo -e "${RED}FAIL${NC} (SPIM on original .s failed)"
        continue
    fi

    # Step 6: Run reconstructed .s with SPIM
    spim -st 33554431 -ss 1577058305 -f "$rc_sfile" > "$rc_s_outfile"
    if [ $? -ne 0 ]; then
        echo -e "${RED}FAIL${NC} (SPIM on .rc.s failed)"
        continue
    fi

    # Step 7: Compare outputs
    if diff -q "$s_outfile" "$rc_s_outfile" >/dev/null; then
        : # echo -e "$base.rc.s : ${GREEN}PASSED${NC}"
    else
        echo -e "${RED}FAIL${NC} (unequal SPIM outputs)"
        continue
    fi

    # Step 8: Execution
    ./EXE "$hexfile" > "$exe_outout"
    if [ $? -ne 0 ]; then
        echo -e "${RED}FAIL${NC} (Exection of hex codes failed)"
        continue
    fi;

    echo -e "${GREEN}PASSED${NC}"
done
