"""
This is the main parser module.
This contains required classes for AST construction, with each class having these methods
1. parse : parses given tokens and creates a subtree
2. eval : tree walk evaluation
3. MIPS : compilation of subtree's code to MIPS
There are also helper functions for testing and running.

AUTHOR: Pranav Joshi
email : pranav.joshi@iitgn.ac.in
Roll  : 22110197
"""

from LEXER import *
import termplotlib as plt #for `plot` statement
from numpy import * #for vectors
import struct

# global variable for visualisation of AST
from graphviz import Digraph
Graph = Digraph("AST")
cur_node = 0
labels = 0

# settings
DEBUG_WITH_COLOR = False
TESTING = False
FAST = False

TYPES = {
    "int":["000","111"],
    "float":["001","010","101","110"],
    "str":["011"],
    "list":["011"],
    "alg":["100"],
}

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

    def MIPS(self):
        """
        Converts the AST to a program with MIPS32 ISA instructions.
        """
        L = self.children
        n = len(L)
        if n==0:return ""
        if n==1:return L[0].MIPS()
        raise RuntimeError(f"MIPS code generation not implemented for {self.name} yet")

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
    """
    Base class for numbers. Evaluates to complex numbers.
    """
    name = "Number"
    def eval(self):return complex(self.value)

class Int(Number):
    name = "int"
    Type = int
    def eval(self):return int(self.value)

    def MIPS(self):
        """
        Puts the value on the top of stack
        """
        if int(self.value) >= 2**31 or int(self.value) < -2**31:
            raise RuntimeError(f"integer {self.value} is too big.")
        return "\n".join([
            f"# int {self.value}",
            "addi $s1,$s1,-4",
            f"li $t1,{self.value}",
            "sw $t1,0($s1)"
        ])

