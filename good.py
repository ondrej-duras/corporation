#!/usr/bin/env python
# 230524, Ondrej DURAS (dury)

## MANUAL ############################################################# {{{ 1

VERSION = "2024.011102"
MANUAL  = """
NAME: Good-Oldies manipulation utility
FILE: good.py

DESCRIPTION:
  Helps to practise good-oldies style
  current version manipulation

BEHAVIOUR:
  1. Target folder for backup
  If ./.good-oldies does exist, then the target 
    folder is ./.good-oldies
  Else If ~/.good-oldies does exist, then
    the target folder is ~/.good-oldies
  Else
    it searches for system common folder.
    ...but it's relavant for windows only.
    Windows: c:/usr/good-oldies
    Unix:    /var/good-oldies

  2. Timestamp
  Timestamp format is YYYYmmdd-HHMMSS

  3. Target file is extended to:
  ${TARGET_FOLDER}/${FILENAME}-${TIMESTAMP}.${EXTENSION}

  4. Make a backup copy
  cp ${FILE_NAME}.${EXTENSION} ${TARGET_FOLDER}/${FILENAME}-${TIMESTAMP}.${EXTENSION}

  Utility assumes there are no two attempts of backup within a second

EXAMPLE:
  good --add  file.txt       # make a new backup
  good --list file.txt       # list of all existing backups
  good --last file.txt       # provides the last backup filename
  good --test --add file.txt # acting verbosely but without execution
  good --debug --add file.txt # make a new backup verbosely
  good --ad file.txt # as the same as good --debug --add file.txt

SEE ALSO:
  https://github.com/ondrej-duras

VERSION: %s
""" % (VERSION)


####################################################################### }}} 1
## GLOBALS ############################################################ {{{ 1


import sys
import re
import os
import glob
from datetime import datetime

ACTION = []     # command-line attributes translated into list of actions
DEBUG  = False  # verbosity 
TEST   = False  # test mode of processing
FILE   = []     # list of files to proceed
DEST   = ""

####################################################################### }}} 1
## SUPPORT ############################################################ {{{ 1


def debug(msg,category="basic"):
  global DEBUG
  if DEBUG:
    print(":: good: " + msg)
  return

####################################################################### }}} 1
## newFile newMask #################################################### {{{ 1

# prepares a new archive file name by
# adding a version between plain file name and file extension

def newFile(fname=FILE):
  global ACTION,DEBUG,TEST,FILE
  if len(fname)==0:   # empty filename returns empty
    return ""
  if re.match(r".*\.",fname):  # handling filename with extension
    plainfile = re.sub(r"\.[a-zA-Z0-9]+$","",fname)
    plainfile = re.sub(r"^.*[\\/]","",plainfile)
    extension = re.sub(r"^.*\.","",fname)
    fversion  = datetime.now().strftime("%Y%m%d-%H%M%S")
    newfile   = plainfile + "-" + fversion + "." + extension
  else :  # handling filename without an extension
    plainfile = re.sub(r"^.*[\\/]","",fname)
    fversion  = datetime.now().strftime("%Y%m%d-%H%M%S")
    newfile   = plainfile + "-" + fversion
  return(newfile)


def newMask(fname=FILE):
  global ACTION,DEBUG,TEST,FILE
  if len(fname)==0:   # empty filename returns empty
    return ""
  if re.match(r".*\.",fname):  # handling filename with extension
    plainfile = re.sub(r"\.[a-zA-Z0-9]+$","",fname)
    plainfile = re.sub(r"^.*[\\/]","",plainfile)
    extension = re.sub(r"^.*\.","",fname)
    fversion  = "*"
    newfile   = plainfile + "-" + fversion + "." + extension
  else :  # handling filename without an extension
    plainfile = re.sub(r"^.*[\\/]","",fname)
    fversion  = "*"
    newfile   = plainfile + "-" + fversion
  return(newfile)


####################################################################### }}} 1
## newPath ############################################################ {{{ 1

