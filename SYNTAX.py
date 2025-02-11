from LEXER import *
from graphviz import Digraph
from ast import literal_eval
import termplotlib as plt
from numpy import *

Graph = Digraph("AST")
cur_node = 0
DEBUG_WITH_COLOR = False
TESTING = False

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
        on_wrong = self.name + f" : syntax error in: \n" + TokensToStr(s,DEBUG_WITH_COLOR)
        if not n >= 2:return ValueError(self.name + " : syntax error in: \n" + TokensToStr(s,DEBUG_WITH_COLOR))
        if not s[0][1] == "{":return ValueError(self.name + " : body should start with '{': \n" + TokensToStr(s,DEBUG_WITH_COLOR))
        if not s[-1][1] == "}":return ValueError(self.name + " : missing closing '}': \n" + TokensToStr(s,DEBUG_WITH_COLOR))
        body = S0()
        res = body.parse(s[1:-1])
        if isinstance(res,ValueError):return res
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
        env = [f" {k} = {to_tuple(self.env[k]).__repr__()}" for k in self.env] + [""]
        env = "\n |".join(env)
        if len(env) : s += "\n | where\n |" + env
        max_width = max([len(x) for x in s.split("\n")])
        s = "\n".join([x + " "*(max_width+2-len(x)) + "|" for x in s.split("\n")])
        s = "  " + "_"*max_width + "\n |" + " "*max_width + "|\n" + s + "\n |" + "_"*max_width + "|\n\n"
        return s
    def __repr__(self):
        s = self.value
        if len(s) > 10: s = s[:5] + [(""," ... ")]+ s[-5:]
        s = "".join([(" " if x[0] != "brak" else "") + x[1] for x in s])
        s = "alg(" + ",".join(self.args) + ")" + s
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
        on_wrong = f"syntax error for operation {self.op} \n" + TokensToStr(s,DEBUG_WITH_COLOR)
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
        last_err = None
        if n == 0:self.children =[]
        elif s[0][1] in ["while","if",'elif','else']:
            on_wrong = self.name + " : syntax error in:\n" + TokensToStr(s,DEBUG_WITH_COLOR)
            for i in range(1,n):
                if s[i][1] == "}":
                    left = s[:i+1]
                    right = s[i+1:]
                    if s[0][1] == "while":Left = W()
                    elif s[0][1] == "elif":Left = EI()
                    elif s[0][1] == "else":Left = EI1()
                    elif s[0][1] == "if":Left = I()
                    else:continue
                    Right = S0()
                    res = Left.parse(left)
                    if isinstance(res,ValueError):
                        last_err = res
                        continue
                    res = Right.parse(right)
                    if isinstance(res,ValueError):
                        return ValueError(on_wrong,res)
                    #except:continue
                    self.children = [Left,Right]
                    break
            else:
                if last_err is not None: return ValueError(on_wrong,last_err)
                return ValueError(on_wrong)
        else:
            on_wrong = self.name + " : syntax error in:\n" + TokensToStr(s,DEBUG_WITH_COLOR)
            for i in range(n):
                if s[i][1] == ";":
                    left = s[:i+1]
                    right = s[i+1:]
                    Left = S1()
                    Right = S0()
                    try:res = Left.parse(left)
                    except:continue
                    if isinstance(res,ValueError):
                        last_err = res
                        continue
                    try:res = Right.parse(right)
                    except:continue
                    if isinstance(res,ValueError):
                        return ValueError(on_wrong,res)
                    self.children = [Left,Right]
                    break
            else:
                if last_err is not None: return ValueError(on_wrong,last_err)
                return ValueError(on_wrong)
    def eval(self):
        for child in self.children:
            x = child.eval()
            if x is not None: return x

