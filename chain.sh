if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file="$1"

# Compile the file using COM.py and capture its output
compilation_output=$(python3 COM.py "$input_file")

# Check if compilation was successful based on COM.py's output
if [[ "$compilation_output" != "compiled" ]]; then
    echo "Compilation failed"
    exit 1
fi

# Determine the base file name using the same logic as COM.py
if [[ "$input_file" == *.txt ]]; then
    base="${input_file%.txt}"
elif [[ "$input_file" == *.algl ]]; then
    base="${input_file%.algl}"
else
    base="${input_file}"
fi

sfile="${base}.s"
hexfile="${base}.hex"

# Check if compilation was successful
if [ ! -f "$sfile" ]; then
    echo "Compilation failed: $sfile not found"
    exit 1
fi

# Assemble the sfile

assembler_output=$(python3 ASS.py "$sfile" > /dev/null)

# Check if assembler was successful based on output
if [[ "$assembler_output" != "" ]]; then
    echo "Assembling failed"
    exit 1
fi

# Check if assembling was successful
if [ ! -f "$hexfile" ]; then
    echo "Assembler failed: $hexfile not found"
    exit 1
fi

# Compile latest version of EXE.c
gcc EXE.c -o EXE -lm -std=c99 -Wall
if [ $? -ne 0 ]; then
    echo "Compilation of EXE.c failed. Exiting."
    exit 1
fi

# Run
./EXE "$hexfile"