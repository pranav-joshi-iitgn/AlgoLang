from SYNTAX import *
import matplotlib.pyplot as plt

f = open("try.txt",'r')
input_string = f.read()
f.close()

set_defaults({})
set_symbolstack([{}])
s = lex(input_string)
e0 = Statements()
e0.parse(s)
#e0.PlotTree()
#Graph.render("try",format='png',view=False)
#I = plt.imread("try.png")
#plt.imshow(I)
#plt.xticks([])
#plt.yticks([])
#plt.title(input_string)
#plt.show()
mips_code = e0.MIPS()
mips_code = "\n".join([
    ".global _start",
    "_start:",
    "",
    mips_code,
    "",
    "syscall 10", #This is the call to exit in this simulator : https://cpulator.01xz.net/?sys=mipsr5-spim
])
f = open("try.s",'w')
f.write(mips_code)
f.close
#print(mips_code)