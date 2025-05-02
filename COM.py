"""
This is a terminal utility that compiles a given AlgoLang file
to MIPS32 instructions (catered to SPIM simulator by default).

AUTHOR: Pranav Joshi
email : pranav.joshi@iitgn.ac.in
Roll  : 22110197
"""

import argparse
import SYNTAX
SYNTAX.DEBUG_WITH_COLOR = True
SYNTAX.TESTING = False
from SYNTAX import *
parser = argparse.ArgumentParser()
parser.add_argument("file")
parser.add_argument("--format",default="VM")
parser.add_argument("--output",default="")
args = parser.parse_args()
file = args.file
Format = args.format
out = args.output
if out:asfile = out
elif file[-4:]==".txt":asfile = file[:-4] + ".s"
elif file[-5:]==".algl":asfile = file[:-5] + ".s"
else: asfile = file + ".s"
FileToMIPS(file,asfile,Format)
print("compiled")