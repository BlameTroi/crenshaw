# cradle.py, from the Crenshaw tutorial pascal version
# first version is a transliteration 

import sys

# globals

tab = "\t"
look = ""

#
# read next character
#
# whole lines are buffered when interactive, but
# this still works
#
def getchar():
    global look     # <-- 
    look = sys.stdin.read(1)
    if not look:
        look = "$"
        print("end of file")

#
# report error
#
def error(s):
    print("\nError:  " + s + ".")

#
# report error and halt
#
def abort(s):
    error(s)
    sys.exit(-1)

#
# report a missing expected token
#
def expected(s):
    abort(s + " expected")

#
# match a specific input character
#
def match(x):
    if look == x:
        getchar()
    else:
        expected("'" + x + "'")

#
# recognize an alpha character
#
# this name is from the original pascal
# version. it isn't really a collision with
# the string and bytearray functions.
#
def isalpha(c):
    return c[0].isalpha()

#
# recognize a decimal digit
#
# this name is from the original pascal
# version. it isn't really a collision with
# the string and bytearray functions.
#
def isdigit(c):
    return c[0].isdigit()

#
# recognize an addop
#
def isaddop(c):
    return c[0] in ["+", "-"]

#
# recognize a mulop
def ismulop(c):
    return c[0] in ["*", "/"]

#
# get an identifier
def getname():
    if not isalpha(look):
        expected("Name")
    n = look.upper(look)
    getchar()
    return n

#
# get a number
def getnum():
    if not isdigit(look):
        expected("Integer")
    n = look;
    getchar()
    return n

#
# outputs
#
def emit(s):
    sys.stdout.write("\t" + s)

def emitln(s):
    sys.stdout.write("\t" + s + "\n")

#
# initialization
#
# just prime the character pump.
#
def init():
    getchar();

#
# mainline
#
def main():
    init()

#
# run as script
#
if __name__ == "__main__":
    main()
