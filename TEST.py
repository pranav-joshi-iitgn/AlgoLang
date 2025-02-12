import SYNTAX
SYNTAX.TESTING = True
SYNTAX.DEBUG_WITH_COLOR = True
from SYNTAX import *
for i in range(1,10):
    filename = f"sample{i}.txt"
    try:file = open(filename,'r')
    except:
        print(filename,"not found in this directory")
        continue
    try:s = file.read()
    except:
        print("couldn't read from",filename)
        continue
    try:s = lex(s)
    except:
        print("lexing failed on",filename)
        continue
    s0 = Statements()
    try:res = s0.parse(s)
    except:
        print(filename,"crashed before giving a respnese")
        continue
    if isinstance(res,ValueError):
        print("compilation error in",filename)
        continue
    try:s0.eval()
    except:
        print("Run-time error in",filename)
        continue
    print(filename,"ran")