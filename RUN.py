"""
This is a terminal utility that run the given AlgoLang
source code file using the tree-walk interpreter.

AUTHOR: Pranav Joshi
email : pranav.joshi@iitgn.ac.in
Roll  : 22110197
"""

import argparse
import SYNTAX
SYNTAX.DEBUG_WITH_COLOR = True
SYNTAX.TESTING = False
from SYNTAX import *
parser = argparse.ArgumentParser()
parser.add_argument("file")
args = parser.parse_args()
file = args.file
RunFilePretty(file,False)