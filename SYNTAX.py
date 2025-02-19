from LEXER import *
from ast import literal_eval #for strings only
import termplotlib as plt #for `plot` statement
from numpy import * #for vectors

# global variable for visualisation of AST
from graphviz import Digraph
Graph = Digraph("AST")
cur_node = 0

# settings
DEBUG_WITH_COLOR = False
TESTING = False

def to_tuple(L):
    """
    Recursively converts lists to tuples
    """
    if isinstance(L,list) or isinstance(L,tuple):
        return tuple(x for x in L)
    else:return L

class Node:
    """
    Base class for all non-terminals
    Every Non-terminal has a `parse` and `eval` method
    """
    name = "Node"
    def __init__(self):
        self.children = []
        self.value = None
    def __repr__(self):
        return self.name + "->" + " ".join([x.name for x in self.children])
    def MakeTree(self):
        """
        Makes a string representing the sub-tree with node as head
        """
        s = [str(self)]
        for child in self.children:
            s.extend(child.MakeTree())
        return s
    def PlotTree(self):
        """
        Plots the sub-tree with node as head using Graphviz
        """
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
    """
    Base class for terminals
    Example usage:
    >>> some_token = Token("5")
    """
    def __init__(self,value:str):
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
        assert (
            (value[0] == '"' and value[-1] == '"')
            or
            (value[0] == "'" and value[-1] == "'")
        ), "Strings must be enclosed in quotes"
        #self.value = literal_eval(value)
        self.value = value[1:-1]
        self.name = self.value
    def eval(self):
        return self.value

class Id(Token):
    """
    Identifiers.
    Example usage:
    >>> x = Id("x")
    """
    name = "id"
    def __init__(self,value:str):
        self.value = value
        self.name = value
    def eval(self):
        x = self.value
        for i in range(len(SYMBOLSTACK)-1,-1,-1):
            SYMBOLS = SYMBOLSTACK[i]
            if x in SYMBOLS:
                if SYMBOLS[x] is None: raise ValueError(f"{x} is not assigned yet")
                return SYMBOLS[x]
        raise ValueError(f"undefined variable {x}")

class Block(Node):
    """
    A non-terminal respresenting a block of statements.
    CFG rules:

    Block -> { Statements }

    A block is basically a function and thus has these attributes:

    args : iterable of names of variables that are assigned just after block's evaluation has started.
    The values can be assigned via a function call

    env : static arguments. These are set during creation of an algorithm (function) using the `alg` keyword

    A block returns values if there are return statements inside. For example:

    ```
    x = {return 1;};
    ```

    will assign `1` to `x` .

    Blocks can be concatenated togather using the `+` operator, and can be repeated by multiplying with a natural number.
    """
    name = "Block"
    args = ()
    env = {}
    def parse(self,s:list):
        self.value = s
        n = len(s)
        on_wrong = self.name + f" : syntax error in: \n" + TokensToStr(s,DEBUG_WITH_COLOR)
        if not n >= 2:return ValueError(self.name + " : syntax error in: \n" + TokensToStr(s,DEBUG_WITH_COLOR))
        if not s[0][1] == "{":return ValueError(self.name + " : body should start with '{': \n" + TokensToStr(s,DEBUG_WITH_COLOR))
        if not s[-1][1] == "}":return ValueError(self.name + " : missing closing '}': \n" + TokensToStr(s,DEBUG_WITH_COLOR))
        body = Statements()
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
        par = Block()
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
        body =Statements()
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

class UnaryOperation(Node):
    """
    Base class for all unary operations.
    """
    name = "UnOp"
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

class List(UnaryOperation):
    """
    Example:
    ```
    L = list 4;
    ```
    This creates a list with size of 4 with null values as elements
    ```
    L = (1,2,3);
    ```
    This creates a list of size 3 with elements 1, 2, 3
    Lists need not contain elements of a particular type.
    Lists are concatenated using the + operator.
    """
    name = "List"
    opname = "list"
    def other(self):return SOPLogic()
    def op(self,x):
        if isinstance(x,int):return [None]*x
        if isinstance(x,list):return x
        if isinstance(x,ndarray):return list(x)