class Float(Number):
    name = "float"
    Type = float
    def eval(self):return float(self.value)
    def MIPS(self):
        v = float(self.value)
        v = ''.join('{:08b}'.format(b) for b in struct.pack('>f', v))
        if v[:3] not in TYPES["float"]: raise RuntimeError(f"{self.value} is too large or small")
        v = int(v,2)
        return "\n".join([
            f"# float {self.value}",
            "addi $s1,$s1,-4",
            f"li $t1,{v}",
            "sw $t1,0($s1)"
        ])

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

    def MIPS(self):
        s = self.value
        n = len(s)
        code = [
            f'# putting "{s}" on heap ',
            "add $t0,$s5,$zero",
            f"addi $s5, $s5,{4*n+4}",
            f"addi $t1,$zero,{4*n} # add size at start",
            "sw $t1,0($t0)",
        ]
        for i,x in enumerate(s) : code.extend([
            f"addi $t1,$zero,{ord(x)} # {x}",
            f"sw $t1, {4*i+4}($t0)",
        ])
        code.extend([
            "# add the pointer on stack",
            "addi $s1,$s1,-4",
            "sw $t0,0($s1)",
        ])
        return "\n".join(code)

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

    def MIPS(self,up=False):
        """
        Gets the value of the identifier and puts it on stack.
        If `up` is set to `True` then it gets the top value in stack and updates the variable instead.

        If not present in current scope, it does back to the scope where the algorithm requiring the variable was defined.
        This is done recusrively, till eiher the variable is found, or we run out of scopes.

        Note : The "parent" scope in the tree eval parser is just the caller, while in this case, it is the creator of the function.
        """
        global labels,MIPSPrint
        x = self.value
        N = len(SYMBOLSTACK)
        code = [
            f"# getting {self.name}",
            "add $t0,$s0,$zero",
        ]
        for lev in range(N-1,-1,-1):
            SYMBOLS = SYMBOLSTACK[lev]
            if x in SYMBOLS:
                v = SYMBOLS[x]
                if not up:
                    code.extend([
                        "addi $s1,$s1,-4",
                        f"lw $t1,{-4*v}($t0)",
                        "sw $t1,0($s1)",
                    ])
                else:
                    code.extend([
                        "lw $t1,0($s1)",
                        f"sw $t1,{-4*v}($t0)",
                        "addi $s1,$s1,4",
                    ])
                return "\n".join(code)
            else:
                labels +=1
                code.extend([
                    "li $t5,0x7F000000",
                    "li $t6,0x1FFFFFFF",
                    "lw $t1,-8($t0) # self",
                    "and $t1,$t1,$t6",
                    "or $t1,$t1,$t5",
                    "lw $t2,0($t1) # parent",
                    "lw $t0,-4($t0)",
                    "lw $t3,-8($t0) # self_new",
                    f"beq $t3,$t2,label{labels}",
                    MIPSPrint("parent dead, checking for fake parent"),
                    "add $t3,$zero,$t0 # make a copy",
                    "lw $t0,-12($t0) # fake parent stack",
                    f"bne $t0,$zero,label{labels} # even the fake parent is dead .. 1 ",
                    "and $t2,$t2,$t6",
                    "or $t2,$t2,$t5",
                    "lw $t0,4($t2) # depend on fake parent",
                    "beq $t0,$zero,error # even the fake parent is dead ... 2",
                    "sw $t0,-12($t3) # update the fake parent",
                    f"label{labels}:# creator alive checking over",
                    ])
        raise RuntimeError(f"variable {x} not found in any scope")

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
    def MIPS(self):
        global SYMBOLSTACK
        body = self.children[1]
        SYMBOLS = SYMBOLSTACK[-1]
        code = body.MIPS(True)
        return code

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
    def MIPS(self):
        """
        Gets the value on the top of stack, operates on it,
        and stores replaces the old value on the top of stack with the new value.
        """
        L = self.children
        n = len(L)
        assert n > 0
        if n == 1:return L[0].MIPS()
        elif n == 2:
            op = self.mips_op
            if not isinstance(op,str):op = op()
            old = L[1].MIPS()
            return "\n".join([
                old,
                "",
                f"# {self.op}",
                "lw $t1,0($s1)",
                op,
                "sw $t1,0($s1)"
            ])

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

    def MIPS(self):
        """
        1. puts the value (say `n`) of the operand on the stack
        2. increments the heap pointer ($s5) by 4n+4.
        3. puts `4*n` as first thing in allocated space
        4. puts the old heap pointer value on the stack, replacing the operand.
        Note that the values in the heap array will be garbage values.
        TODO: We need to ensure that the user cannot use these values.
        """
        L = self.children
        n = len(L)
        if n > 2:raise RuntimeError("`list` keyword takes in an integer expression")
        right = L[1]
        right = right.MIPS()
        return "\n".join([right,open("helpers/list.s").read()])

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

    def MIPS(self):
        """
        1. Loads the 2 topmost values from stack into t2 and t1 (in that order)
        2. pops the stack once
        3. Operates on t1 and t2.
           This is usually what you have to write in the `mips_op` attribute (with type `str`) when you inherit from the Base Class.
        4. Replaces topmost stack value with the result value.
        """
        L = self.children
        n = len(L)
        if n == 1: return L[0].MIPS()
        assert n == 3
        if self.mips_op is None:raise RuntimeError(f"{self.name} is not implemented yet :(")
        old1 =  L[0].MIPS()
        old2 = L[2].MIPS()
        return "\n".join([
            old1,
            "",
            old2,
            "",
            "lw $t2,0($s1)",
            "addi $s1,$s1,4",
            "lw $t1,0($s1)",
            self.mips_op,
            "sw $t1,0($s1)"
        ])

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

    def MIPS(self):
        """
        1. Loads the 2 topmost values from stack into t2 and t1 (in that order)
        2. pops the stack once
        3. Operates on t1 and t2.
           This is usually what you have to write in the `mips_op` attribute (`list` type) when you inherit from the Base Class.
        4. Replaces topmost stack value with the result value.
        """
        L = self.children
        n = len(L)
        if n == 1: return L[0].MIPS()
        assert n == 3
        old1 =  L[0].MIPS()
        old2 = L[2].MIPS()
        if isinstance(self.mips_op,dict):middle = self.mips_op[L[1].value]
        else:middle = self.mips_op(L[1].value)
        if middle is None:raise RuntimeError(f"{L[1].value} is not implemented yet :(")
        return "\n".join([
            old1,
            "",
            old2,
            "",
            "lw $t2,0($s1)",
            "addi $s1,$s1,4",
            "lw $t1,0($s1)",
            middle,
            "sw $t1,0($s1)"
        ])

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
    def MIPS(self,root=True,start_label = "",end_label = ""):
        """
        initialises $t9 to 1 . This is analogous to the LASTCONDITION global variable
        Also sets $t8 to 1. This is never changed and is only for my own convenience.
        """
        global SYMBOLSTACK
        SYMBOLS = SYMBOLSTACK[-1]
        L = self.children
        n = len(L)
        if n == 0:return ""
        assert n == 2
        code1 = L[0].MIPS(start_label,end_label)
        code2 = L[1].MIPS(False,start_label,end_label)
        if root:
            code = [
                "addi $t8,$zero,1",#This is permanently going to stay like this
                "addi $t9,$zero,1",#make the LASTCONDITION to be true
                f"addi $s1,$s0,{-4*len(SYMBOLS)}",#make space for all the variables that will be used eventually
                "",code1,"",code2,
            ]
        else:code = [code1,"",code2]
        return "\n".join(code)

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

    def MIPS(self,start_label="",end_label=""):
        """
        Generates the MIPS code for the body and wraps in a loop.
        The start and end label are passed to the children recursively, so that break and continue statements work.
        """
        global labels
        L = self.children
        assert len(L) == 3
        condition = L[1]
        code = L[2].children[1]
        condition = condition.MIPS()
        labels += 1
        start_label = f"label{labels}_start"
        end_label = f"label{labels}_end"
        code = code.MIPS(False,start_label,end_label)
        return "\n".join([
            f"{start_label}: # while ",
            "",
            condition,
            ""
            "lw $t9,0($s1)",
            "addi $s1,$s1,4",
            "slt $t1,$zero,$t9",
            "slt $t9,$t9,$zero",
            "or $t9,$t9,$t1",
            f"beq $t9,$zero,{end_label}",
            "",
            code,
            "",
            f"j {start_label}",
            f"{end_label}: # end while",
        ])

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
    def MIPS(self,start_label="",end_label=""):
        return f"addi $t9,$zero,1\nj {end_label}"

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
    def MIPS(self,start_label="",end_label=""):
        return f"j {start_label}"

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

    def MIPS(self,start_label="",end_label=""):
        global labels
        L = self.children
        n = len(L)
        assert n == 5
        condition = L[1]
        code = L[3]
        SYMBOLS = SYMBOLSTACK[-1]
        code = code.MIPS(False,start_label,end_label)
        condition = condition.MIPS()
        labels += 1
        return "\n".join([
            "# Condition",
            "",
            condition,
            "",
            "lw $t9,0($s1) #get result of condition",
            "addi $s1,$s1,4 # delete a value",
            f"beq $t9,$zero,label{labels} # if",
            "",
            code,
            "",
            "addi $t9,$zero,1",
            f"label{labels}: # end if",
        ])

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

    def MIPS(self,start_label="",end_label=""):
        global labels
        L = self.children
        n = len(L)
        assert n == 5
        condition = L[1]
        code = L[3]
        SYMBOLS = SYMBOLSTACK[-1]
        code = code.MIPS(False,start_label,end_label)
        condition = condition.MIPS()
        labels += 1
        return "\n".join([
            "# Condition",
            "",
            condition,
            "",
            f"bne $t9,$zero,label{labels} # el..",
            "lw $t9,0($s1)",#get result of condition
            "addi $s1,$s1,4",# delete a value
            f"beq $t9,$zero,label{labels} # ..if",
            "",
            code,
            "",
            "addi $t9,$zero,1",
            f"label{labels}: # end elif",
        ])

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

    def MIPS(self,start_label="",end_label=""):
        global labels
        L = self.children
        n = len(L)
        assert n == 2
        code = L[1].children[1]
        code = code.MIPS(False)
        labels += 1
        return "\n".join([
            "# else",
            f"bne $t9,$zero,label{labels}",
            "",
            code,
            "",
            "addi $t9,$zero,1", # set LASTCONDITION to be true
            f"label{labels}: # end else",
        ])

