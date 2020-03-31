# cradle.py, from the Crenshaw tutorial pascal version
# first version is a transliteration 

import sys

#
# globals
#

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
# outputs
#
def emit(s):
    sys.stdout.write("\t" + s)

def emitln(s):
    sys.stdout.write("\t" + s + "\n")

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
# recognize an alphanumeric
#
def isalnum(c):
    return isalpha(c) or isdigit(c)

#
# recognize an addop
#
def isaddop(c):
    return c[0] in ["+", "-"]

#
# recognize a mulop
#
def ismulop(c):
    return c[0] in ["*", "/"]

#
# get an identifier
#
def getname():
    if not isalpha(look):
        expected("Name")
    n = look.upper()
    getchar()
    return n

#
# get a number
#
def getnum():
    if not isdigit(look):
        expected("Integer")
    n = look;
    getchar()
    return n

#
# parse and translate a factor
# where factor is a single digit or:
#
# <factor> ::= (<expression>)
#
def factor():
    if look == "(":
        match("(")
        expression()
        match(")")
    else:
        emitln("MOVE #" + getnum() + ",D0")

#
# handle a multiply
#
def multiply():
    match("*")
    factor()
    emitln("MULS (SP)+,D0")

#
# handle a divide
#
def divide():
    match("/")
    factor()
    emitln("MOVE (SP)+,D1")
    emitln("DIVS D1,D0")

#
# parse and translate a term
#
# where:
#
# term ::= <factor> [ <mulop> <factor> ]*
#
def term():
    factor()
    while ismulop(look): 
        emitln("MOVE D0,-(SP)")
        if look == "*":
            multiply()
        elif look == "/":
            divide()
        else:
            expected("mulop")

#
# handle addition
#
def add():
    match("+")
    term()
    emitln("ADD (SP)+,D0")

#
# handle subtraction
#
def subtract():
    match("-")
    term()
    emitln("SUB (SP)+,D0")
    emitln("NEG D0")

#
# parse and translate an expression
# the prior version had an overly simplistic definition
# of expression. a more correct definition is:
#
# <expression> ::= <term> [<addop> <term>]*
#
def expression():
    if isaddop(look):
        emitln("CLR D0")
    else:
        term()
    while isaddop(look):
        emitln("MOVE D0,-(SP)")
        if look == "+":
            add()
        elif look == "-":
            subtract()
        else:
            expected("addop")

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
    expression()

#
# run as script
#
if __name__ == "__main__":
    main()