class W(Node):
    name = "W"
    def parse(self,s:list):
        n = len(s)
        on_wrong = self.name + f" : syntax error in: \n" + TokensToStr(s,DEBUG_WITH_COLOR)
        if not n > 0                :return ValueError(on_wrong)
        if not s[0][1] == "while"   :return ValueError(on_wrong)
        if not s[-1][1] == "}"      :return ValueError(on_wrong)
        last_err = None
        for i in range(1,n):
            if s[i][1] == '{':
                condition =s[1:i]
                code = s[i:]
                cs0 = CS0()
                f = F()
                try:res = cs0.parse(condition)
                except:continue
                if isinstance(res,ValueError):
                    last_err = res
                    continue
                try:res = f.parse(code)
                except:continue
                if isinstance(res,ValueError):
                    last_err = res
                    continue
                self.children = [Token('while'),cs0,f]
                break
        else:
            if last_err is not None: return ValueError(on_wrong,last_err)
            return ValueError(on_wrong)
    def eval(self):
        L = self.children
        assert len(L) == 3
        condition = L[1]
        code = L[2]
        br =10**9
        SYMBOLS = SYMBOLSTACK[-1]
        while condition.eval() and br > 0:
            x = code.eval()
            if isinstance(x,Brk):
                SYMBOLS["LASTCONDITION"] = True
                break
            if isinstance(x,Cont):continue
            if x is not None:return x
            br -= 1
        else:SYMBOLS["LASTCONDITION"] = False
        if br <= 0 : print("broken while because it took over 10^9 loops")

class Brk(Node):
    def parse(self,s:list):
        n = len(s)
        if not n == 1:return ValueError("break statements only have the `break` keyword:\n" + TokensToStr(s,DEBUG_WITH_COLOR))
        if not s[0][1] == "break":return ValueError("break statements start with `break`:\n" + TokensToStr(s,DEBUG_WITH_COLOR))
        self.children = [Token("break")]
    def eval(self):
        return self

class Cont(Node):
    def parse(self,s:list):
        n = len(s)
        if not n == 1:return ValueError("continue statements only have the `continue` keyword:\n" + TokensToStr(s,DEBUG_WITH_COLOR))
        if not s[0][1] == "continue":return ValueError("continue statements start with `continue`:\n" + TokensToStr(s,DEBUG_WITH_COLOR))
        self.children = [Token("continue")]
    def eval(self):
        return self


class I(Node):
    name = "I"
    def parse(self,s:list):
        n = len(s)
        on_wrong = self.name + f" : syntax error in: \n" + TokensToStr(s,DEBUG_WITH_COLOR)
        if not n > 0            :return ValueError(on_wrong)
        if not s[0][1] == "if"  :return ValueError(on_wrong)
        if not s[-1][1] == "}"  :return ValueError(on_wrong)
        last_err = None
        for i in range(1,n):
            if s[i][1] == '{':
                condition =s[1:i]
                code = s[i+1:-1]
                cs0 = CS0()
                s0 = S0()
                try:res = cs0.parse(condition)
                except:continue
                if isinstance(res,ValueError):
                    last_err = res
                    continue
                res = s0.parse(code)
                if isinstance(res,ValueError):
                    #last_err = res
                    #continue
                    return ValueError(on_wrong,res)
                self.children = [Token('if'),cs0,Token("{"),s0,Token("}")]
                break
        else:
            if last_err is not None: return ValueError(on_wrong,last_err)
            return ValueError(on_wrong)
    def eval(self):
        L = self.children
        assert len(L) == 5
        condition = L[1]
        code = L[3]
        SYMBOLS = SYMBOLSTACK[-1]
        cond = condition.eval()
        if cond:
            to_ret = code.eval()
            SYMBOLS["LASTCONDITION"] =True
            return to_ret
        else:SYMBOLS["LASTCONDITION"] =False

class EI(Node):
    name = "EI"
    def parse(self,s:list):
        n = len(s)
        on_wrong = self.name + f" : syntax error in: \n" + TokensToStr(s,DEBUG_WITH_COLOR)
        if not n > 0            :return ValueError(on_wrong)
        if not s[0][1] == "elif":return ValueError(on_wrong)
        if not s[-1][1] == "}"  :return ValueError(on_wrong)
        last_err = None
        for i in range(1,n):
            if s[i][1] == '{':
                condition =s[1:i]
                code = s[i+1:-1]
                cs0 = CS0()
                s0 = S0()
                try:res = cs0.parse(condition)
                except:continue
                if isinstance(res,ValueError):
                    last_err = res
                    continue
                try:res=s0.parse(code)
                except:continue
                if isinstance(res,ValueError):
                    #last_err = res
                    #continue
                    return ValueError(on_wrong,res)
                self.children = [Token('elif'),cs0,Token("{"),s0,Token("}")]
                break
        else:
            if last_err is not None: return ValueError(on_wrong,last_err)
            return ValueError(on_wrong)
    def eval(self):
        L = self.children
        assert len(L) == 5
        condition = L[1]
        code = L[3]
        SYMBOLS = SYMBOLSTACK[-1]
        #assert SYMBOLS["LASTCONDITION"] is not None,"elif must have a while or if before it"
        if SYMBOLS["LASTCONDITION"]:return
        cond = condition.eval()
        if cond:
            to_ret = code.eval()
            SYMBOLS["LASTCONDITION"] =True
            return to_ret
        else:
            SYMBOLS["LASTCONDITION"] =False

