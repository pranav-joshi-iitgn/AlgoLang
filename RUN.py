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