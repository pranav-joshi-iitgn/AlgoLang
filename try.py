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
    "",
    "pathfinder:",
    "add $t1,$ra,$zero",
    "jr $ra",
    "",
    "_start:",
    "li $s0,0x40000000", # make some space
    "li $s5,0x40000004", # This is our heap pointer
    "",
    mips_code,
    "",
    "# Exit",
    "addi $v0,$zero,10",
    "syscall",
    #This is the call to exit in this simulator : https://cpulator.01xz.net/?sys=mipsr5-spim
])
f = open("try.s",'w')
f.write(mips_code)
f.close
#print(mips_code)