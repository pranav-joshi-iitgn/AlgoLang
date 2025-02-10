from LEXER import *
from graphviz import Digraph
from ast import literal_eval
import termplotlib as plt
from numpy import *
"""
BODMAS
The grammar for this language is ..
S0 -> S1 S0 | W S0 | I S0 | ""
W -> while CS0 F
I -> if CS0 F
S1 -> P; | A; | R; | D;
P -> print CS0
R -> run id | run CS0 with CSV
Ret -> return CS0
A -> V = CS0 | V = F
F -> { S0 }

CS0 -> CS1 or CS0 | CS1
CS1 -> CS2 and CS1 | CS2
CS2 -> not C0

C0 -> C1 == C0 | C1
C1 -> C2 > C1 | C2
C2 -> C3 < C2 | C3
C3 -> C4 >= C3 | C4
C4 -> C5 <= C4 | C5
C5 -> E0 != C5 | E0

E0 -> E2 - E0 | E2 + E1 | E2
E2 -> E3 * E2 | E3
E3 -> E3 / E4 | E4
E4 -> E4 ** E5 | E5
E5 -> E5 // E6 | E6
E6 -> E6 % E7 | E7
E7 -> - E8 | E8
E8 -> (CS0) | E9
E9 -> int | float | str | V | Al
V -> id [ E0 ] | id
Al -> alg (CSV) F | alg F
CSV -> id,CSV | id

"""
Graph = Digraph("AST")
cur_node = 0

def to_tuple(L):
    if isinstance(L,list) or isinstance(L,tuple):
        return tuple(x for x in L)
    else:return L

class Node:
    name = "Node"
    def __init__(self):
        self.children = []
        self.value = None
    def __repr__(self):
        return self.name + "->" + " ".join([x.name for x in self.children])
    def MakeTree(self):
        s = [str(self)]
        for child in self.children:
            s.extend(child.MakeTree())
        return s
    def PlotTree(self):
        global Graph,cur_node
        self.id = str(cur_node)
        if len(self.children) > 1 or len(self.children) == 0:
            Graph.node(self.id,self.name)
            cur_node += 1
            for child in self.children:
                cid = child.PlotTree()
                Graph.edge(self.id,cid)
            return self.id
        if len(self.children) == 1:
            child = self.children[0]
            cid = child.PlotTree()
            return cid

class Token:
    def __init__(self,value):
        self.value = value
        self.name = value
    def __repr__(self):
        return self.value
    def MakeTree(self):
            return [self.value]

    def PlotTree(self):
        global Graph,cur_node
        self.id = str(cur_node)
        Graph.node(self.id,self.value)
        cur_node += 1
        return self.id

class Number(Token):
    name = "Number"
    def eval(self):return complex(self.value)

class Int(Number):
    name = "int"
    Type = int
    def eval(self):return int(self.value)

class Float(Number):
    name = "float"
    Type = float
    def eval(self):return float(self.value)

class Str(Token):
    name = "str"
    Type = str
    def __init__(self,value):
        assert value[0] == '"'
        assert value[-1] == '"'
        self.value = literal_eval(value)
        self.name = self.value
    def eval(self):
        return self.value

class Id(Token):
    name = "id"
    def __init__(self,value):
        self.value = value
        self.name = value
    def eval(self):
        x = self.value
        for i in range(len(SYMBOLSTACK)-1,-1,-1):
            SYMBOLS = SYMBOLSTACK[i]
            if x in SYMBOLS:return SYMBOLS[x]
        print(x,"is not defined")
        raise ValueError("undefined variable")