class SingleStatement(Node):
    """
    Non terminal for generating single statements, i.e. the statement, followed by a `;` token.
    Currently, the statements supported are : 
    1. print
    2. run
    3. dict
    4. return
    5. plot
    6. breakloop
    7. skipit
    8. let
    9. delete
    """
    name = "SingleStatement"
    def parse(self,s:list):
        n =len(s)
        on_wrong = self.name + f" : syntax error in: \n" + TokensToStr(s,DEBUG_WITH_COLOR)
        self.value = s
        if not n > 1:return ValueError(on_wrong)
        if not s[-1][1] == ";":return ValueError(on_wrong)
        right = Token(";")
        if   s[0][1] == "print":left = PrintStatement()
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
    def MIPS(self,start_label="",end_label=""):
        """
        returns MIPS code for a single statement.
        """
        return self.children[0].MIPS(start_label,end_label)

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

    def MIPS(self,start_label="",end_label=""):
        L = self.children
        n = len(L)
        SYMBOLS = SYMBOLSTACK[-1]
        #if n > 2:raise RuntimeError("definition with assignment not done in MIPS yet :(")
        x = L[1].value # name of variable
        if x in SYMBOLS : return f"# {x} is {-4*SYMBOLS[x]}($s0)"
        v = max(list(SYMBOLS.values()) + [0]) + 1
        SYMBOLS[x] = v
        code =  f"# Definition : {x} is {-4*v}($s0)"
        if n == 2 : return code
        val = L[3].MIPS()
        code = "\n".join([
                code,
                "",
                val,
                "",
                "lw $t1,0($s1) # get value",
                f"addi $t0,$s0,{-4*v} # load variable address",
                f"sw $t1,0($t0) # update the value at variable address",
                "addi $s1,$s1,4 # remove the value on stack"
            ])
        return code

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
        value = L[2].eval()
        L[0].update(value)

    def MIPS(self,start_label="",end_label=""):
        L = self.children
        n = len(L)
        assert n == 3
        val = L[2].MIPS()
        ass = L[0].MIPS(True) # assigns 0($s1) to the value
        return "\n".join([
            val,
            "",
            "# Assignment",
            ass
        ])

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
        if not TESTING:print(x)
    
    def MIPS(self,start_label="",end_label=""):
        global labels
        L = self.children
        getval = L[1].MIPS()
        labels += 4
        return getval + "\n" + open("helpers/print.s").read().format(
            labels=labels,
            labelsm1=labels-1,
            labelsm2=labels-2,
            labelsm3=labels-3
        )

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
    def MIPS(self,start_label="",end_label=""):
        L = self.children
        getaddress = L[1].MIPS()
        if len(L) == 4:
            getargs = L[3].MIPS(True)
            N = len(L[3].children[::2])
        else:
            getargs = "# No arguments"
            N = 0
        return "\n ".join([
            getaddress,# Also puts current base value in $t0
            TypeCheck("alg"),
            open("helpers/run.s").read().format(getargs=getargs,p4Np12=4*N+12,m4Nm12=-4*N-12)
        ])

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

    def MIPS(self,start_label="",end_label=""):
        global labels
        val = self.children[1]
        val = val.MIPS()
        labels += 2
        recreate = True
        recreate = "" if recreate else "#"
        return val + "\n" + open("helpers/return.s").read().format(labels=labels,labelsm1=labels-1,recreate=recreate)
        return "\n".join([
            val,
            "# return",
            "lw $t0,0($s0)",

            "lw $t1,0($s1)",
            "sw $t1,0($s0)",
            "addi $t9,$zero,1",

            "add $s1,$s0,$zero",
            "add $s0,$zero,$t0",
            "jr $ra",
        ])

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

    mips_op = "or $t1,$t1,$t2"

