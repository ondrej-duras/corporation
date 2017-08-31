#!/bin/env python
#
# 048-ANY-MODULEVERSION.PY - PYthon Modules Info Utility
# 20170831, Ing. Ondrej DURAS, OSK
# C:\usr\prog\py-priklady\048-any-ModuleVersion.py
#
## MANUAL ############################################################# {{{ 1

VERSION = 2017.083102
MANUAL  = """
NAME: PYthon Modules Info Utility
FILE: pym.py / 048-any-ModuleVersion.py

DESCRIPTION:
  The script queries a list of Python modules for
  their __version__ and __file__ (real deployment).
  That's helpful for module dependency troubleshooting.

USAGE:
  pym.py pygame visual colorama re os sys xxx
  pym.py -a -q os

PARAMETERS:
  -a - check all my favorite modules
  -q - do not display this manual page 

SEE ALSO:
  https://github.com/ondrej-duras/myPL
  pym.py - home of this script
  pm.pl  - similar script for PERL

VERSION: %s
""" % (VERSION)


####################################################################### }}} 1
## DEFAULTS ########################################################### {{{ 1

import sys
import re

MODULES_FAVOR=[
 "colorama",  # Win32::Console::ANSI alternative
 "pygame",    # PyGame.org
 "visual"     # VPython.org
]
MODULES=[]

MODE_QUIET = 0
MODE_FAVOR = 0

sys.argv.pop(0) # removes the name of script - argv[0]
for argx in sys.argv:
  if not re.match("-",argx):
    MODULES.append(argx); continue
  if re.match("-+q",argx): MODE_QUIET = 1
  if re.match("-+a",argx): MODE_FAVOR = 1

if not MODE_QUIET: print MANUAL
if MODE_FAVOR: MODULES = MODULES_FAVOR + MODULES


####################################################################### }}} 1
## MAIN ############################################################### {{{ 1

for module in MODULES:
  ver  = None
  path = None
  try:     # skus nieco co mozno nedopadne dobre
    # takto to funguje tiez
    #import colorama as xmodule
    #ale takto do 'module' dame premennu
    xmodule = __import__(module)
  except:  # tot sprav ak to dobre nedopadlo 
    ver = "missing"
    path= "missing"
  else:    # alebo toto, ak to dobre dopadlo
    try:
      ver = str(xmodule.__version__)
    except:
      ver = 'Unknown'
    try:
      path = str(xmodule.__file__)
    except:
      path = 'Internal'
    
  finally: # 
    print "%-15s ........ %-15s at %s" % (module,ver,path)

####################################################################### }}} 1
# --- end ---