class F(Node):
    name = "F"
    args = ()
    env = {}
    def parse(self,s:list):
        self.value = s
        n = len(s)
        assert n >= 2
        assert s[0][1] == "{"
        assert s[-1][1] == "}"
        body = S0()
        body.parse(s[1:-1])
        self.children = [Token("{"),body,Token("}")]
    def eval(self,argvals=[]):
        if len(argvals) > len(self.args):raise ValueError("Too many values in function call")
        SYMBOLS = SYMBOLSTACK[-1]
        for k in self.env:
            SYMBOLS[k] = self.env[k]
        for i in range(len(argvals)):
            SYMBOLS[self.args[i]] = argvals[i]
        body = self.children[1]
        return body.eval()
    def __add__(self,other):
        par = F()
        env1 = self.env
        env2 = other.env
        env = {k:env1[k] for k in env1}
        for k in env2:
            if (k in env) and (env[k] is not env2[k]) and (env[k] != env2[k]):
                raise ValueError("environments did not match for concatenation of algorithms")
            else: env[k] = env2[k]
        args = list(self.args)
        args2 = list(other.args)
        for x in args2:
            if x not in args:args.append(x)
        par.args = args
        par.env = env
        body =S0()
        body.children = [self.children[1],other.children[1]]
        par.children = [Token("{"),body,Token("}")]
        return par
    def __mul__(self,other:int):
        to_ret = self
        for i in range(other-1):
            to_ret = to_ret + self
        return to_ret
    def prepr(self):
        s = "".join([x[1] + ("\n" if x[1] in r";{}" else " ") for x in self.value])
        s = s.split("\n")
        if len(s) > 10: s = s[:5] + ["..."] + s[-5:]
        s = "\n | ".join(s)
        s = " | alg ( " + " , ".join(self.args) + " ) " + s
        env = [f" {k} = {str(to_tuple(self.env[k]))}" for k in self.env] + [""]
        env = "\n |".join(env)
        if len(env) : s += "\n | where\n |" + env
        max_width = max([len(x) for x in s.split("\n")])
        s = "\n".join([x + " "*(max_width+2-len(x)) + "|" for x in s.split("\n")])
        s = "  " + "_"*max_width + "\n |" + " "*max_width + "|\n" + s + "\n |" + "_"*max_width + "|\n\n"
        return s
    def __str__(self):
        s = "".join([x[1] + ("\n" if x[1] in r";{}" else " ") for x in self.value])
        s = s.split("\n")
        if len(s) > 10: s = s[:5] + ["..."] + s[-5:]
        s = "\n".join(s)
        s = "alg(" + ",".join(self.args) + ")" + s
        env = [f"{k} is {str(to_tuple(self.env[k]))}" for k in self.env]
        env = "\n".join(env)
        if len(env) : s += "where\n" + env
        return s + "\n"

def SymbolsNeeded(node):
    if isinstance(node,Id):return {node.name}
    elif isinstance(node,Token):return set()
    need = set()
    for child in node.children:
        need = need.union(SymbolsNeeded(child))
    return need

class UnOp(Node):
    name = "E?"
    other = None
    opname = "op"
    op = None
    def parse(self,s:list):
        self.value = s
        n = len(s)
        if s[0][1] == self.opname:
            left = Token(self.opname)
            right = self.other()
            right.parse(s[1:])
            self.children = [left,right]
        else:
            child = self.other()
            child.parse(s)
            self.children = [child]
    def eval(self):
        L = self.children
        n = len(L)
        assert n > 0
        if n == 1:
            child = self.children[0]
            return child.eval()
        elif n == 2:
            right = self.children[1]
            right = right.eval()
            return self.op(right)
        else: raise ValueError("This isn't good")

class Lis(UnOp):
    name = "Lis"
    opname = "list"
    def other(self):return CS0()
    def op(self,x):
        if isinstance(x,int):return [None]*x
        if isinstance(x,list):return x
        if isinstance(x,ndarray):return list(x)