class MinTerm(BinaryOperation):
    """
    MinTerm -> LogicLiteral and MinTerm | LogicLiteral
    """
    name = "MinTerm"
    opname = "and"
    def duplicate(self):return MinTerm()
    def other(self):return LogicLiteral()
    def op(self,x,y):return x and y

    mips_op = "and $t1,$t1,$t2"

class LogicLiteral(UnaryOperation):
    """
    LogicLiteral -> not Comparison | Comparison
    """
    name = "LogicLiteral"
    opname = "not"
    def other(self):return Comparison()
    def op(self,x):return not x

    mips_op = "sub $t1,$t8,$t1" # 1-t1

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

    mips_op = { # I won't allow comparisons between floats.. that is one messed up thing.
        "==":"\n".join([
                "slt $t3,$t1,$t2", # x < y
                "slt $t2,$t2,$t1", # x > y
                "or $t1,$t3,$t2", # (x<y) or (x>y)
                "sub $t1,$t8,$t1" # 1-t1
            ]),
        ">":"slt $t1,$t2,$t1",
        "<":"slt $t1,$t1,$t2",
        ">=":"\n".join([
                "slt $t1,$t1,$t2",
                "sub $t1,$t8,$t1" # 1-t1
            ]),
        "<=":"\n".join([
                "slt $t1,$t2,$t1",
                "sub $t1,$t8,$t1" # 1-t1
            ]),
        "!=":"\n".join([
                "slt $t3,$t1,$t2", # x < y
                "slt $t2,$t2,$t1", # x > y
                "or $t1,$t3,$t2", # (x<y) or (x>y)
            ]),
    }

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
    
    def mips_op(self,op:str):
        global labels,FAST
        op = {"+":"add","-":"sub"}[op]
        if FAST:return f"{op} $t1,$t1,$t2"
        labels += 4
        return open(f"helpers/{op}.s").read().format(
            labels = labels,
            labelsm1 = labels-1,
            labelsm2 = labels-2,
            labelsm3 = labels-3
        )

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

    mips_op_old = {
        "*":"\n".join([
            "mult $t1,$t2",
            "mflo $t1",
            "mfhi $t2",
        ]),
        "/":"\n".join([
            "div $t1,$t2",
            "mflo $t1",
            "mfhi $t2",
        ]),
        "//":"\n".join([
            "div $t1,$t2",
            "mflo $t1",
            "mfhi $t2",
        ]),
        "%":"\n".join([
            "div $t1,$t2",
            "mflo $t2",
            "mfhi $t1",
        ]),
        "div":"\n".join([
            "div $t1,$t2",
            "mfhi $t2",
            "mflo $t1",
        ]),
        "mod":"\n".join([
            "div $t1,$t2",
            "mflo $t2",
            "mfhi $t1",
        ]),
    }

    def mips_op(self,op:str):
        global labels
        if op == "*":
            #TODO:add support for integer times string
            labels += 4
            return open("helpers/mul.s").read().format(
                labels = labels,
                labelsm1 = labels - 1,
                labelsm2 = labels - 2,
                labelsm3 = labels - 3
            )
        elif op == "/":
            labels += 4
            return open("helpers/div.s").read().format(
                labels = labels,
                labelsm1 = labels - 1,
                labelsm2 = labels - 2,
                labelsm3 = labels - 3
            )
        else: return self.mips_op_old[op]

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
    
    def MIPS(self):
        global labels
        L = self.children
        n = len(L)
        if n == 1: return L[0].MIPS()
        assert n == 3
        old1 =  L[0].MIPS()
        old2 = L[2].MIPS()
        labels += 1
        return "\n ".join([
            old1,
            old2,
            open("helpers/exp.s").read().format(labels=labels)
        ])

