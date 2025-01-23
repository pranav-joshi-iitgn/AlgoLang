from SYNTAX import *
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("file")
args = parser.parse_args()
file = args.file
s = open(file).read()
print("Program:")
print("-"*50)
print(HighLight(s))
print("-"*50)
s = lex(s)
s0 = S0()
s0.parse(s)
print("Output:")
print("-"*50)
s0.eval()
print("\n\n" + "-"*50)
print("Program Finished")