class Vec(UnOp):
    name = "Vec"
    opname = "vec"
    def other(self):return CS0()
    def op(self,x):
        if x is None: raise ValueError("give the size of the array please")
        if isinstance(x,int):return zeros(x)
        if isinstance(x,list):return array(x)
        if isinstance(x,ndarray):
            x = tuple(x.astype("i"))
            size = prod(x)
            if size >1e6:raise ValueError(f"Cannot allocate memory for vector of shape {x}")
            return zeros(x)

class Neg(UnOp):
    name = "Neg"
    opname = "-"
    def other(self):return CS0()
    def op(self,x):return [None]*x

class BinOp(Node):
    name = "E?"
    other = None
    opname = "op"
    op = None
    left_associative = True
    def parse(self,s:list):
        self.value = s
        good =  False
        for i in range(len(s)):
            if s[i][1] == self.opname:
                try:
                    if self.left_associative:
                        Left = self.duplicate()
                        Right = self.other()
                    else:
                        Right = self.duplicate()
                        Left = self.other()
                    Left.parse(s[:i])
                    Right.parse(s[i+1:])
                    self.children = [Left,Token(self.opname),Right]
                    good = True
                    break
                except: pass
        else:
            try:
                child = self.other()
                child.parse(s)
                self.children = [child]
                good = True
            except:pass
        assert good, f"syntax error on {s}"
    def eval(self):
        L = self.children
        assert L
        if len(L) == 1:return L[0].eval()
        elif len(L) == 3:return self.op(L[0].eval(),L[2].eval())

class MultiBinOp(Node):
    name = "E?"
    other = None
    opnames = ["op"]
    op = None
    left_associative = True
    def parse(self,s:list):
        self.value = s
        good =  False
        for i in range(len(s)):
            op = s[i][1]
            if op in self.opnames:
                try:
                    if self.left_associative:
                        Left = self.duplicate()
                        Right = self.other()
                    else:
                        Right = self.duplicate()
                        Left = self.other()
                    Left.parse(s[:i])
                    Right.parse(s[i+1:])
                    self.children = [Left,Token(op),Right]
                    good = True
                    break
                except: pass
        else:
            try:
                child = self.other()
                child.parse(s)
                self.children = [child]
                good = True
            except:pass

        assert good, f"syntax error on {s}"
    def eval(self):
        L = self.children
        assert L
        if len(L) == 1:return L[0].eval()
        elif len(L) == 3:return self.op(L[0].eval(),L[2].eval(),L[1].name)

class S0(Node):
    name = "S0"
    def parse(self,s:list):
        n = len(s)
        if n == 0:self.children =[]
        elif s[0][1] in ["while","if",'elif','else']:
            for i in range(1,n):
                if s[i][1] == "}":
                    try:
                        left = s[:i+1]
                        right = s[i+1:]
                        if s[0][1] == "while":Left = W()
                        elif s[0][1] == "elif":Left = EI()
                        elif s[0][1] == "else":Left = EI1()
                        elif s[0][1] == "if":Left = I()
                        else:
                            raise ValueError("This isn't allowed")
                        Right = S0()
                        Left.parse(left)
                        Right.parse(right)
                        self.children = [Left,Right]
                        break
                    except:pass
            else:
                raise ValueError(f"syntax error in {s}")
        else:
            for i in range(n):
                if s[i][1] == ";":
                    try:
                        left = s[:i+1]
                        right = s[i+1:]
                        Left = S1()
                        Right = S0()
                        Left.parse(left)
                        Right.parse(right)
                        self.children = [Left,Right]
                        break
                    except:pass
            else:
                raise ValueError(f"syntax error in {s}")
    def eval(self):
        for child in self.children:
            x = child.eval()
            if x is not None: return x