class SignedValue(UnaryOperation):
    """
    SignedValue -> - EnclosedValues | EnclosedValues
    """
    name = "SignedValue"
    opname = "-"
    def other(self):return EnclosedValues()
    def op(self,x):return -x

    #mips_op = "sub $t1,$zero,$t1"
    def mips_op(self):
        global labels
        labels += 1
        return open("helpers/unary_sign.s").read().format(labels=labels)

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

    def MIPS(self):
        L = self.children
        assert L
        if len(L) == 1:return L[0].MIPS()
        elif len(L) == 3:
            if L[0].value == "(" and len(L[1].children) == 1 : return L[1].MIPS()
            #if L[0].value == "(":return L[1].MIPS()
            #elif L[0].value == "[":
            else:
                n = len(L[1].children)
                n = n - n//2
                return "\n".join([
                    "# get the elements of list, from left to right",
                    L[1].MIPS(wrap=False),
                    "",
                    f"addi $s5, {4*n} # make space for {n+1} elements on heap",
                    "\n".join(["\n".join([
                        f"# store element at index {n-1-i}",
                        f"lw $t1,{4*i}($s1)",
                        f"sw $t1,{-4*i-4}($s5)",
                        ]) for i in range(n)]),
                    f"addi $s1,{4 * (n-1)} # pop stack {n-1} times",
                    f"addi $t0,$s5,{-4*n -4} # old $s5 value",
                    f"sw $t0,0($s1) # store pointer on heap",
                    f"addi $t1,$zero,{4*n}",
                    "sw $t1,0($t0) # store 4n as first element"
                    ])

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

    def MIPS(self):
        assert len(self.children) == 1
        child = self.children[0]
        return child.MIPS()

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
    def MIPS(self):
        global labels,SYMBOLSTACK,SymbolsNeeded
        kw,arg,f = self.children
        SYMBOLSTACK.append({"creator-base":1,"self":2,"my-base":3})
        # This has invalid variables because of the `-`. The name doesn't really matter
        # All that matters is that the user should never be able to access -4($s0) and -12($s0) using just the language
        # This is because it holds the base of the creator on this algorithm and base of current algorithm
        arg = arg.MIPS()
        # TODO : Add f.env support so that the function can be returned.
        code = f.MIPS()
        labels += 2
        start = f"label{labels-1}"
        end = f"label{labels}"
        to_ret = open("helpers/alg.s").read().format(start=start,end=end,code=code,arg=arg)
        SYMBOLSTACK.pop()
        return to_ret

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

    def MIPS(self):
        global SYMBOLSTACK
        SYMBOLS = SYMBOLSTACK[-1]
        comments = []
        for x in self.eval():
            if x in SYMBOLS: continue
            SYMBOLS[x] = max(list(SYMBOLS.values()) + [0]) + 1
            comments.append(f"# {x} is {-4*SYMBOLS[x]}($s0)")
        return "\n".join(comments)

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

    def MIPS(self,wrap = False):
        L = self.children
        n = len(L)
        if not wrap and n == 0 : raise RuntimeError("empty `()` not allowed here")
        elif not wrap and n == 1:return self.children[0].MIPS()
        else : return "\n\n".join([x.MIPS() for x in self.children[::2]])

