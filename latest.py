#!/usr/bin/env python2

## MANUAL ############################################################# {{{ 1

VERSION = "2022.100401"
MANUAL  = """
NAME: Latest File
FILE: latest.py

DESCRIPTION:
  Helps to find the latest version of file

USAGE:
  latest.py a8  # shows filename only
  latest.py -zip Backup.ZIP a8 # adds to archive
  latest.py -par -zip Backup.ZIP a8 # adds drawing from parent dir to archive
  latest.py -par -ext pdf -file a8 # provides a filename from parent dir
  latest.py -new a8 # creates a new file ...???
  latest.py -ver a8 # provides a lates version ID
  latest.py -copy a8 a8-Drawing.vsdx # makes a copy to particular file
  latest.py -file a8 # shows a file name only
  latest.py -file -ext pdf # ... -//- , specifies a .PDF extension
  latest.py -start a8  # opens a file, based on OS setup
  latest.py a8 -pg 4,5 -pgout vrfXY-only  # makes vrfXY.pdf based on 4th and 5th page of a8*.pdf
  latest.py a8 -pg 4,5 -pgout vrfXY-only -pgver # makes vrfXY-20220701-130102.pdf
  latest.py

PARAMETERS:
  -zip   - adds file to .ZIP archive
  -new   - creates a new copy/version of the file
  -ver   - provides a version of latest files
  -copy  - makes a copy of the latest file
  -file  - provides a file name of the latest file
  -start - opens the latest file via system setup
  -ext   - define a file extension
  -par   - parent directory contains file
  -pg    - list of pages (see pdftk manual)
  -pages - -//-
  -pgver - generates automated version at the end of output filename
  -pgout - file name prefix of output file for -pg

SEE ALSO:
  https://github.com/ondrej-duras/

VERSION: %s
""" % (VERSION)

####################################################################### }}} 1
## GLOBALS ############################################################ {{{ 1


import sys
import os
import os.path
import re
import datetime


fpath  = "."
dircon = []       # os.listdir(".") # DIRectory CONtent
action = "file"   # actions: have a look to MANUAL:USAGE section
extension = ".*"  # regular expression - filtering based on file extension
fnpattern = ".*"  # file pattern
copyfile= ""      # destination file to copy
zipfile = ""      # destination archive file to archive
debug = ""        #

pages = ""        # list of pages to forward to output (see tdftk manual)
pgoutfile = "out" # prefix of PDF output filename
pgver = ""        # pages goes to file <pgoutfile>-<pgver>.pdf or <pgoutfile>.pdf

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
  global action,debug,dircon,fnpattern,extension,fpath
  fname=sorted(filterPattern(filterExtension(dircon,extension),fnpattern))[-1]
  # fname= fpath + "/" + fname
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
  global action,debug,dircon,fnpattern,extension,fpath
  global zipfile,copyfile,pages,pgoutfile,pgver

  dircon = os.listdir(fpath)

  if action == "file":
    #fname=latestFile()
    fname=fpath + "/" + latestFile()
    print(fname)
    exit()

  if action == "start":
    fname=fpath + "/" + latestFile()
    print("Opening file ... %s" % (fname))
    if sys.platform == "win32":
      fname = fname.replace(r"/","\\")
      print("Fixed fname .... %s" % (fname))
    os.system("\"%s\"" % (fname))
    exit()

  if action == "copy":
    # fname=latestFile()
    fname=fpath + "/" + latestFile()
    if sys.platform == "win32":
      fname = fname.replace(r"/","\\")
      cmd="copy /Y %s %s" % (fname,copyfile)
    else:
      cmd="cp -f %s %s" % (fname,copyfile)
    print(cmd)
    os.system(cmd)
    exit() 

  if action == "zip":
    # fname=latestFile()
    fname=fpath + "/" + latestFile()
    cmd="7za a -tzip %s %s" % (zipfile,fname)
    print(cmd)
    os.system(cmd)
    exit()

  if action == "ver":
    # fname=latestFile()
    fname=fpath + "/" + latestFile()
    version=splitFile(fname)[1]
    print(version)
    exit()

  if action == "pages":
    fname=latestFile()
    output=pgoutfile
    if pgver <> "": output+="-"+pgver
    output+=".pdf"
    cmd="pdftk %s cat %s output %s" % (fname,pages,output)
    print(cmd)
    os.system(cmd)
    exit()

####################################################################### }}} 1
## CLI ################################################################ {{{ 1

def commandLine(cli=sys.argv):
  global fnpattern,action,zipfile,copyfile,extension,fpath
  global pages,pgver,pgoutfile
  if len(cli) < 2:
     print(MANUAL)
     exit()

  cli.pop(0)
  while len(cli):
    argx = cli.pop(0)
    if re.match("-+z",    argx): action = "zip";  zipfile  = cli.pop(0); continue  # -zip
    if re.match("-+c",    argx): action = "copy"; copyfile = cli.pop(0); continue  # -copy
    if re.match("-+e",    argx): extension = cli.pop(0); continue # -extension
    if re.match("-+pgout",argx): pgoutfile= cli.pop(0); continue # -pgout <file_prefix>
    if re.match("-+pgver",argx): now=datetime.datetime.now(); pgver=now.strftime("%Y%m%d-%H%M%S"); continue
    if re.match("-+pg",   argx): action ="pages"; extension=".*\.(pdf|PDF)"; pages=cli.pop(0); continue
    if re.match("-+pages",argx): action ="pages"; extension=".*\.(pdf|PDF)"; pages=cli.pop(0); continue
    if re.match("-+par",  argx): fpath  = "..";          continue # -parent ( -path .. )
    if re.match("-+p",    argx): fpath  = cli.pop(0);    continue # -path
    if re.match("-+n",    argx): action = "new";   continue       # -new
    if re.match("-+v",    argx): action = "ver";   continue       # -version
    if re.match("-+f",    argx): action = "file";  continue       # -file
    if re.match("-+s",    argx): action = "start"; continue       # -start ( -open )
    if re.match("=+d",    argx): debug  = "all";   continue       # troubleshooting
    fnpattern = argx

####################################################################### }}} 1
## MAIN ############################################################### {{{ 1

if __name__ == "__main__":
  commandLine()
  takeAction()

####################################################################### }}} 1
# --- end ---