class W(Node):
    name = "W"
    def parse(self,s:list):
        n = len(s)
        assert n > 0
        assert s[0][1] == "while"
        assert s[-1][1] == "}"
        for i in range(1,n):
            if s[i][1] == '{':
                try:
                    condition =s[1:i]
                    code = s[i:]
                    cs0 = CS0()
                    f = F()
                    cs0.parse(condition)
                    f.parse(code)
                    self.children = [Token('while'),cs0,f]
                    break
                except:pass
        else:raise ValueError(f"syntax error in {s}")
    def eval(self):
        L = self.children
        assert len(L) == 3
        #while
        condition = L[1]
        code = L[2]
        br =10**9
        SYMBOLS = SYMBOLSTACK[-1]
        SYMBOLS["LASTCONDITION"] = False
        while condition.eval() and br > 0:
            SYMBOLS["LASTCONDITION"] = True
            x = code.eval()
            if x is not None:return x
            br -= 1
        if br <= 0 : print("broken while because it took over 10^9 loops")

class I(Node):
    name = "I"
    def parse(self,s:list):
        n = len(s)
        assert n > 0
        assert s[0][1] == "if"
        assert s[-1][1] == "}"
        for i in range(1,n):
            if s[i][1] == '{':
                try:
                    condition =s[1:i]
                    code = s[i+1:-1]
                    cs0 = CS0()
                    s0 = S0()
                    cs0.parse(condition)
                    s0.parse(code)
                    self.children = [Token('if'),cs0,Token("{"),s0,Token("}")]
                    break
                except:pass
        else:raise ValueError(f"syntax error in {s}")
    def eval(self):
        L = self.children
        assert len(L) == 5
        condition = L[1]
        code = L[3]
        SYMBOLS = SYMBOLSTACK[-1]
        cond = condition.eval()
        if cond:
            SYMBOLS["LASTCONDITION"] =True
            return code.eval()
        else:
            SYMBOLS["LASTCONDITION"] =False

class EI(Node):
    name = "EI"
    def parse(self,s:list):
        n = len(s)
        assert n > 0
        assert s[0][1] == "elif"
        assert s[-1][1] == "}"
        for i in range(1,n):
            if s[i][1] == '{':
                try:
                    condition =s[1:i]
                    code = s[i+1:-1]
                    cs0 = CS0()
                    s0 = S0()
                    cs0.parse(condition)
                    s0.parse(code)
                    self.children = [Token('elif'),cs0,Token("{"),s0,Token("}")]
                    break
                except:pass
        else:raise ValueError(f"syntax error in {s}")
    def eval(self):
        L = self.children
        assert len(L) == 5
        condition = L[1]
        code = L[3]
        SYMBOLS = SYMBOLSTACK[-1]
        assert SYMBOLS["LASTCONDITION"] is not None,"elif must have a while or if before it"
        if SYMBOLS["LASTCONDITION"]:return
        cond = condition.eval()
        if cond:
            SYMBOLS["LASTCONDITION"] =True
            return code.eval()
        else:
            SYMBOLS["LASTCONDITION"] =False

class EI1(Node):
    name = "EI1"
    def parse(self,s:list):
        n = len(s)
        assert n >= 3
        assert s[0][1] == "else"
        assert s[-1][1] == "}"
        assert s[1][1] == "{"
        code = F()
        code.parse(s[1:])
        self.children = [Token('else'),code]
    def eval(self):
        L = self.children
        assert len(L) == 2
        code = L[1]
        SYMBOLS = SYMBOLSTACK[-1]
        assert SYMBOLS["LASTCONDITION"] is not None,"else must have a while or if before it"
        if SYMBOLS["LASTCONDITION"]:return
        return code.eval()


class S1(Node):
    name = "S1"
    def parse(self,s:list):
        n =len(s)
        self.value = s
        assert n > 1
        assert s[-1][1] == ";"
        right = Token(";")
        if s[0][1] == "print":left = P()
        elif s[0][1] == "run":left = R()
        elif s[0][1] == "dict":left = D()
        elif s[0][1] == "return":left = Ret()
        elif s[0][1] == "plot":left = Plot()
        else:left = A()
        left.parse(s[:-1])
        self.children = [left,right]
    def eval(self):
        L = self.children
        assert len(L) == 2
        return L[0].eval()