def TypeCheck(Type):
    global labels
    FirstThree = TYPES[Type] # This is a list of possible first 3 bits
    labels += 1
    to_ret =  "\n".join([
        f"# assert type is {Type}",
        "lw $t1,0($s1)",
        "srl $t1,$t1,29",
        "\n".join([f"addi $t2,$zero,{int(x,2)}\nbeq $t1,$t2,label{labels}" for x in FirstThree]),
        "j error # if wrong type",
        f"label{labels}:# type check over"
    ])
    return to_ret

def MIPSPrint(s:str):
    code = f"#Print {s}\naddi $v0,$zero,11\n"
    code += "\n".join([f"addi $a0,$zero,{ord(x)} #{x}\nsyscall" for x in s])
    code += "\naddi $a0,$zero,10 # newline\nsyscall\n"
    return code

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
        SYMBOLS["self"] = f
        SYMBOLSTACK.append(SYMBOLS)
        args = right.eval(True)
        if args is None:args = []
        elif not isinstance(args,list):args = [args]
        to_ret = f.eval(args)
        SYMBOLSTACK.pop()
        return to_ret
    def MIPS(self):
        """
        Prepares the stack for a function call
        jumps to the function
        undoes some of the changes done before the function call
        """
        L = self.children
        getaddress = L[0].MIPS()
        getargs = L[2].MIPS(True)
        N = len(L[2].children[::2])
        return " \n".join([
            getaddress,
            TypeCheck("alg"),
            open("helpers/fcall.s").read().format(getargs=getargs,p4Np12=4*N+12,m4Nm12=-4*N-12)
        ])

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
    def MIPS(self,up=False):
        """
        Generates MIPS code for setting and getting values on arrays, and variables.
        The code is self explanatory. Please read it
        """
        L = self.children
        n = len(L)
        assert n > 0
        v = L[0].value
        SYMBOLS = SYMBOLSTACK[-1]
        if v not in SYMBOLS:raise RuntimeError(f"variable {v} not defined yet.")
        v = SYMBOLS[v]
        if n ==1: return L[0].MIPS(up)
        assert n == 4
        getindex = L[2].MIPS()
        m4v = -4*v
        if not up:return "\n".join([
            "# Getting index",
            getindex,
            "",
            open("helpers/index_get.s").read().format(m4v=m4v),
            ])
        else:return "\n".join([
            "# Getting index",
            getindex,
            "",
            open("helpers/index_set.s").read().format(m4v=m4v),
            ])

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