def newPath():
  global ACTION,DEBUG,TEST,FILE,DEST
  DEST = "."
  #  preconfigured local "good-oldies" repository
  if os.path.isdir(".good-oldies"):
    DEST = ".good-oldies"
    return(DEST)
  # windows systems
  if os.name == 'nt':
    try : 
      USERHOME = os.path.join(os.environ['USERHOME'],".good-oldies")
    except :
      USERHOME = ""
    if os.path.isdir(USERHOME):
      DEST = USERHOME
      return(DEST)
    if os.path.isdir("c:/usr/good-oldies"):
      DEST = "c:/usr/good-oldies"
      return(DEST)
  # non windows systems
  try :
    HOME = os.path.join(os.environ['HOME'],".good-oldies")
  except : 
    HOME = "/var/good-oldies"
  if os.path.isdir(HOME):
    DEST = HOME
    return(DEST)
  DEST = "."
  return(DEST)  
  
####################################################################### }}} 1
## doAdd doList doLast ################################################ {{{ 1

# makes a new backup
# doAdd('file.txt')
def doAdd(fname=FILE):
  global ACTION,DEBUG,TEST,FILE,DEST
  newfile = newFile(fname)
  newpath = newPath()
  #fullname= os.path.join(newpath,newfile)
  fullname= newpath + "/" + newfile
  command = "cp %s %s" % (fname,fullname)
  debug("command .... "+command)
  debug("fullname ... "+fullname)
  if TEST:
    return
  os.system(command)


# list of all existing backups
# doList('file.txt')
def doList(fname=FILE):
  global ACTION,DEBUG,TEST,FILE,DEST
  newfile = newMask(fname)
  newpath = newPath()
  #fullname= os.path.join(newpath,newfile)
  fullname= newpath + "/" + newfile
  command = "ls -l %s" % (fullname)
  debug(command)
  os.system(command)


# provide the name of the last one backup
# doLast('file.txt')
def doLast(fname=FILE):
  global ACTION,DEBUG,TEST,FILE,DEST
  newfile = newMask(fname)
  newpath = newPath()
  #fullname= os.path.join(newpath,newfile)
  fullname= newpath + "/" + newfile
  debug(fullname)
  DIR=glob.glob(fullname)
  if len(DIR) > 0:
    print(DIR[-1])


####################################################################### }}} 1
## doAction ########################################################### {{{ 1


def doAction():
  global ACTION,DEBUG,TEST,FILE
  if ("last" in ACTION):
    fl=FILE
    while(len(fl)):
      doLast(fl.pop(0))

  if ("add" in ACTION):
    fl=FILE
    while(len(fl)):
      doAdd(fl.pop(0))

  if ("list" in ACTION):
    fl=FILE
    while(len(fl)):
      doList(fl.pop(0))

  # at the end
  #exit()  # script could be terminated...
  return


####################################################################### }}} 1
## commandLine ######################################################## {{{ 1

def commandLine():
  global ACTION,TEST,DEBUG,FILE
  args  = sys.argv
  args.pop(0)
  argix = 1
  while(len(args)):
    argx = args.pop(0)
    argix += 1
    debug(str(argix)+":"+argx)

    if argx in ("--ad","ad"):
      ACTION.append("debug")
      ACTION.append("add")
      FILE.append(args.pop(0))
      DEBUG=True
      continue

    if argx in ("-a","--add","add"):
      ACTION.append("add")
      FILE.append(args.pop(0))
      continue

    if argx in ("-q","--list","list"):
      ACTION.append("list")
      FILE.append(args.pop(0))
      continue

    if argx in ("-l","--last","last"):
      ACTION.append("last")
      FILE.append(args.pop(0))
      continue

    if argx in ("-t","--test","test"):
      ACTION.append("test")
      TEST=True
      DEBUG=True
      continue

    if argx in ("-v","--debug","debug"):
      ACTION.append("debug")
      DEBUG=True
      continue

    print("Syntax error (%s) '%s' !" % (str(argix),argx))
    exit()
  return

####################################################################### }}} 1
## MAIN ############################################################### {{{ 1

if __name__ == "__main__":

  if len(sys.argv) <=1:
    print(MANUAL)
    exit()
  commandLine()
  doAction()

####################################################################### }}} 1
# --- end ---