class A(Node):
    name = "A"
    opname = "="
    left_associative =False
    def parse(self,s:list):
        n = len(s)
        for i in range(n):
            if s[i][1] == "=":
                left = s[:i]
                right = s[i+1:]
                assert len(left) > 0
                assert len(right) > 0
                Left = V()
                if right[0][1] == "{":Right = F()
                elif right[0][1] == "list":Right = Lis()
                elif right[0][1] == "vec":Right = Vec()
                else: Right = CS0()
                Left.parse(left)
                Right.parse(right)
                Middle = Token("=")
                self.children = [Left,Middle,Right]
                break
        else:raise ValueError("Not an assignment")
    def eval(self):
        L = self.children
        n = len(L)
        assert n == 3
        assert L[1].value == "="
        #if isinstance(L[2],F) and L[2].name == "F":
        #    L[0].update(L[2])
        #else:
        value = L[2].eval()
        L[0].update(value)

class P(Node):
    name:"P"
    def parse(self,s:list):
        n = len(s)
        assert n > 0
        x = s[0]
        assert x[1] == "print"
        Left = Token(x[1])
        Right = CS0()
        Right.parse(s[1:])
        self.children = [Left,Right]
    def eval(self):
        global to_tuple
        L = self.children
        n = len(L)
        assert n == 2
        x = L[1].eval()
        x = to_tuple(x)
        print(x,end = "")

class Plot(Node):
    name:"plot"
    def parse(self,s:list):
        n = len(s)
        assert n > 0
        x = s[0]
        assert x[1] == "plot"
        Left = Token(x[1])
        Right = CSV()
        Right.parse(s[1:])
        self.children = [Left,Right]
    def eval(self):
        global to_tuple
        L = self.children
        n = len(L)
        assert n == 2
        x = L[1].eval()
        if x is None: print("\nNothing to plot\n")
        elif not isinstance(x,list):print(f"\n{x} is a 0 dimensional object. This cannot be ploted\n")
        elif not x:print(f"\nEmpty lists cannot be ploted\n")
        elif len(x) > 2 and not isinstance(x[0],list):
            try:
                t = arange(len(x))
                x = array(x)
                f = plt.figure()
                f.plot(t,x)
                f.show()
                del f
            except:print("\nunable to plot\n")
        elif len(x) > 2 : print("\nplotting in more than 2 dimensions is not possible yet\n")
        elif not (isinstance(x[1],list) or isinstance(x[1],ndarray)):print("second argument should be a vector too")
        elif len(x[0])!=len(x[1]):print("size mismatch")
        else:
            try:
                x,y = x
                f = plt.figure()
                f.plot(x,y)
                f.show()
                del f
            except:print("\nunable to plot\n")

class R(Node):
    name:"R"
    def parse(self,s:list):
        self.value = s
        n = len(s)
        assert n > 0
        x = s[0]
        assert x[1] == "run"
        Left = Token(x[1])
        for i in range(1,n):
            x = s[i]
            if x[1] == "with":
                Fun = CS0()
                Fun.parse(s[1:i])
                Arg = CSV()
                Arg.parse(s[i+1:])
                self.children = [Left,Fun,Token("with"),Arg]
                return
        Fun = CS0()
        Fun.parse(s[1:])
        self.children = [Left,Fun]
    def eval(self):
        L = self.children
        n = len(L)
        assert n == 4 or n==2
        Fun = L[1]
        f = Fun.eval()
        assert isinstance(f,F)
        if n==4:
            Arg = L[3]
            arg = Arg.eval()
            if arg is None:arg = []
            elif not isinstance(arg,list):arg = [arg]
        else:
            arg = []
        SYMBOLS = {
            "nl":"\n",
            "tab":"\t",
            "LASTCONDITION":None,
        }
        SYMBOLSTACK.append(SYMBOLS)
        to_ret = f.eval(arg)
        SYMBOLSTACK.pop()
        SYMBOLS = SYMBOLSTACK[-1]

