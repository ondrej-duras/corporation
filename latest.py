#!/usr/bin/env python2

## MANUAL ############################################################# {{{ 1

VERSION = "2021.090701"
MANUAL  = """
NAME: Latest File
FILE: latest.py

DESCRIPTION:
  Helps to find the latest version of file

USAGE:
  latest.py a8
  latest.py -zip Backup.ZIP a8
  latest.py -new a8
  latest.py -ver a8
  latest.py -copy a8 a8-Drawing.vsdx
  latest.py -file a8
  latest.py -file -ext pdf
  latest.py -start a8

PARAMETERS:
  -zip   - adds file to .ZIP archive
  -new   - creates a new copy/version of the file
  -ver   - provides a version of latest files
  -copy  - makes a copy of the latest file
  -file  - provides a file name of the latest file
  -start - opens the latest file via system setup
  -ext   - define a file extension

SEE ALSO:
  https://github.com/ondrej-duras/

VERSION: %s
""" % (VERSION)

####################################################################### {{{ 1
## GLOBALS ############################################################ }}} 1


import sys
import os
import os.path
import re
import datetime

dircon = os.listdir(".") # DIRectory CONtent
action = "file"   # actions: have a look to MANUAL:USAGE section
extension = ".*"  # regular expression - filtering based on file extension
fnpattern = ".*"  # file pattern
copyfile= ""      # destination file to copy
zipfile = ""      # destination archive file to archive
debug = ""        #

####################################################################### }}} 1
## LIBRARY ############################################################ {{{ 1


# input  dcin = content of folder (all filenames within the folder)
# output all filenames matching the file pattern (from the right side)
def filterExtension(dcin=dircon,fext=extension):   # filterExtension(dircon,extension)
  dcout=[]
  rgext=r".*" + fext + r"$"
  for fname in dcin:
    if re.match(rgext,fname): dcout.append(fname)
  return dcout


# input  dcin = content of folder (all filenames within the folder)
# output all filenames matching the file pattern (from the left side)
def filterPattern(dcin=dircon,fpat=fnpattern):  # filterPattern(dircon,fnpattern)
  dcout=[]
  for fname in dcin:
    if re.match(fpat,fname): 
      dcout.append(fname)
      #print("Match %s" % (fname))
  return dcout


# provides the latest file name of matching pattern and extension
def latestFile():
  global action,debug,dircon,fnpattern,extension
  fname=sorted(filterPattern(filterExtension(dircon,extension),fnpattern))[-1]
  return fname


# splits a filename into pattern,version and extension
def splitFile(fname):
  rx=re.search(r"^(.*)-(2[0-9]{7}-[0-9]+).([0-9a-zA-Z]+)$",fname)
  pat=rx.group(1) # pattern  *rx.group(0) is whole matched string
  ver=rx.group(2) # version
  ext=rx.group(3) # extension
  return (pat,ver,ext)


####################################################################### }}} 1
## ACTION ############################################################# {{{ 1

def takeAction():
  global action,debug,dircon,fnpattern,extension
  global zipfile,copyfile

  if action == "file":
    fname=latestFile()
    print(fname)
    exit()

  if action == "start":
    fname=latestFile()
    print("Opening file ... %s" % (fname))
    os.system("\"%s\"" % (fname))
    exit()

  if action == "copy":
    fname=latestFile()
    if sys.platform == "win32":
      cmd="copy /Y %s %s" % (fname,copyfile)
    else:
      cmd="cp -f %s %s" % (fname,copyfile)
    print(cmd)
    os.system(cmd)
    exit() 

  if action == "zip":
    fname=latestFile()
    cmd="7za a -tzip %s %s" % (zipfile,fname)
    print(cmd)
    os.system(cmd)
    exit()

  if action == "ver":
    fname=latestFile()
    version=splitFile(fname)[1]
    print(version)
    exit()

####################################################################### }}} 1
## CLI ################################################################ {{{ 1

def commandLine(cli=sys.argv):
  global fnpattern,action,zipfile,copyfile,extension
  if len(cli) < 2:
     print(MANUAL)
     exit()

  cli.pop(0)
  while len(cli):
    argx = cli.pop(0)
    if re.match("-+z",argx): action = "zip";  zipfile  = cli.pop(0); continue
    if re.match("-+c",argx): action = "copy"; copyfile = cli.pop(0); continue
    if re.match("-+e",argx): extension = cli.pop(0); continue
    if re.match("-+n",argx): action = "new";   continue
    if re.match("-+v",argx): action = "ver";   continue
    if re.match("-+f",argx): action = "file";  continue
    if re.match("-+s",argx): action = "start"; continue
    if re.match("=+d",argx): debug  = "all";   continue
    fnpattern = argx

####################################################################### }}} 1
## MAIN ############################################################### {{{ 1

if __name__ == "__main__":
  commandLine()
  takeAction()

####################################################################### }}} 1
# --- end ---