class Vector(UnaryOperation):
    """
    These are basically numpy's ndarrays
    Example:
    ```
    x = [1,1,0];
    print 2*x;
    ```
    This will output `[2,2,0]` as the output.
    """
    name = "Vector"
    opname = "vec"
    def other(self):return SOPLogic()
    def op(self,x):
        if x is None: raise ValueError("give the size of the array please")
        if isinstance(x,int):return zeros(x)
        if isinstance(x,list):return array(x)
        if isinstance(x,ndarray):
            x = tuple(x.astype("i"))
            size = prod(x)
            if size >1e6:raise ValueError(f"Cannot allocate memory for vector of shape {x}")
            return zeros(x)

class BinaryOperation(Node):
    """
    Base class for single binary operations
    """
    name = "BinOp"
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

class MultipleBinaryOperation(Node):
    """
    Base class for non-terminals that implement
    many binary operations at same level of precedence,
    and same associativity (left,right)
    """
    name = "MultiBinOp"
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

class Statements(Node):
    """
    Many statements. A statement can be classified in 5 main categories:

    1. a `while` loop
    2. an `if` condition
    3. `elif`
    4. `else`
    5. Single line statements

    Single statements ends with a `;`, while others use {..} syntax
    """
    name = "Statements"
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
                    if s[0][1] == "while":Left = Loop()
                    elif s[0][1] == "elif":Left = ElseIfStatement()
                    elif s[0][1] == "else":Left = ElseStatement()
                    elif s[0][1] == "if":Left = IfStatement()
                    else:continue
                    Right = Statements()
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
                    Left = SingleStatement()
                    Right = Statements()
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

class Loop(Node):
    """
    While loops
    """
    name = "Loop"
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
                cs0 = SOPLogic()
                f = Block()
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
            if isinstance(x,Break):
                SYMBOLS["LASTCONDITION"] = True
                break
            if isinstance(x,Continue):continue
            if x is not None:return x
            br -= 1
        else:SYMBOLS["LASTCONDITION"] = False
        if br <= 0 : print("broken while because it took over 10^9 loops")

class Break(Node):
    """
    Implements the `breakloop`
    """
    def parse(self,s:list):
        n = len(s)
        if not n == 1:return ValueError("break statements only have the `breakloop` keyword:\n" + TokensToStr(s,DEBUG_WITH_COLOR))
        if not s[0][1] == "breakloop":return ValueError("break statements start with `breakloop`:\n" + TokensToStr(s,DEBUG_WITH_COLOR))
        self.children = [Token("breakloop")]
    def eval(self):
        return self

class Continue(Node):
    """
    Implements the `skipit` statements
    """
    def parse(self,s:list):
        n = len(s)
        if not n == 1:return ValueError("skip statements only have the `skipit` keyword:\n" + TokensToStr(s,DEBUG_WITH_COLOR))
        if not s[0][1] == "skipit":return ValueError("skip statements start with `skipit`:\n" + TokensToStr(s,DEBUG_WITH_COLOR))
        self.children = [Token("skipit")]
    def eval(self):
        return self

class IfStatement(Node):
    name = "If"
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
                cs0 = SOPLogic()
                s0 = Statements()
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

class ElseIfStatement(Node):
    name = "ElseIfStatement"
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
                cs0 = SOPLogic()
                s0 = Statements()
                try:res = cs0.parse(condition)
                except:continue
                if isinstance(res,ValueError):
                    last_err = res
                    continue
                try:res=s0.parse(code)
                except:continue
                if isinstance(res,ValueError):
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

