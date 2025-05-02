# get argument
import sys
file = sys.argv[1]
# read file
assert file.endswith(".rc.s") or file.endswith(".rc.s.txt"), "File must end with RC.s or RC.s.txt"
f = open(file, "r")
s = f.read()
f.close()
s = s.replace("0x004","lx004")
s = s.replace("$at","$s7")
s = "main:\n" + s
f = open(file, "w")
f.write(s)
f.close()