class EI1(Node):
    name = "EI1"
    def parse(self,s:list):
        n = len(s)
        on_wrong = self.name + f" : syntax error in: \n" + TokensToStr(s,DEBUG_WITH_COLOR)
        if not n >= 3           :return ValueError(on_wrong)
        if not s[0][1] == "else":return ValueError(on_wrong)
        if not s[-1][1] == "}"  :return ValueError(on_wrong)
        if not s[1][1] == "{"   :return ValueError(on_wrong)
        code = F()
        try:res = code.parse(s[1:])
        except:return ValueError(on_wrong)
        if isinstance(res,ValueError):
            return ValueError(on_wrong,res)
        self.children = [Token('else'),code]
    def eval(self):
        L = self.children
        assert len(L) == 2
        code = L[1]
        SYMBOLS = SYMBOLSTACK[-1]
        #assert SYMBOLS["LASTCONDITION"] is not None,"else must have a while or if before it"
        if SYMBOLS["LASTCONDITION"]:return
        SYMBOLS["LASTCONDITION"] = True
        return code.eval()


class S1(Node):
    name = "S1"
    def parse(self,s:list):
        n =len(s)
        on_wrong = self.name + f" : syntax error in: \n" + TokensToStr(s,DEBUG_WITH_COLOR)
        self.value = s
        if not n > 1:return ValueError(on_wrong)
        if not s[-1][1] == ";":return ValueError(on_wrong)
        right = Token(";")
        if s[0][1] == "print":left = P()
        elif s[0][1] == "run":left = R()
        elif s[0][1] == "dict":left = D()
        elif s[0][1] == "return":left = Ret()
        elif s[0][1] == "plot":left = Plot()
        elif s[0][1] == "break":left = Brk()
        elif s[0][1] == "continue":left = Cont()
        else:left = A()
        try:res = left.parse(s[:-1])
        except:return ValueError(on_wrong)
        if isinstance(res,ValueError):return ValueError(on_wrong,res)
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
        on_wrong = "incorrect assignment:\n" + TokensToStr(s,DEBUG_WITH_COLOR)
        for i in range(n):
            if s[i][1] == "=":
                left = s[:i]
                right = s[i+1:]
                if not len(left) > 0 : return ValueError("LHS is empty:\n" + TokensToStr(s,DEBUG_WITH_COLOR))
                if not len(right) > 0 : return ValueError("RHS is empty:\n" + TokensToStr(s,DEBUG_WITH_COLOR))
                Left = V()
                if right[0][1] == "{":Right = F()
                elif right[0][1] == "list":Right = Lis()
                elif right[0][1] == "vec":Right = Vec()
                else: Right = CS0()
                try:res = Left.parse(left)
                except:return ValueError(on_wrong)
                if isinstance(res,ValueError):return ValueError(on_wrong,res)
                try:res = Right.parse(right)
                except:return ValueError(on_wrong)
                if isinstance(res,ValueError):return ValueError(on_wrong,res)
                Middle = Token("=")
                self.children = [Left,Middle,Right]
                break
        else:return ValueError(on_wrong)
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
        on_wrong = f"incorrect print statement: \n" + TokensToStr(s,DEBUG_WITH_COLOR)
        assert n > 0
        x = s[0]
        assert x[1] == "print"
        Left = Token(x[1])
        Right = CS0()
        try:res = Right.parse(s[1:])
        except:return ValueError(on_wrong)
        if isinstance(res,ValueError):return ValueError(on_wrong,res)
        self.children = [Left,Right]
    def eval(self):
        global to_tuple,TESTING
        L = self.children
        n = len(L)
        assert n == 2
        x = L[1].eval()
        x = to_tuple(x)
        if isinstance(x,F):x = x.prepr()
        if not TESTING:print(x,end = "")