class ElseStatement(Node):
    name = "ElseStatement"
    def parse(self,s:list):
        n = len(s)
        on_wrong = self.name + f" : syntax error in: \n" + TokensToStr(s,DEBUG_WITH_COLOR)
        if not n >= 3           :return ValueError(on_wrong)
        if not s[0][1] == "else":return ValueError(on_wrong)
        if not s[-1][1] == "}"  :return ValueError(on_wrong)
        if not s[1][1] == "{"   :return ValueError(on_wrong)
        code = Block()
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
        if SYMBOLS["LASTCONDITION"]:return
        SYMBOLS["LASTCONDITION"] = True
        return code.eval()

class SingleStatement(Node):
    name = "SingleStatement"
    def parse(self,s:list):
        n =len(s)
        on_wrong = self.name + f" : syntax error in: \n" + TokensToStr(s,DEBUG_WITH_COLOR)
        self.value = s
        if not n > 1:return ValueError(on_wrong)
        if not s[-1][1] == ";":return ValueError(on_wrong)
        right = Token(";")
        if s[0][1] == "print":left = PrintStatement()
        elif s[0][1] == "run":left = RunStatement()
        elif s[0][1] == "dict":left = Dictionary()
        elif s[0][1] == "return":left = ReturnStatement()
        elif s[0][1] == "plot":left = PlotStatement()
        elif s[0][1] == "breakloop":left = Break()
        elif s[0][1] == "skipit":left = Continue()
        elif s[0][1] == "let":left = Definition()
        elif s[0][1] == "delete":left = Deletion()
        else:left = Assignment()
        try:res = left.parse(s[:-1])
        except:return ValueError(on_wrong)
        if isinstance(res,ValueError):return ValueError(on_wrong,res)
        self.children = [left,right]
    def eval(self):
        L = self.children
        assert len(L) == 2
        return L[0].eval()

class Definition(Node):
    """
    Defines a variable in the innermost scope
    """
    name = "Def"
    opname = "="
    left_associative =False
    def parse(self,s:list):
        n = len(s)
        on_wrong = "incorrect definition:\n" + TokensToStr(s,DEBUG_WITH_COLOR)
        if not n>=2: return ValueError(on_wrong)
        if not s[0][1] == "let": return ValueError(on_wrong)
        child = Token("let")
        self.children = [child]
        if not s[1][0] == "id": return ValueError(on_wrong)
        if s[1][1] in RESTRICTED: return ValueError(f"cannot set the read-only variable {s[1][1]} :\n" + TokensToStr(s,DEBUG_WITH_COLOR))
        child = Id(s[1][1])
        self.children.append(child)
        if n == 2:return
        if not s[2][1]=="=": return ValueError(on_wrong)
        child = Token("=")
        self.children.append(child)
        if n == 3: return ValueError("empty RHS in definition:\n" + TokensToStr(s,DEBUG_WITH_COLOR))
        right = s[3:]
        if right[0][1] == "{":Right = Block()
        elif right[0][1] == "list":Right = List()
        elif right[0][1] == "vec":Right = Vector()
        else: Right = SOPLogic()
        try:res = Right.parse(right)
        except:return ValueError(on_wrong)
        if isinstance(res,ValueError):return ValueError(on_wrong,res)
        self.children.append(Right)
    def eval(self):
        global SYMBOLSTACK
        L = self.children
        n = len(L)
        assert n >=2
        SYMBOL = SYMBOLSTACK[-1]
        name = L[1].name
        if n == 2:SYMBOL[name] = None
        elif n == 4:
            value = L[3].eval()
            SYMBOL[name] = value
        else: raise ValueError(f"n = {n} ..how?")

class Assignment(Node):
    """
    Updates the value of variable found in the innermost scope, till now.
    If no variable found, throws an error.
    """
    name = "Assignment"
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
                Left = Assignable()
                if right[0][1] == "{":Right = Block()
                elif right[0][1] == "list":Right = List()
                elif right[0][1] == "vec":Right = Vector()
                else: Right = SOPLogic()
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
        #if isinstance(L[2],Block) and L[2].name == "Block":
        #    L[0].update(L[2])
        #else:
        value = L[2].eval()
        L[0].update(value)