class Ret(Node):
    name:"Ret"
    def parse(self,s:list):
        self.value = s
        n = len(s)
        assert n > 0
        x = s[0]
        assert x[1] == "return"
        Left = Token(x[1])
        Right = CS0()
        Right.parse(s[1:])
        self.children = [Left,Right]
    def eval(self):
        L = self.children
        n = len(L)
        assert n == 2
        return L[1].eval()

class D(Node):
    name:"D"
    def parse(self,s:list):
        self.value = s
        n = len(s)
        assert n > 0
        x = s[0]
        assert x[1] == "dict"
        Left = Token(x[1])
        Right = V()
        Right.parse(s[1:])
        self.children = [Left,Right]
    def eval(self):
        L = self.children
        n = len(L)
        assert n == 2
        L[1].update(dict())


"""
CS0 -> CS1 or CS0 | CS1
CS1 -> CS2 and CS1 | CS2
CS2 -> not C0 | C0
"""

class CS0(BinOp):
    name = "CS0"
    opname = "or"
    def duplicate(self):return CS0()
    def other(self):return CS1()
    def op(self,x,y):return x or y

class CS1(BinOp):
    name = "CS1"
    opname = "and"
    def duplicate(self):return CS1()
    def other(self):return CS2()
    def op(self,x,y):return x and y

class CS2(Node):
    name = "CS2"
    def parse(self,s:list):
        self.value = s
        n = len(s)
        assert n > 0
        x = s[0]
        if x[1] == "not":
            left = Token("not")
            right = C0()
            right.parse(s[1:])
            self.children = [left,right]
        else:
            child = C0()
            child.parse(s)
            self.children = [child]
    def eval(self):
        L = self.children
        n = len(L)
        if n == 1:return L[0].eval()
        elif n == 2:return L[1].eval()

"""
C0 -> C1 == C0 | C1
C1 -> C2 > C1 | C2
C2 -> C3 < C2 | C3
C3 -> C4 >= C3 | C4
C4 -> C5 <= C4 | C5
C5 -> E0 != C5 | E0
"""

class C0(BinOp):
    name = "C0"
    opname = "=="
    def duplicate(self):return C0()
    def other(self):return C1()
    def op(self,x,y):return x == y

class C1(BinOp):
    name = "C1"
    opname = ">"
    def duplicate(self):return C1()
    def other(self):return C2()
    def op(self,x,y):return x > y

class C2(BinOp):
    name = "C2"
    opname = "<"
    def duplicate(self):return C2()
    def other(self):return C3()
    def op(self,x,y):return x < y

class C3(BinOp):
    name = "C3"
    opname = ">="
    def duplicate(self):return C3()
    def other(self):return C4()
    def op(self,x,y):return x >= y

class C4(BinOp):
    name = "C4"
    opname = "<="
    def duplicate(self):return C4()
    def other(self):return C5()
    def op(self,x,y):return x <= y

class C5(BinOp):
    name = "C5"
    opname = "!="
    def duplicate(self):return C5()
    def other(self):return E0()
    def op(self,x,y):return x != y

class E0(MultiBinOp):
    name = "E0"
    opnames = ["+","-"]
    left_associative = True
    def duplicate(self):return E0()
    def other(self):return E2()
    def op(self,x,y,operation):
        if operation == "+" : return x+y
        if operation == "-" : return x-y
        else:
            print("This is not good")

class E2(BinOp):
    name = "E2"
    opname = "*"
    left_associative = True
    def duplicate(self):return E2()
    def other(self):return E3()
    def op(self,x,y):return x*y

class E3(BinOp):
    name = "E3"
    opname = "/"
    left_associative = True
    def duplicate(self):return E3()
    def other(self):return E4()
    def op(self,x,y):return x/y

