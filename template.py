#!/bin/env python
# hello.py - The first attempt to write something in Python
# 20170126, Ing. Ondrej DURAS (dury)
# ~/prog/pyTWIST/hello.py

## MANUAL ############################################################# {{{ 1

VERSION = 2017.012601
MANUAL  = """
NAME: Hello Python template
FILE: hello.py

DESCRIPTION:
  A simple templated, providing a basic 
  structure to write any tradition script.

USAGE:
  ./hello.py --colors --debug --echo something

PARAMETERS:
  --colors     - turns ON the usage of terminal colors
  --no-color   - turns OFF the usage of TTY colors
  --debug      - turns on the troubleshooting messages
  --no-debug   - turns OFF the usage of tshoot messages
  --echo <str> - paramether to be displayed on STDOUT

SEE ALSO:
  http://tutorialspoint.com/python
  http://cs.wikipedia.org/Python
  http://docs.python.org/2.7/
  http://py.cz

VERSION: %s  
""" % (VERSION)

####################################################################### }}} 1
## DEFAULTS ########################################################### {{{ 1

import sys
import os
import re

# Unix ANSI TTY Escape prefixes with Windows as well
if sys.platform == "win32":   
  import colorama
  colorama.init()

MODE_DEBUG = "" # Filter of troubleshooting messages
MODE_COLOR = 2  # TTY colors 0=OFF 1=ON 2=TBD
TEST_ECHO  = [] # message to be displayed on STDOUT

####################################################################### }}} 1
## INTERFACE ########################################################## {{{ 1

TEST_COLOR = """
#: debug
#+ pass
#- fail
#_ info
#! intrusive
#. confidential
## highlight
#& status
#? prompt
#> interaction
"""


def color(msg):
  global MODE_COLOR
  if not MODE_COLOR: return msg
  msg = re.sub(r"^(#:.*)$", "\033[1;34m\\1\033[m",msg,re.M)     # debug
  msg = re.sub(r"^(#-.*)$", "\033[1;31m\\1\033[m",msg,re.M)     # warning/error
  msg = re.sub(r"^(#\+.*)$","\033[1;32m\\1\033[m",msg,re.M)     # success
  msg = re.sub(r"^(#\&.*)$","\033[1;33m\\1\033[m",msg,re.M)     # status
  msg = re.sub(r"^(#_.*)$", "\033[0;36m\\1\033[m",msg,re.M)     # notice
  msg = re.sub("^(#\>.*)$", "\033[1;36m\\1\033[m",msg,re.M)     # interaction
  msg = re.sub(r"^(#\?.*)$", "\033[1;35m\\1\033[m",msg,re.M)    # prompt
  msg = re.sub(r"^(##.*)$", "\033[1;37m\\1\033[m",msg,re.M)     # highlight
  msg = re.sub(r"^(#\..*)$", "\033[0;34m\\1\033[m",msg,re.M)    # confidential
  msg = re.sub(r"^(#\!.*)$", "\033[1;37;41m\\1\033[m",msg,re.M) # intrusive
  return msg

def strip(msg,mode=2):
  global MODE_COLOR
  if mode == 2: mode=MODE_COLOR
  if mode: return msg
  return re.sub(r"\033[[;0-9]+[mHJ]","",msg)

def debug(msg="DEBUG"):
  global MODE_DEBUG
  if not MODE_DEBUG : return
  if not re.match(MODE_DEBUG,msg): return
  print color("#: "+msg)

def warn(msg="Warning!"):
  print color("#- "+msg)

def good(msg="Good."):
  print color("#+ "+msg)

def die(msg="Error!",code=1):
  if msg: warn(msg)
  sys.exit(code)

def done(msg="Done.",code=0):
  if msg: good(msg)
  sys.exit(code)

  
def interface():
  global MODE_COLOR, MODE_DEBUG

  # handling command-line parameters
  for idx in range(1,len(sys.argv),1):
    argx=sys.argv[idx]
    debug(str(idx)+" : "+argx)
    if re.match("-+c",argx):     MODE_COLOR = 1;    continue  # --color
    if re.match("-+d",argx):     MODE_DEBUG = ".*"; print "debug"; continue # --debug
    if re.match("-+D",argx):     MODE_DEBUG=sys.argv[idx+1]; idx=idx+1; continue # --Debug <filter>
    if re.match("-+no-?c",argx): MODE_COLOR = 0;    continue # --no-color
    if re.match("-+no-?d",argx): MODE_DEBUG = "";   continue # --no-debug
    if re.match("-+e",argx):     TEST_ECHO.append(sys.argv[idx+1]); idx=idx+1; continue  # --echo <text>
    warn("Wrong parameter '%s' !" % (argx))  # command-line syntax error handling

  # Handling TTY colors  
  if MODE_COLOR == 2:
    if sys.stdout.isatty(): MODE_COLOR = 1
    else:                   MODE_COLOR = 0


####################################################################### }}} 1
## MAIN ############################################################### {{{ 1

def main():
  interface()
  for msg in TEST_ECHO:
    print color("#+ "+msg)
  for line in TEST_COLOR.split("\n"):
    print color(line)
  print strip("\033[1;33mhello\033[m",0)
  print strip("\033[1;33mhello\033[m",1)
  print strip("\033[1;33mhello\033[m")
  done()


if __name__ == "__main__":
  main()

####################################################################### }}} 1