class PrintStatement(Node):
    name:"PrintStatement"
    def parse(self,s:list):
        n = len(s)
        on_wrong = f"incorrect print statement: \n" + TokensToStr(s,DEBUG_WITH_COLOR)
        assert n > 0
        x = s[0]
        assert x[1] == "print"
        Left = Token(x[1])
        Right = SOPLogic()
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
        if isinstance(x,Block):x = x.prepr()
        if not TESTING:print(x,end = "")

class PlotStatement(Node):
    name:"plot"
    def parse(self,s:list):
        n = len(s)
        on_wrong = "incorrect plot statement: \n" + TokensToStr(s,DEBUG_WITH_COLOR)
        assert n > 0
        x = s[0]
        assert x[1] == "plot"
        Left = Token(x[1])
        Right = CommaSeparatedValues()
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

class RunStatement(Node):
    """
    Runs an algorithm.
    Algorithms are ran without any arguments by default.
    Use the `with` keyword to specify arguments.
    Example:
    ```
    f = alg (x,y){print x + y;};
    run f with (1,2);
    ```
    """
    name:"RunStatement"
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
                Fun = SOPLogic()
                Arg = CommaSeparatedValues()
                try:res= Fun.parse(s[1:i])
                except:return ValueError(on_wrong)
                if isinstance(res,ValueError):return ValueError(on_wrong,res)
                try:res= Arg.parse(s[i+1:])
                except:return ValueError(on_wrong)
                if isinstance(res,ValueError):return ValueError(on_wrong,res)
                self.children = [Left,Fun,Token("with"),Arg]
                return
        Fun = SOPLogic()
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
        assert isinstance(f,Block) or isinstance(f,SysCall)
        if n==4:
            Arg = L[3]
            arg = Arg.eval(True)
            if arg is None:arg = []
            elif not isinstance(arg,list):arg = [arg]
        else:
            arg = []
        SYMBOLS =DEFAULT_SYMBOLS.copy()
        SYMBOLSTACK.append(SYMBOLS)
        to_ret = f.eval(arg)
        SYMBOLSTACK.pop()
        SYMBOLS = SYMBOLSTACK[-1]

class ReturnStatement(Node):
    """
    These are the only kind of statements that return a value upon calling `eval`.
    When this happens in the `eval` for `Statements`, the value is returned there too.
    """
    name:"ReturnStatement"
    def parse(self,s:list):
        self.value = s
        on_wrong = "incorrect return statement :\n" + TokensToStr(s,DEBUG_WITH_COLOR)
        n = len(s)
        assert n > 0
        x = s[0]
        assert x[1] == "return"
        Left = Token(x[1])
        Right = SOPLogic()
        try:res = Right.parse(s[1:])
        except:return ValueError(on_wrong)
        if isinstance(res,ValueError):return ValueError(on_wrong,res)
        self.children = [Left,Right]
    def eval(self):
        L = self.children
        n = len(L)
        assert n == 2
        return L[1].eval()

class Dictionary(Node):
    """
    Initialises an empty dictionary for a new variable, or location in list.
    Example 1:
    ```
    dict D;
    D["x"]=1;
    ```
    Example 2:
    ```
    let L = list 2;
    dict L[0];
    ```
    """
    name:"Dictionary"
    def parse(self,s:list):
        self.value = s
        on_wrong = "incorrect dictionary initialisation :\n" + TokensToStr(s,DEBUG_WITH_COLOR)
        n = len(s)
        assert n > 0
        x = s[0]
        assert x[1] == "dict"
        Left = Token(x[1])
        if n == 2:
            if not s[1][0] == "id":return ValueError(on_wrong)
            Right = Id(s[1][1])
        else:
            Right = Assignable()
            try:res = Right.parse(s[1:])
            except:return ValueError(on_wrong)
            if isinstance(res,ValueError):return ValueError(on_wrong,res)
        self.children = [Left,Right]
    def eval(self):
        L = self.children
        n = len(L)
        assert n == 2
        if isinstance(L[1],Id):
            SYMBOLS = SYMBOLSTACK[-1]
            SYMBOLS[L[1].name] = {}
        else : L[1].update(dict())