class Plot(Node):
    name:"plot"
    def parse(self,s:list):
        n = len(s)
        on_wrong = "incorrect plot statement: \n" + TokensToStr(s,DEBUG_WITH_COLOR)
        assert n > 0
        x = s[0]
        assert x[1] == "plot"
        Left = Token(x[1])
        Right = CSV()
        try:res = Right.parse(s[1:])
        except:return ValueError(on_wrong)
        if isinstance(res,ValueError):return ValueError(on_wrong,res)
        self.children = [Left,Right]
    def eval(self):
        global to_tuple,TESTING
        if TESTING:return
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
                f.plot(x,y,width=50,height=20)
                f.show()
                del f
            except:print("\nunable to plot\n")

class R(Node):
    name:"R"
    def parse(self,s:list):
        self.value = s
        on_wrong = "incorrect run statement :\n" + TokensToStr(s,DEBUG_WITH_COLOR)
        n = len(s)
        assert n > 0
        x = s[0]
        assert x[1] == "run"
        Left = Token(x[1])
        for i in range(1,n):
            x = s[i]
            if x[1] == "with":
                Fun = CS0()
                Arg = CSV()
                try:res= Fun.parse(s[1:i])
                except:return ValueError(on_wrong)
                if isinstance(res,ValueError):return ValueError(on_wrong,res)
                try:res= Arg.parse(s[i+1:])
                except:return ValueError(on_wrong)
                if isinstance(res,ValueError):return ValueError(on_wrong,res)
                self.children = [Left,Fun,Token("with"),Arg]
                return
        Fun = CS0()
        try:res= Fun.parse(s[1:])
        except:return ValueError(on_wrong)
        if isinstance(res,ValueError):return ValueError(on_wrong,res)
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
            arg = Arg.eval(True)
            if arg is None:arg = []
            elif not isinstance(arg,list):arg = [arg]
        else:
            arg = []
        SYMBOLS = {
            "nl":"\n",
            "tab":"\t",
            "LASTCONDITION":True,
        }
        SYMBOLSTACK.append(SYMBOLS)
        to_ret = f.eval(arg)
        SYMBOLSTACK.pop()
        SYMBOLS = SYMBOLSTACK[-1]

class Ret(Node):
    name:"Ret"
    def parse(self,s:list):
        self.value = s
        on_wrong = "incorrect return statement :\n" + TokensToStr(s,DEBUG_WITH_COLOR)
        n = len(s)
        assert n > 0
        x = s[0]
        assert x[1] == "return"
        Left = Token(x[1])
        Right = CS0()
        try:res = Right.parse(s[1:])
        except:return ValueError(on_wrong)
        if isinstance(res,ValueError):return ValueError(on_wrong,res)
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
        on_wrong = "incorrect dictionary initialisation :\n" + TokensToStr(s,DEBUG_WITH_COLOR)
        n = len(s)
        assert n > 0
        x = s[0]
        assert x[1] == "dict"
        Left = Token(x[1])
        Right = V()
        try:res = Right.parse(s[1:])
        except:return ValueError(on_wrong)
        if isinstance(res,ValueError):return ValueError(on_wrong,res)
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

# class CS2(Node):
#     name = "CS2"
#     def parse(self,s:list):
#         self.value = s
#         n = len(s)
#         assert n > 0
#         x = s[0]
#         if x[1] == "not":
#             left = Token("not")
#             right = C0()
#             right.parse(s[1:])
#             self.children = [left,right]
#         else:
#             child = C0()
#             child.parse(s)
#             self.children = [child]
#     def eval(self):
#         L = self.children
#         n = len(L)
#         if n == 1:return L[0].eval()
#         elif n == 2:return not L[1].eval()

class CS2(UnOp):
    name = "CS2"
    opname = "not"
    def other(self):return C0()
    def op(self,x):return not x

"""
C0 -> E0 == C0
C0 -> E0 >  C0
C0 -> E0 <  C0
C0 -> E0 >= C0
C0 -> E0 <= C0
C0 -> E0 != C0
"""

class C0(MultiBinOp):
    name = "E0"
    opnames = ["==",">","<",">=","<=","!="]
    left_associative = True
    def duplicate(self):return C0()
    def other(self):return E0()
    def op(self,x,y,operation):
        if operation == "==" : return x == y
        if operation == ">" : return x > y
        if operation == "<" : return x < y
        if operation == ">=" : return x >= y
        if operation == "<=" : return x <= y
        if operation == "!=" : return x != y
        else:raise ValueError(f"unrecognised binary operation {operation}")

