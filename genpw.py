#!/usr/bin/env python2
# 20210701, Ing. Ondrej DURAS (dury)

## MANUAL ############################################################# {{{ 1

VERSION = "2021.100701"
MANUAL  = """
NAME: Password Generator
FILE: genpw.py

DESCRIPTION:
  generates ranedom password, matching various criteria

USAGE:
  genpw -8
  genpw -17 sdfnklb gio
  genpw -hsrp

PARAMETERS
  -17    - password containing 17 characters, 8 characters are default
  -21    - password containing 21 characters ... any uint can be there
  -hsrp  - password matching requirements for Cisco HSRP configuration
  -ntlm  - password for usual windows domain

SEE ALSO:
  https://github.com/ondrej-duras/

VERSION: %s  
""" % (VERSION)

####################################################################### }}} 1
## GLOBAL ############################################################# {{{ 1

SALT=""
PWLEN=0  # Password Length (must be updated)
PWMIN=8  # Minimal Password Length
PWMAX=8  # Maximal Password Length
PWGRP="Aa8_" # Groups of characters A=BigLetters a=SmallLetters 8=digits _=_-. +=usual_special_chars
CGMAIN  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
CGMAIN += "abcdefghijklmnopqrstuvwxyz"
CGMAIN += "0123456789"
CGMAIN += "_-."

import sys
import re
import hashlib
import base64
import random
import time

####################################################################### }}} 1
## LIBRARY ############################################################ {{{ 1

def genPassword(pwmin,pwmax,pwgrp,salt):
  global PWLEN,CGMAIN
  random.seed(time.time())
  PWLEN = random.randint(pwmin,pwmax)
  out=""
  for i in range(PWLEN):
    out += random.choice(CGMAIN)
  return out

####################################################################### }}} 1
## ACTION ############################################################# {{{ 1

def takeAction():
  print(genPassword(PWMIN,PWMAX,PWGRP,SALT))
  exit(0)

####################################################################### }}} 1
## COMMAND-LINE ####################################################### {{{ 1

def takeParameters():
  global SALT,PWLEN,PWMIN,PWMAX,PWGRP
  argv = sys.argv
  if len(argv) <= 1:
    print MANUAL
    exit(0)
 
   
  while len(argv) > 0:
    argx = argv.pop(0)
    if argx in ("-?","-h","--help"): 
      print(MANUAL)
      exit(0)

    if re.match("-+[0-9]+$",argx): 
      PWMIN=int(re.sub("[^0-9]","",argx))
      PWMAX=PWMIN
      continue

    if re.match("-+[0-9]+,[0-9]+$",argx): 
      argx=re.sub("[^0-9,]","",argx); 
      (PWMIN,PWMAX)=argx.split(",")
      PWMIN=int(PWMIN)
      PWMAX=int(PWMAX)

    # default behaviour
    SALT += str(argx)

####################################################################### }}} 1
## MAIN ############################################################### {{{ 1

if __name__ == "__main__":
  takeParameters()
  takeAction()


####################################################################### }}} 1
# --- end ---