class SOPLogic(BinaryOperation):
    """
    SOPLogic -> MinTerm `or` SOPLogic | MinTerm
    """
    name = "SOPLogic"
    opname = "or"
    def duplicate(self):return SOPLogic()
    def other(self):return MinTerm()
    def op(self,x,y):return x or y

class MinTerm(BinaryOperation):
    """
    MinTerm -> LogicLiteral and MinTerm | LogicLiteral
    """
    name = "MinTerm"
    opname = "and"
    def duplicate(self):return MinTerm()
    def other(self):return LogicLiteral()
    def op(self,x,y):return x and y

class LogicLiteral(UnaryOperation):
    """
    LogicLiteral -> not Comparison | Comparison
    """
    name = "LogicLiteral"
    opname = "not"
    def other(self):return Comparison()
    def op(self,x):return not x

class Comparison(MultipleBinaryOperation):
    """
    Comparison -> Expression == Expression
    Comparison -> Expression >  Expression
    Comparison -> Expression <  Expression
    Comparison -> Expression >= Expression
    Comparison -> Expression <= Expression
    Comparison -> Expression != Expression
    """
    name = "Comparison"
    opnames = ["==",">","<",">=","<=","!="]
    left_associative = True
    def duplicate(self):return Expression()
    def other(self):return Expression()
    def op(self,x,y,operation):
        if operation == "==" : return x == y
        if operation == ">" : return x > y
        if operation == "<" : return x < y
        if operation == ">=" : return x >= y
        if operation == "<=" : return x <= y
        if operation == "!=" : return x != y
        else:raise ValueError(f"unrecognised binary operation {operation}")

class Expression(MultipleBinaryOperation):
    """
    Expression -> Expression + Term
    Expression -> Expression - Term
    """
    name = "Expression"
    opnames = ["+","-"]
    left_associative = True
    def duplicate(self):return Expression()
    def other(self):return Term()
    def op(self,x,y,operation):
        if operation == "+" : return x+y
        if operation == "-" : return x-y
        else:print("This is not good")

class Term(MultipleBinaryOperation):
    """
    Term -> Term * ExponentTower
    Term -> Term / ExponentTower
    Term -> Term // ExponentTower | Term div ExponentTower
    Term -> Term % ExponentTower | Term mod ExponentTower
    """
    name = "Term"
    opnames = ["*","/","//","%","mod","div"]
    left_associative = True
    def duplicate(self):return Term()
    def other(self):return ExponentTower()
    def op(self,x,y,operation):
        if operation == "*" : return x*y
        if operation == "/" : return x/y
        if operation == "//" : return x//y
        if operation == "%" : return x%y
        if operation == "div" : return x//y
        if operation == "mod" : return x%y
        else:raise ValueError(f"unrecognised binary operation {operation}")

class ExponentTower(MultipleBinaryOperation):
    """
    ExponentTower -> SignedValue ** ExponentTower
    """
    name = "ExponentTower"
    opnames = ["**","^"]
    left_associative = False
    def duplicate(self):return ExponentTower()
    def other(self):return SignedValue()
    def op(self,x,y,operation):
        if operation == "**" : return x**y
        if operation == "^" : return x**y
        else:raise ValueError(f"unrecognised binary operation {operation}")

class SignedValue(UnaryOperation):
    """
    SignedValue -> - EnclosedValues | EnclosedValues
    """
    name = "SignedValue"
    opname = "-"
    def other(self):return EnclosedValues()
    def op(self,x):return -x

