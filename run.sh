#!/bin/bash


# This is a terminal utility that compiles a given AlgoLang file
# to MIPS32 instructions (centered around the SPIM simulator).
# and then executes the .s file using SPIM
# 
# AUTHOR: Pranav Joshi
# email : pranav.joshi@iitgn.ac.in
# Roll  : 22110197



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

# Determine the output .s file name using the same logic as COM.py
if [[ "$input_file" == *.txt ]]; then
    output_file="${input_file%.txt}.s"
elif [[ "$input_file" == *.algl ]]; then
    output_file="${input_file%.algl}.s"
else
    output_file="${input_file}.s"
fi

# Check if compilation was successful
if [ ! -f "$output_file" ]; then
    echo "Compilation failed: $output_file not found"
    exit 1
fi

# Run the compiled file using SPIM
echo "Running $output_file..."
spim -st 33554431 -ss 1577058305 -f "$output_file" | tail -n +6