digits = "0123456789"
alphas = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
dot = "."
brak = r"()[]{};,"
op1 = "+-<>*/"
op2 = "%!/^"
equal = "="
quotes = '"'
spaces = " \t"
comS = "#"
newline = "\n\r"

keywords = [
    "while","if",'else','elif',
    'in','and','or','not',
    "print",
    'run','list','return','alg',
    'with','vec','plot','break',
    'continue','mod','div','let'
]

chartypes = [
    digits,alphas,dot,brak,
    op1,op2,equal,quotes,
    spaces,newline,comS
]

def get_char_type(c):
    global chartypes
    assert len(c)==1
    for i,T in enumerate(chartypes):
        if c in T:return i
    else:return 11

DFA = {
#           0-9         a-Z,_   .           ()[]{};,        +,-,<,>,*,/     %,!,:   =       "           space   \n      #       unk
"":       [ "int",      "id",   "float",    "brak",         "op1",          "op2",  "op2",  "str_",     None,   None,   "com_", False,  ],
"str_":   [ "str_",     "str_", "str_",     "str_",         "str_",         "str_", "str_", "str",      "str_", "str_", "str_", "str_", ],
"str":    [ None,       None,   None,       None,           None,           None,   None,   None,       None,   None,   None,   False,  ],
"int":    [ "int",      None,   "float",    None,           None,           None,   None,   None,       None,   None,   None,   False,  ],
"float":  [ "float",    False,  False,      None,           None,           None,   None,   None,       None,   None,   None,   False,  ],
"id":     [ "id",       "id",   "id.",      None,           None,           None,   None,   None,       None,   None,   None,   False,  ],
"id.":    [ False,      "id",   False,      False,          False,          False,  False,  False,      False,  False,  False,  False,  ],
"brak":   [ None,       None,   None,       None,           None,           None,   None,   None,       None,   None,   None,   False,  ],
"op1":    [ None,       None,   None,       None,           "check",        None,   "op1=", None,       None,   None,   None,   False,  ],
"op2":    [ None,       None,   None,       None,           None,           None,   "op2=", None,       None,   None,   None,   False,  ],
"op12":   [ None,       None,   None,       None,           None,           None,   None,   None,       None,   None,   None,   False,  ],
"op1=":   [ None,       None,   None,       None,           None,           None,   None,   None,       None,   None,   None,   False,  ],
"op2=":   [ None,       None,   None,       None,           None,           None,   None,   None,       None,   None,   None,   False,  ],
"com_":   [ "com_",     "com_", "com_",     "com_",         "com_",         "com_", "com_", "com_",     "com_", "com",  "com_", "com_", ],
"com":    [ None,       None,   None,       None,           None,           None,   None,   None,       None,   None,   None,   False,  ],
}

def lex(s:str,keep_spaces = False,keep_comments = False):
    global get_char_type,DFA
    if not keep_comments: s = remove_comments(s)
    s = s + "\n"
    n = len(s)
    tokens = []
    current = ""
    state = ""
    i = 0
    while i < n:
        x = s[i]
        #print(tokens,repr(current),repr(state),repr(x))
        t = get_char_type(x)
        #print(t)
        ns = DFA[state][t]
        #print(ns)
        if ns == "check":
            if x == current: ns = "op12"
            else: ns = None
        #print(ns,"\n")
        if ns is False:raise ValueError(f"can't lex {current + s[i:].split()[0]}")
        elif ns is None:
            if current :
                if state == 'id' and current in keywords:state = "kw"
                token = (state,current)
                tokens.append(token)
            state = ""
            current = ""
            if x in spaces or x in newline:
                if keep_spaces : tokens.append(("sp",x))
                i+=1
        else:
            current = current + x
            state = ns
            i += 1
    return tokens


def remove_comments(s:str):
    s = s.split("\n")
    for i,x in enumerate(s):
        if not x : continue
        s[i] = x.split("#")[0]
    s = "\n".join(s)
    return s

COLOR = {
    "id":"\x1b[38;2;100;200;255m",#blue
    "str":"\x1b[38;2;170;50;50m",#red
    "int":"\x1b[38;2;0;255;0m",#green
    "float":"\x1b[38;2;0;255;0m",#green
    "kw":"\x1b[38;2;255;170;170m",#pink
    "op1":"\x1b[38;2;255;255;0m",#yellow
    "op2":"\x1b[38;2;255;255;0m",#yellow
    "op2=":"\x1b[38;2;255;255;0m",#yellow
    "op1=":"\x1b[38;2;255;255;0m",#yellow
    "op12":"\x1b[38;2;255;255;0m",#yellow
    "com":"\x1b[38;2;150;150;150m",#grayeen
}

def HighLight(s):
    tokens = lex(s,True,True)
    colored = []
    for x in tokens:
        t = x[1]
        if x[0] in COLOR: t= COLOR[x[0]] + t
        else: t= "\x1b[0m" + t
        colored.append(t)
    colored = "".join(colored)
    return colored

def TokensToStr(tokens,color=False):
    if len(tokens) > 10: tokens = tokens[:5] + [("","\n.....\n")]+  tokens[-5:]
    if not color :return " ".join([x[1] for x in tokens])
    colored = []
    for x in tokens:
        t = x[1]
        if x[0] in COLOR: t= COLOR[x[0]] + t
        else: t= "\x1b[0m" + t
        colored.append(t)
    colored.append("\x1b[0m")
    colored = " ".join(colored)
    return colored

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("file")
    args = parser.parse_args()
    file = args.file
    s = open(file).read()
    col_s = HighLight(s)
    print(col_s)