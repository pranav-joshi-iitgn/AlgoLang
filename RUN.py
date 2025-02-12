import argparse
import SYNTAX
SYNTAX.DEBUG_WITH_COLOR = True
SYNTAX.TESTING = False
from SYNTAX import *
parser = argparse.ArgumentParser()
parser.add_argument("file")
args = parser.parse_args()
file = args.file
s = open(file).read()
print("_"*50 + "\n")
print("Program")
print("_"*50 + "\n")
if DEBUG_WITH_COLOR:print(HighLight(s))
else:print(TokensToStr(lex(s,True,True),color =False))
print("_"*50 + "\n")
s = lex(s)
s0 = S0()
res = s0.parse(s)
if isinstance(res,ValueError):
    if DEBUG_WITH_COLOR:print("\x1b[38;2;255;0;0mCompilation Error\x1b[0m")
    else:print("Compilation Error")
    print("_"*50 + "\n")
    PrintError(res)
else:
    try:
        if DEBUG_WITH_COLOR:print("\x1b[38;2;0;0;255mOutput\x1b[0m")
        else:print("Output")
        print("_"*50 + "\n")
        s0.eval()
    except ValueError as e:
        if DEBUG_WITH_COLOR:print("\x1b[38;2;255;0;0mRuntime Error\x1b[0m")
        else:print("Runtime Error")
        print("_"*50 + "\n")
        PrintError(e)
    print("\n\n" + "_"*50 + "\n")