class EnclosedValues(Node):
    """
    EnclosedValues -> ( CommaSeparatedValues )
    EnclosedValues -> [ CommaSeparatedValues ]
    EnclosedValues -> Value
    """
    name = "EnclosedValues"
    def parse(self,s:list):
        self.value = s
        n = len(s)
        assert n > 0
        if s[0][1] == "(":
            assert s[-1][1] == ")",f"syntax error in {s}"
            Left =Token("(")
            Right =Token(")")
            Middle = CommaSeparatedValues()
            Middle.parse(s[1:-1])
            self.children = [Left,Middle,Right]
        elif s[0][1] == "[":
            assert s[-1][1] == "]",f"syntax error in {s}"
            Left =Token("[")
            Right =Token("]")
            Middle = CommaSeparatedValues()
            Middle.parse(s[1:-1])
            self.children = [Left,Middle,Right]
        else:
            child = Value()
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
                if x is None:return array([])
                elif not isinstance(x,list):x = array([x])
                return array(x)

class Value(Node):
    name = "Value"
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
            t = Algorithm()
            t.parse(s)
        elif s[0][0] == "id" and s[1][1] == "(" and s[-1][1] == ")":
            t =FunctionCall()
            t.parse(s)
        else:
            t = Assignable()
            t.parse(s)
        self.children = [t]
    def eval(self):
        assert len(self.children) == 1
        child = self.children[0]
        return child.eval()

def SymbolsNeeded(node):
    """
    Returns a set of all the identifiers that occur in the AST with given node as head
    """
    if isinstance(node,Id):return {node.name}
    elif isinstance(node,Token):return set()
    need = set()
    for child in node.children:
        need = need.union(SymbolsNeeded(child))
    return need

class Algorithm(Node):
    """
    Used to create algorithms from Blocks, with the keyword `alg`.
    Example:
    ```
    f = alg(x){print x;};
    ```
    """
    name = "Algorithm"
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
                    right = Block()
                    res = right.parse(s[i+1:])
                    if isinstance(res,ValueError):raise ValueError("Function body wasn't parsed")
                    left = Token("alg")
                    middle = Arguments()
                    middle.parse(s[1:i+1])
                    self.children = [left,middle,right]
                    return
        except:
            raise ValueError("Algorithm definition failed")
    def eval(self):
        global SymbolsNeeded,SYMBOLSTACK
        kw,arg,f = self.children
        arg = arg.eval()
        assert isinstance(f,Block)
        f.args = tuple(arg)
        S = SYMBOLSTACK[-1]
        f.env = {k:S[k] for k in S if k in SymbolsNeeded(f)}
        return f

class Arguments(Node):
    """
    Comma Separated Identifiers (not values).
    This returns a list of names (not values) of identifiers on `eval`
    Mainly used for algorithm definition
    """
    name = "Arguments"
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

class CommaSeparatedValues(Node):
    name = "CommaSeparatedValues"
    def parse(self,s):
        self.value = s
        n = len(s)
        children = []
        stack = []
        for i in range(0,n):
            if s[i][1] != ",":
                stack.append(s[i])
            else:
                try:
                    child = SOPLogic()
                    child.parse(stack)
                    children.append(child)
                    children.append(Token(","))
                    stack = []
                except:stack.append(s[i])
        if stack:
            child = SOPLogic()
            child.parse(stack)
            children.append(child)
        self.children = children
    def eval(self,wrap=False):
        if not wrap and len(self.children) == 0:return None
        if not wrap and len(self.children) == 1:return self.children[0].eval()
        return  [x.eval() for x in self.children[::2]]

class FunctionCall(Node):
    """
    Example:
    ```
    let f = alg(x){return x*2;};
    print f(2); #This is a function call
    ```
    """
    name = "FunctionCall"
    def parse(self,s):
        self.value = s
        n = len(s)
        assert n >= 3
        assert s[0][0] == "id"
        assert s[1][1] == "("
        assert s[-1][1] == ")"
        right = CommaSeparatedValues()
        right.parse(s[2:-1])
        left = Id(s[0][1])
        self.children = [left,Token("("),right,Token(")")]
    def eval(self):
        left,op,right,ed = self.children
        f = left.eval()
        assert isinstance(f,Block) or isinstance(f,SysCall), f"{left.name} is not callable"
        assert isinstance(right,CommaSeparatedValues)
        SYMBOLS = DEFAULT_SYMBOLS.copy()
        SYMBOLSTACK.append(SYMBOLS)
        args = right.eval(True)
        if args is None:args = []
        elif not isinstance(args,list):args = [args]
        to_ret = f.eval(args)
        SYMBOLSTACK.pop()
        return to_ret

