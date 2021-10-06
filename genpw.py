#!/usr/bin/env python2
# 20210701, Ing. Ondrej DURAS (dury)

## MANUAL ############################################################# {{{ 1

VERSION = "2021.100703"
MANUAL  = """
NAME: Password Generator
FILE: genpw.py

DESCRIPTION:
  generates ranedom password, matching various criteria

USAGE:
  genpw -8
  genpw -8|clip
  genpw -17 sdfnklb gio
  genpw -10,15 -grp=Aa8+
  genpw -hsrp

PARAMETERS
  -17      - password containing 17 characters, 8 characters are default
  -21      - password containing 21 characters ... any uint can be there
  -10,15   - password length will be between 10 and 15 chars
  -hsrp    - password matching requirements for Cisco HSRP configuration
  -ntlm    - password for usual windows domain
  -grp=Aa8 - password will contain Aa8 groups of character
  all other/unknown parameters are recognized as a "salt"
 
CHARACTER GROUPS:
  A - ABCDEFGHIJKLMNOPQRSTUVWXYZ
  a - abcdefghijklmnopqrstuvwxyz
  8 - 0123456789
  H - 0123456789ABCDEF
  h - 0123456789abcdef
  - - _-.
  + - _-.!@#$%%^&*()+=,><:;{|}[]/
  q - `'\"\\
  s - <space>
  t - <tabulator> 

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
CGUPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"  # group A
CGSMALL = "abcdefghijklmnopqrstuvwxyz"  # group a
CGDIGIT = "0123456789"                  # group 8
CGHEXAU = "0123456789ABCDEF"            # group 8
CGHEXAL = "0123456789abcdef"            # group 8
CGLIGHT = "_-."                         # group _ or -
CGEXTRA = "_-.!@#$%%^&*()+=,><:;{|}[]/" # group +
CGQUOTE = "'\"\\`"                      # group q
CGSPACE = " "                           # group s
CGTABUL = "\t"                          # group t
CGOUTPW = "" # output Character Group
CGMAIN  = CGUPPER + CGSMALL + CGDIGIT + CGLIGHT # group m - The most comfortable group for passwords

import sys
import re
import hashlib
import base64
import random
import time

####################################################################### }}} 1
## LIBRARY ############################################################ {{{ 1

# providing group of characters that the password should contain
def getCharGroup(pwgrp):
  global CGUPPER,CGSMALL,CGDIGIT,CGLIGHT,CGEXTRA,CGSPACE,CGTABUL,CGMAIN 
  global CGOUTPW
  CGOUTPW = ""
  if "A" in pwgrp: CGOUTPW += CGUPPER
  if "a" in pwgrp: CGOUTPW += CGSMALL
  if "8" in pwgrp: CGOUTPW += CGDIGIT
  if "H" in pwgrp: CGOUTPW += CGHEXAU
  if "h" in pwgrp: CGOUTPW += CGHEXAL
  if "_" in pwgrp: CGOUTPW += CGLIGHT
  if "-" in pwgrp: CGOUTPW += CGLIGHT
  if "+" in pwgrp: CGOUTPW += CGEXTRA
  if "q" in pwgrp: CGOUTPW += CGQUOTE
  if "s" in pwgrp: CGOUTPW += CGSPACE
  if "t" in pwgrp: CGOUTPW += CGTABUL
  if "m" in pwgrp: CGOUTPW += CGMAIN  # default option
  return CGOUTPW

# providing a password
def genPassword(pwmin,pwmax,pwgrp=CGMAIN,salt=SALT):
  global PWLEN,CGMAIN,CGOUTPW
  random.seed(time.time())
  PWLEN = random.randint(pwmin,pwmax)
  CGOUTPW = getCharGroup(pwgrp)
  out=""
  for i in range(PWLEN):
    out += random.choice(CGOUTPW)
  return out

####################################################################### }}} 1
## ACTION ############################################################# {{{ 1

def takeAction():
  if sys.stdout.isatty():  # EOL required
    print(genPassword(PWMIN,PWMAX,PWGRP,SALT))
  else: # strip EOL
    sys.stdout.write(genPassword(PWMIN,PWMAX,PWGRP,SALT))

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

    if re.match("-grp=",argx):
       PWGRP=argx[5:]  # -grp

    # default behaviour
    SALT += str(argx)

####################################################################### }}} 1
## MAIN ############################################################### {{{ 1

if __name__ == "__main__":
  takeParameters()
  takeAction()


####################################################################### }}} 1
# --- end ---