class E4(BinOp):
    name = "E4"
    opname = "**"
    left_associative =False
    def duplicate(self):return E4()
    def other(self):return E5()
    def op(self,x,y):return x ** y

class E5(BinOp):
    name = "E5"
    opname = "//"
    left_associative =False
    def duplicate(self):return E5()
    def other(self):return E6()
    def op(self,x,y):return x // y

class E6(BinOp):
    name = "E6"
    opname = "%"
    left_associative =False
    def duplicate(self):return E6()
    def other(self):return E7()
    def op(self,x,y):return x % y

class E7(UnOp):
    name = "E7"
    opname = "-"
    def other(self):return E8()
    def op(self,x):return -x

class E8(Node):
    name = "E8"
    def parse(self,s:list):
        self.value = s
        n = len(s)
        assert n > 0
        if s[0][1] == "(":
            assert s[-1][1] == ")",f"syntax error in {s}"
            Left =Token("(")
            Right =Token(")")
            Middle = CSV()
            Middle.parse(s[1:-1])
            self.children = [Left,Middle,Right]
        elif s[0][1] == "[":
            assert s[-1][1] == "]",f"syntax error in {s}"
            Left =Token("[")
            Right =Token("]")
            Middle = CSV()
            Middle.parse(s[1:-1])
            self.children = [Left,Middle,Right]
        else:
            child = E9()
            child.parse(s)
            self.children = [child]
    def eval(self):
        L = self.children
        assert L
        if len(L) == 1:return L[0].eval()
        elif len(L) == 3:
            if L[0].value == "(":return L[1].eval()
            elif L[0].value == "[":
                x = L[1].eval()
                if x is None:return array()
                elif not isinstance(x,list):x = array([x])
                return array(x)

class E9(Node):
    name = "E9"
    def parse(self,s):
        self.value = s
        n = len(s)
        assert n > 0,f"syntax error in {s}"
        x = s[0]
        if n == 1 and x[0] == "int": t = Int(x[1])
        elif n == 1 and x[0] == "float": t = Float(x[1])
        elif n == 1 and x[0] == "str": t = Str(x[1])
        elif n == 1 and x[0] == "id": t = Id(x[1])
        elif x[1] == "alg":
            t = Al()
            t.parse(s)
        elif s[0][0] == "id" and s[1][1] == "(" and s[-1][1] == ")":
            t =FC()
            t.parse(s)
        else:
            t = V()
            t.parse(s)
        self.children = [t]
    def eval(self):
        assert len(self.children) == 1
        child = self.children[0]
        return child.eval()

class Al(Node):
    name = "Al"
    def parse(self,s):
        self.value = s
        n = len(s)
        assert n >= 3
        assert s[0][1] == "alg"
        assert s[1][1] == "("
        assert s[-1][1] == "}"
        try:
            for i in range(2,n-1):
                if s[i][1] == ")":
                    right = F()
                    right.parse(s[i+1:])
                    left = Token("alg")
                    middle = ENV()
                    middle.parse(s[1:i+1])
                    self.children = [left,middle,right]
                    return
        except:
            raise ValueError("Algorithm definition failed")
    def eval(self):
        global SymbolsNeeded,SYMBOLSTACK
        kw,arg,f = self.children
        arg = arg.eval()
        assert isinstance(f,F)
        f.args = tuple(arg)
        S = SYMBOLSTACK[-1]
        f.env = {k:S[k] for k in S if k in SymbolsNeeded(f)}
        return f

class ENV(Node):
    name = "ENV"
    def parse(self,s):
        self.value = s
        n = len(s)
        assert s[0][1] == "("
        assert s[-1][1] == ")"
        var = True
        children = [Token("(")]
        for i in range(1,n-1):
            if var:
                assert s[i][0] == "id", "environement not parsed correctly"
                child = Id(s[i][1])
                children.append(child)
                var = False
            else:
                assert s[i][1] == ",","environment not parsed correctly"
                child = Token(",")
                children.append(child)
                var = True
        children.append(Token(")"))
        self.children = children
    def eval(self):
        return [child.value for child in self.children[1:-1:2]]