class SysCall:
    def __init__(self,name,f):
        self.name = name
        self.f = f
    def eval(self,args):
        try: return self.f(*args)
        except Exception as e:
            raise ValueError(f"Error in {self.name} : {e}")


class Assignable(Node):
    """
    Either just an identifier (`x`), or an identifier with an index (`L[1+2]`).
    Returns the value upon `eval`.
    Updates the value upon `update`
    """
    name = "Assignable"
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
            Middle = Expression()
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
        if x in RESTRICTED:raise ValueError(f"trying to update read only variable {x}")
        for SYMBOLS in SYMBOLSTACK[::-1]:
            if x in SYMBOLS:break
        else:raise ValueError(f"couldn't find variable {x}")
        if n == 1:
            SYMBOLS[x] = value
        elif n == 4:
            ind = L[2].eval()
            SYMBOLS[x][ind] = value
        else:raise ValueError("This shouldn't be happening")

class Deletion(Node):
    """
    Deletes a variable from a dictionary
    Example:
    ```
    dict D;
    D["x"] = 1;
    delete "x" from D;
    ```
    """
    name = "Delete"
    def parse(self,s):
        self.value = s
        on_wrong = "incorrect delete statement :\n" + TokensToStr(s,DEBUG_WITH_COLOR)
        n = len(s)
        if not n == 4 : return ValueError(on_wrong)
        if not s[0][1] == "delete" : return ValueError(on_wrong)
        if not s[1][0] == "str" : return ValueError(on_wrong)
        if not s[2][1] == "from" : return ValueError(on_wrong)
        if not s[3][0] == "id" : return ValueError(on_wrong)
        self.children = [Token("delete"),Str(s[1][1]),Token("from"),Id(s[3][1])]
    def eval(self):
        L = self.children
        x = L[3].name
        if x in RESTRICTED:raise ValueError(f"trying to delete read only variable {x}")
        x = L[3].eval()
        if isinstance(x,ValueError):raise x
        if not isinstance(x,dict):raise ValueError(f"trying to delete from a non-dictionary {x}")
        key = L[1].eval()
        if key in x:x.pop(key)
        else:raise ValueError(f"key {key} not found in {x}")


def TakeIn(prompt:str=""):
    """
    Takes in input from the user
    """
    global DEBUG_WITH_COLOR
    if DEBUG_WITH_COLOR:prompt = prompt + "\x1b[38;2;0;100;255m\n> \x1b[38;2;0;255;0m"
    x = input(prompt)
    print("\x1b[0m")
    try:return int(x)
    except:
        try:return float(x)
        except:return x

def PushIn(L:list,x):
    """
    Pushes a new element into a list
    """
    if isinstance(L,list):L.append(x)
    else:raise ValueError(f"trying to push into a non-list {L}")

def PopOut(L,i=0):
    """
    Pops the last element from a list
    """
    if isinstance(L,list):
        if i >= len(L):raise ValueError(f"trying to pop and index not present in {L}")
        else : return L.pop()
    elif isinstance(L,dict):
        if i not in L:raise ValueError(f"trying to pop and index not present in {L}")
        else : return L.pop(i)
    else:raise ValueError(f"trying to pop from a non-list {L}")

def GetLength(L):
    """
    Returns the length of a list
    """
    if isinstance(L,list) or isinstance(L,dict):return len(L)
    if isinstance(L,ndarray):return L.shape[0]
    else:raise ValueError(f"trying to get length of a non-list {L}")

