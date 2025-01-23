from LEXER import *
from graphviz import Digraph
from ast import literal_eval
"""
BODMAS
The grammar for this language is ..
S0 -> S1 S0 | W S0 | I S0 | ""
W -> while CS0 F
I -> if CS0 F
S1 -> P; | A; | R; | D;
P -> print CS0
R -> run id
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
Al -> alg F

"""
Graph = Digraph("AST")
cur_node = 0

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
        Graph.node(self.id,self.name)
        cur_node += 1
        for child in self.children:
            child.PlotTree()
            Graph.edge(self.id,child.id)

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
        SYMBOLS = SYMBOLSTACK[-1]
        if value not in SYMBOLS:
            SYMBOLS[value] = None
    def eval(self):
        x = self.value
        for i in range(len(SYMBOLSTACK)-1,-1,-1):
            SYMBOLS = SYMBOLSTACK[i]
            if x in SYMBOLS:return SYMBOLS[x]
        print(x,"is not defined")
        raise ValueError("undefined variable")

class F(Node):
    name = "F"
    def parse(self,s:list):
        self.value = s
        n = len(s)
        assert n >= 2
        assert s[0][1] == "{"
        assert s[-1][1] == "}"
        body = S0()
        body.parse(s[1:-1])
        self.children = [Token("{"),body,Token("}")]
    def eval(self):
        body = self.children[1]
        return body.eval()
    def __add__(self,other):
        par = F()
        body =S0()
        body.children = [self.children[1],other.children[1]]
        par.children = [Token("{"),body,Token("}")]
        return par
    def __mul__(self,other:int):
        to_ret = self
        for i in range(other-1):
            to_ret = to_ret + self
        return to_ret

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
    def op(self,x):return [None]*x

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
                else:Right = Lis()
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
        L = self.children
        n = len(L)
        assert n == 2
        x = L[1].eval()
        print(x,end = "")

class R(Node):
    name:"R"
    def parse(self,s:list):
        self.value = s
        n = len(s)
        assert n > 0
        x = s[0]
        assert x[1] == "run"
        Left = Token(x[1])
        Right = CS0()
        Right.parse(s[1:])
        self.children = [Left,Right]
    def eval(self):
        L = self.children
        n = len(L)
        assert n == 2
        f = L[1].eval()
        assert isinstance(f,F)
        SYMBOLS = {
            "nl":"\n",
            "tab":"\t",
            "LASTCONDITION":None,
        }
        SYMBOLSTACK.append(SYMBOLS)
        to_ret = f.eval()
        SYMBOLSTACK.pop()
        del SYMBOLS
        SYMBOLS = SYMBOLSTACK[-1]
        #return to_ret

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
            Middle = CS0()
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
        elif len(L) == 3:return L[1].eval()

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
        elif x[1] == "alg":
            t = Al()
            t.parse(s)
        elif s[0][0] == "id" and s[-1][1] == "}":
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
        assert s[1][1] == "{"
        assert s[-1][1] == "}"
        right = F()
        right.parse(s[1:])
        left = Token("alg")
        self.children = [left,right]
    def eval(self):
        return self.children[1]

class FC(Node):
    name = "FC"
    def parse(self,s):
        self.value = s
        n = len(s)
        assert n >= 3
        assert s[0][0] == "id"
        assert s[1][1] == "{"
        assert s[-1][1] == "}"
        right = F()
        right.parse(s[1:])
        left = Id(s[0][1])
        self.children = [left,right]
    def eval(self):
        left,right = self.children
        f = left.eval()
        assert isinstance(f,F)
        assert isinstance(right,F)
        SYMBOLS = {
            "nl":"\n",
            "tab":"\t",
            "LASTCONDITION":None,
        }
        SYMBOLSTACK.append(SYMBOLS)
        body1 = right.children[1]
        body2 = f.children[1]
        body1.eval()
        to_ret = body2.eval()
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