class CSV(Node):
    name = "CSV"
    def parse(self,s):
        self.value = s
        n = len(s)
        #assert s[0][1] == "("
        #assert s[-1][1] == ")"
        #children = [Token("(")]
        children = []
        stack = []
        for i in range(0,n):
            if s[i][1] != ",":
                stack.append(s[i])
            else:
                try:
                    child = CS0()
                    child.parse(stack)
                    children.append(child)
                    children.append(Token(","))
                    stack = []
                except:stack.append(s[i])
        if stack:
            child = CS0()
            child.parse(stack)
            children.append(child)
        #children.append(Token(")"))
        self.children = children
    def eval(self):
        if len(self.children) == 0:return None
        if len(self.children) == 1:return self.children[0].eval()
        return  [x.eval() for x in self.children[::2]]

class FC(Node):
    name = "FC"
    def parse(self,s):
        self.value = s
        n = len(s)
        assert n >= 3
        assert s[0][0] == "id"
        assert s[1][1] == "("
        assert s[-1][1] == ")"
        right = CSV()
        right.parse(s[2:-1])
        left = Id(s[0][1])
        self.children = [left,Token("("),right,Token(")")]
    def eval(self):
        left,op,right,ed = self.children
        f = left.eval()
        assert isinstance(f,F)
        assert isinstance(right,CSV)
        SYMBOLS = {
            "nl":"\n",
            "tab":"\t",
            "LASTCONDITION":None,
        }
        SYMBOLSTACK.append(SYMBOLS)
        #body1 = right.children[1]
        #body2 = f.children[1]
        #body1.eval()
        #to_ret = body2.eval()
        args = right.eval()
        if args is None:args = []
        elif not isinstance(args,list):args = [args]
        to_ret = f.eval(args)
        SYMBOLSTACK.pop()
        del SYMBOLS
        return to_ret

class V(Node):
    name = "V"
    def parse(self,s):
        self.value = s
        n = len(s)
        assert n > 0
        x = s[0]
        assert x[0] == "id"
        if n == 1 :self.children = [Id(x[1])]
        else:
            assert s[1][1] == "[",s
            assert s[-1][1] == "]",s
            Left = Token("[")
            Right = Token("]")
            Middle = E0()
            Middle.parse(s[2:-1])
            self.children = [Id(x[1]),Left,Middle,Right]
    def eval(self):
        L = self.children
        n = len(L)
        assert n > 0
        if n == 1:return L[0].eval()
        assert n == 4
        lis = L[0].eval()
        ind = L[2].eval()
        if isinstance(lis,list):
            if ind < 0 or ind > len(lis):return None
        return lis[ind]

    def update(self,value):
        L = self.children
        n = len(L)
        assert n > 0
        x = L[0]
        x = x.value
        SYMBOLS = SYMBOLSTACK[-1]
        if n == 1:
            SYMBOLS[x] = value
        elif n == 4:
            ind = L[2].eval()
            SYMBOLS[x][ind] = value
        else:raise ValueError("This shouldn't be happening")

SYMBOLS = {
    "nl":"\n",
    "tab":"\t",
    "LASTCONDITION":None,
}

SYMBOLSTACK = [SYMBOLS]

if __name__ == "__main__":
    #s = open("sample2.txt").read()
    E0().parse([('id', 'x'), ('op1', '+'), ('id', 'y'), ('op1', '+'), ('id', 'z')])
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("file")
    parser.add_argument("vis")
    args = parser.parse_args()
    file = args.file
    vis = args.vis
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
    if vis == "True":
        s0.PlotTree()
        Graph.render(file + ".png",format='png',view=True)