def GetKeys(L):
    """
    Returns the keys of an iterable
    """
    if isinstance(L,dict):return list(L.keys())
    elif isinstance(L,list):return list(range(len(L)))
    elif isinstance(L,ndarray):return list(range(L.shape[0]))
    else:raise ValueError(f"trying to get keys of a non-dictionary {L}")

def ReadFile(path):
    """
    Reads the content of a file
    """
    try:
        f = open(path)
        s = f.read()
        f.close()
        return s
    except:return ValueError(f"couldn't read from {path}")

def WriteFile(path,s=""):
    """
    Writes the content to a file
    """
    try:
        f = open(path,'w')
        f.write(s)
        f.close()
        return 1
    except:return ValueError(f"couldn't write to {path}")

DEFAULT_SYMBOLS = {
    "nl":"\n",
    "tab":"\t",
    "LASTCONDITION":True,
    "true":True,
    "false":False,
    "null":None,
    "input":SysCall("input",TakeIn),
    "int":SysCall("int",int),
    "float":SysCall("float",float),
    "str":SysCall("str",lambda x:str(to_tuple(x))),
    "push":SysCall("push",PushIn),
    "pop":SysCall("pop",PopOut),
    "len":SysCall("len",GetLength),
    "keys":SysCall("keys",GetKeys),
    "read":SysCall("read",ReadFile),
    "write":SysCall("write",WriteFile),
}

RESTRICTED = set(DEFAULT_SYMBOLS.keys())

SYMBOLSTACK = [DEFAULT_SYMBOLS.copy()]

def PrintError(Err):
    assert isinstance(Err,ValueError),"Not an error"
    args = Err.args
    if len(args) == 1:
        print(args[0],"\n")
        return
    m,Err = args
    print(m,"\n")
    PrintError(Err)

def RunPretty(s,vis=False):
    global TESTING,SYMBOLSTACK,DEFAULT_SYMBOLS
    SYMBOLSTACK = [DEFAULT_SYMBOLS.copy()]
    print("_"*50 + "\n")
    print("Program")
    print("_"*50 + "\n")
    if DEBUG_WITH_COLOR:print(HighLight(s))
    else:print(TokensToStr(lex(s,True,True),color =False))
    print("_"*50 + "\n")
    s = lex(s)
    s0 = Statements()
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
        #if DEBUG_WITH_COLOR:print("\x1b[38;2;0;255;0mFinished\x1b[0m")
        #else:print("Finished")
        #print("_"*50 + "\n")
        if vis == "True":
            s0.PlotTree()
            Graph.render(file + ".png",format='png',view=True)

def RunFilePretty(filename,vis=False):
    try:file = open(filename,'r')
    except:
        print(filename,"not found in this directory")
        return
    s = file.read()
    RunPretty(s,vis)

def TestFile(filename):
    global TESTING,SYMBOLSTACK,DEFAULT_SYMBOLS
    old_TESTING = TESTING
    TESTING = True
    SYMBOLSTACK = [DEFAULT_SYMBOLS.copy()]
    try:file = open(filename,'r')
    except:
        print(filename,"not found in this directory")
        TESTING = old_TESTING
        return
    try:s = file.read()
    except:
        print("couldn't read from",filename)
        TESTING = old_TESTING
        return
    try:s = lex(s)
    except:
        print("lexing failed on",filename)
        TESTING = old_TESTING
        return
    s0 = Statements()
    try:res = s0.parse(s)
    except:
        print(filename,"crashed before giving a respnese")
        TESTING = old_TESTING
        return
    if isinstance(res,ValueError):
        print("compilation error in",filename)
        TESTING = old_TESTING
        return
    try:s0.eval()
    except Exception as e:
        print("Run-time error in",filename,":",e)
        TESTING = old_TESTING
        return
    print(filename,"ran")
    TESTING = old_TESTING

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("file")
    parser.add_argument("vis")
    args = parser.parse_args()
    file = args.file
    vis = args.vis
    RunFilePretty(file,vis)