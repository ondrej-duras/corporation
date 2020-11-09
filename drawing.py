#!/usr/bin/env python2
# Drawing.PY
# 20201007, Ing. Ondrej DURAS (dury)

#=vim source $VIM/backup.vim
#=vim call Backup("C:\\usr\\good-oldies\\")
# @rem start a8-Core-Drawing-20200820-1.pdf
# @rem for /F "tokens=*" %%D IN ('ls -w1 *Draw*.pdf | tail -1') DO @(start %%D)
# ls -w1 *Draw*.pdf | tail -1 | clip
# paste

VERSION = "2020.110901"
MANUAL  = """
NAME: Drawing
FILE: drawing.py

DESCRIPTION:
  searches for the last one Drawing.PDF file
  Then launches it

USAGE:
  drawing.py # Latest *Draw*.pdf
  drawing.py -edit # Latest *Draw*.vsdx
  drawing.py a8 # Latest a8*.pdf
  drawing.py a8 -edit # latest a8*.vsdx
  drawing.py -edit a8 # latest a8*.vsdx

PARAMETERS:
  -edit - opens the latest .VSDX file except 
          the latest .PDF file  
  -help - this help

VERSION: %s

SEE ALSO:
  https://github.com/ondrej-duras/

""" % (VERSION)

import sys
import os
import os.path
import re

dircontent = os.listdir(".")
extension  = "pdf"
filemask   = ".*Draw.*"
sys.argv.pop(0)
argct = len(sys.argv)
idx = 0
while idx < argct:
  argx = sys.argv[idx]
  if re.match("-+ed",argx):   extension = "vsdx"; idx += 1; continue
  if re.match("-+ex",argx):   extension = sys.argv[idx+1]; idx += 2; continue
  if re.match("-+m",argx):    filemask  = sys.argv[idx+1]; idx += 2; continue
  if re.match("-+[h?]",argx): print MANUAL; exit()
  filemask = argx + ".*"; idx += 1
print "File mask ................ " + filemask + "\." + extension
print "Total files found ........ " + str(len(dircontent))

drawings = [ str(f) for f in dircontent if re.match(filemask + "\." + extension,f) ]
print "Matching files found ..... " + str(len(drawings))
if len(drawings) == 0:
  print "None drawing file found."; exit(1);
drawings.sort()
MyFile = drawings[-1]
print "Trying to open ........... " + MyFile
os.system("start " + MyFile)
exit()


# --- end ---