class SysCall:
    def __init__(self,name,f):
        self.name = name
        self.f = f
    def eval(self,args):
        try: return self.f(*args)
        except Exception as e:raise ValueError(f"Error in {self.name} : {e}")

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

def set_defaults(D:dict):
    global DEFAULT_SYMBOLS
    DEFAULT_SYMBOLS = D

RESTRICTED = set(DEFAULT_SYMBOLS.keys())

SYMBOLSTACK = [DEFAULT_SYMBOLS.copy()]

def set_symbolstack(L:list):
    global SYMBOLSTACK
    SYMBOLSTACK = L

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

def ToMIPS(s:str,output_file=None,Format="spim"):
    global MIPSPrint
    set_defaults({"self":None,"parent":None})
    set_symbolstack([{"creator-base":1,"self":2,"parent":3}])
    s = lex(s)
    s0 = Statements()
    res = s0.parse(s)
    if isinstance(res,ValueError):
        PrintError(res)
        return
    mips_code = s0.MIPS(False)
    n = len(SYMBOLSTACK[-1])
    error_log = "error:" + MIPSPrint("ERROR")
    if Format == "cpulator":mips_code = open("helpers/cpulator.s").read().format(mips_code=mips_code,error_log = error_log,m4n=-4*n)
    elif Format == "spim":mips_code = open("helpers/spim.s").read().format(mips_code=mips_code,error_log = error_log,m4n=-4*n)
    else:raise ValueError("Unsupported format for output code")
    if output_file is not None:
        if output_file[-2:] != ".s": output_file = output_file + ".s"
        f=open(output_file,'w')
        f.write(mips_code)
        f.close()
        return True
    return mips_code

def FileToMIPS(file,output_file=None,Format='spim'):
    f = open(file,'r')
    s = f.read()
    f.close()
    return ToMIPS(s,output_file,Format)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("file")
    parser.add_argument("vis")
    args = parser.parse_args()
    file = args.file
    vis = args.vis
    RunFilePretty(file,vis)