# class C0(BinOp):
#     name = "C0"
#     opname = "=="
#     def duplicate(self):return C0()
#     def other(self):return C1()
#     def op(self,x,y):return x == y

# class C1(BinOp):
#     name = "C1"
#     opname = ">"
#     def duplicate(self):return C1()
#     def other(self):return C2()
#     def op(self,x,y):return x > y

# class C2(BinOp):
#     name = "C2"
#     opname = "<"
#     def duplicate(self):return C2()
#     def other(self):return C3()
#     def op(self,x,y):return x < y

# class C3(BinOp):
#     name = "C3"
#     opname = ">="
#     def duplicate(self):return C3()
#     def other(self):return C4()
#     def op(self,x,y):return x >= y

# class C4(BinOp):
#     name = "C4"
#     opname = "<="
#     def duplicate(self):return C4()
#     def other(self):return C5()
#     def op(self,x,y):return x <= y

# class C5(BinOp):
#     name = "C5"
#     opname = "!="
#     def duplicate(self):return C5()
#     def other(self):return E0()
#     def op(self,x,y):return x != y

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

#class E2(BinOp):
#    name = "E2"
#    opname = "*"
#    left_associative = True
#    def duplicate(self):return E2()
#    def other(self):return E3()
#    def op(self,x,y):return x*y


class E2(MultiBinOp):
    name = "E0"
    opnames = ["*","/","//","%","mod","div"]
    left_associative = True
    def duplicate(self):return E2()
    def other(self):return E4()
    def op(self,x,y,operation):
        if operation == "*" : return x*y
        if operation == "/" : return x/y
        if operation == "//" : return x//y
        if operation == "%" : return x%y
        if operation == "div" : return x//y
        if operation == "mod" : return x%y
        else:
            raise ValueError(f"unrecognised binary operation {operation}")


#class E3(BinOp):
#    name = "E3"
#    opname = "/"
#    left_associative = True
#    def duplicate(self):return E3()
#    def other(self):return E4()
#    def op(self,x,y):return x/y

class E4(BinOp):
    name = "E4"
    opname = "**"
    left_associative =False
    def duplicate(self):return E4()
    def other(self):return E7()
    def op(self,x,y):return x ** y

#class E5(BinOp):
#    name = "E5"
#    opname = "//"
#    left_associative =True
#    def duplicate(self):return E5()
#    def other(self):return E6()
#    def op(self,x,y):return x // y

#class E6(BinOp):
#    name = "E6"
#    opname = "%"
#    left_associative =True
#    def duplicate(self):return E6()
#    def other(self):return E7()
#    def op(self,x,y):return x % y

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
                    res = right.parse(s[i+1:])
                    if isinstance(res,ValueError):raise ValueError("Function body wasn't parsed")
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
    def eval(self,wrap=False):
        if not wrap and len(self.children) == 0:return None
        if not wrap and len(self.children) == 1:return self.children[0].eval()
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
            "LASTCONDITION":True,
        }
        SYMBOLSTACK.append(SYMBOLS)
        #body1 = right.children[1]
        #body2 = f.children[1]
        #body1.eval()
        #to_ret = body2.eval()
        args = right.eval(True)
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
    "LASTCONDITION":True,
}

SYMBOLSTACK = [SYMBOLS]

def PrintError(Err):
    assert isinstance(Err,ValueError),"Not an error"
    args = Err.args
    if len(args) == 1:
        print(args[0],"\n")
        return
    m,Err = args
    print(m,"\n")
    PrintError(Err)



if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("file")
    parser.add_argument("vis")
    args = parser.parse_args()
    file = args.file
    vis = args.vis
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
        if DEBUG_WITH_COLOR:print("\x1b[38;2;0;0;255mOutput\x1b[0m")
        else:print("Output:")
        print("_"*50 + "\n")
        res = s0.eval()
        if isinstance(res,ValueError):PrintError(res)
        print("\n\n" + "_"*50 + "\n")
        #if DEBUG_WITH_COLOR:print("\x1b[38;2;0;255;0mFinished\x1b[0m")
        #else:print("Finished")
        #print("_"*50 + "\n")
        if vis == "True":
            s0.PlotTree()
            Graph.render(file + ".png",format='png',view=True)
