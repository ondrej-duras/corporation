#!/usr/bin/env python2
#=vim color desert

## MANUAL ############################################################# {{{ 1


VERSION = 2020.091701
MANUAL = """
NAME: MiniShell
FILE: minishell.py

DESCRIPTION:
  Equivalent of perl minishell, but written in python

USAGE:
  minishell.py <COMMAND>               # a single command directly
  cat sequence.txt | minishell.py run  # a sequence of commands
  minishell.py run                     # interactive shell with the prompt
  minishell.py ? <pattern>             # list of commands matching the pattern
  minishell.py ?? <pattern>            # list of commands with coments
  minishell.py ??? <pattern>           # list of commands displaing whole definition lines
  minishell.py ???? <pattern>          # searches whole definition lines for the pattern

VERSION: %s

""" % (str(VERSION))


####################################################################### }}} 1
## SYNTAX - CMDBASE - RegExp command definition ####################### {{{ 1

CMDBASE = """
ffox;ibtb$;https://moja.tatrabanka.sk;Internet Banking TatraBanky
ffox;gmail$;https://gmail.com;Freemail
iexp;gmail explorer$;https://gmail.com; Freemail via Internet Explorer
fexp;docs$;c:\usr\Documents\Projects;Project Folder
help;[?]+ .*;Helper
help;help .*;Helper
help;help[1-4] .*;Helper
mnsh;run$;\033[1;31m>\033[1;34m>\033[1;37m>\033[m #\033[1;37mWelcome to MiniShell\033[m
exit;exit|quit|logout;Program termination
"""


####################################################################### }}} 1
## LIBRARY - 1 ######################################################## {{{ 1

import sys
import os
import re
import subprocess

MODE_DEBUG = "" # Filter of troubleshooting messages
MODE_COLOR = 2  # 0=OFF 1=ON 2=TBD


def color(msg):
  global MODE_COLOR
  if not MODE_COLOR: return msg
  msg = re.sub(r"(?m)^(#:.*)$", "\033[1;34m\\1\033[m",msg,re.M)     # debug
  msg = re.sub(r"(?m)^(#-.*)$", "\033[1;31m\\1\033[m",msg,re.M)     # warning/error
  msg = re.sub(r"(?m)^(#\+.*)$","\033[1;32m\\1\033[m",msg,re.M)     # success
  msg = re.sub(r"(?m)^(#\&.*)$","\033[1;33m\\1\033[m",msg,re.M)     # status
  msg = re.sub(r"(?m)^(#_.*)$", "\033[0;36m\\1\033[m",msg,re.M)     # notice
  msg = re.sub("(?m)^(#\>.*)$", "\033[1;36m\\1\033[m",msg,re.M)     # interaction
  msg = re.sub(r"(?m)^(#\?.*)$", "\033[1;35m\\1\033[m",msg,re.M)    # prompt
  msg = re.sub(r"(?m)^(##.*)$", "\033[1;37m\\1\033[m",msg,re.M)     # highlight
  msg = re.sub(r"(?m)^(#\..*)$", "\033[0;34m\\1\033[m",msg,re.M)    # confidential
  msg = re.sub(r"(?m)^(#\!.*)$", "\033[1;37;41m\\1\033[m",msg,re.M) # intrusive
  return msg

def manual(msg):
  # (?m) is an attribute, that causes proper 
  # functionality of ^$ in rest of multiline RegExp
  # ... (?m) is something like re.M within python 2.7-
  global MODE_COLOR
  if not MODE_COLOR: return msg
  msg = re.sub(r"(?m)^([0-9A-Z]+):(.*)","\033[0;37m\\1:\033[0;36m\\2\033[0;33m",msg,re.M)
  msg = re.sub(r"(<\S+>)","\033[0;31m\\1\033[0;33m",msg,re.M)
  msg = re.sub(r"(-\S+)","\033[0;32m\\1\033[0;33m",msg,re.M)
  msg = re.sub(r"(?m)( # .*)$","\033[0;32m\\1\033[0;33m",msg,re.M)
  msg += "\033[m"
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

####################################################################### }}} 1
## LIBRARY - 2 - def_* ################################################ {{{ 1

# CMDBASE - retazec s definiciou gramatiky
# PATTERN - riadok v gramatike - predpisuje akciu k najdenemu prikazu
# COMMAND - prikaz v povodnom zneni, ktory "matchol" s PATTERNOM

def def_FireFox(CMDBASE,PATTERN,COMMAND):
  APATTERN = re.split(r"\s*;\s*",PATTERN)
  URL = APATTERN[2] ; COMMENT = APATTERN[3]
  print(strip("\033[1;37mFireFox\n\033[0;36m%s\n\033[0;33m%s\033[m" % (URL,COMMENT)))
  #os.system("start c:\\opt\\ffox\\firefox.exe \"%s\"" % (URL))
  if sys.platform == "win32":
    subprocess.call([r'c:\opt\ffox\firefox.exe',URL])
  else:
    warn("Platform is not supported yet !")

def def_IExplorer(CMDBASE,PATTERN,COMMAND):
  APATTERN = re.split(r"\s*;\s*",PATTERN)
  URL = APATTERN[2] ; COMMENT = APATTERN[3]
  print(strip("\033[1;37mInternet Explorer\n\033[0;36m%s\n\033[0;33m%s\033[m" % (URL,COMMENT)))
  #CMD = '"C:\Program Files\internet explorer\iexplore.exe" "'+ URL +'"'
  #os.system(CMD) ...toto nefunguje C:\Program ... :-) windows
  if sys.platform == "win32":
    subprocess.call(['C:\Program Files\internet explorer\iexplore.exe',URL])
  else:
    warn("Platform is not supported yet !")

def def_FileExplore(CMDBASE,PATTERN,COMMAND):
  APATTERN = re.split(r"\s*;\s*",PATTERN)
  URL = APATTERN[2] ; COMMENT = APATTERN[3]
  print(strip("\033[1;37mInternet Explorer\n\033[0;36m%s\n\033[0;33m%s\033[m" % (URL,COMMENT)))
  #CMD = '"C:\Program Files\internet explorer\iexplore.exe" "'+ URL +'"'
  #os.system(CMD) ...toto nefunguje C:\Program ... :-) windows
  if sys.platform == "win32":
    subprocess.call(['C:\Windows\explorer.exe',URL])
  else:
    warn("Platform is not supported yet !")



def def_helper(CMDBASE,PATTERN,COMMAND):
  (QMARKS,PATX)=re.split("\s+",COMMAND,1)
  if re.match("^help$",QMARKS): QMARKS=2
  elif re.match("^help[1-4]$",QMARKS): QMARKS=int(re.sub("help","",QMARKS))
  else: QMARKS=len(QMARKS)
  if QMARKS == 4:
    for LINE in CMDBASE.splitlines():
      if re.search(PATX,LINE,re.I): print(LINE)
    return
  for LINE in CMDBASE.splitlines():
    if re.match("\s*$",LINE): continue
    if re.match("\s*#",LINE): continue
    (CMDREF,CMDX,REST)=re.split(r"\s*;\s*",LINE,2)
    HELP=re.sub(r"^.*[#;]","",LINE)
    if not re.match(PATX,CMDX): continue 
    if QMARKS == 1:
      print(CMDX)
    if QMARKS == 2:
      print("%s - %s" % (CMDX,HELP))
    if QMARKS == 3:
      print(LINE)

def def_minishell(CMDBASE,PATTERN,COMMAND):
  PROMPT=re.sub(r"^[^;]+;[^;]+;","",PATTERN)
  PROMPT=re.sub(r" #.*$"," ",PROMPT)
  WELCOME=re.sub(r"^.* #","",PATTERN)
  print(WELCOME)
  while True:
    if sys.stdout.isatty():
      INPUT=raw_input(strip("\033[1;33m%s\033[1;37m\033[m" % (PROMPT)))
    else:
      INPUT=raw_input()
    if re.match("^\s*$",INPUT): continue
    if re.match("^\s*#",INPUT): continue
    minicommand(CMDBASE,INPUT)

def def_exit(CMDBASE,PATTERN,COMMAND):
  done("ok.")


####################################################################### }}} 1
## SYNTAX - DEFBASE - List of Procedure References #################### {{{ 1

DEFBASE = {
"ffox":def_FireFox,
"iexp":def_IExplorer,
"fexp":def_FileExplore,
"help":def_helper,
"mnsh":def_minishell,
"exit":def_exit
}

####################################################################### }}} 1
## MAIN ############################################################### {{{ 1

def minicommand(CMDBASE,COMMAND):
  global DEFBASE
  COMMAND = re.sub(r"^\s+","",COMMAND)
  COMMAND = re.sub(r"\s+$","",COMMAND)

  for PATTERN in CMDBASE.splitlines():
    if re.match(r"^\s*$",PATTERN): continue
    if re.match(r"^\s*#",PATTERN): continue
    APATTERN = re.split(r"\s*;\s*",PATTERN)
    if len(APATTERN) < 2: die("Internal Error at: %s" % (PATTERN))
    if re.match(APATTERN[1],COMMAND):
      DEFBASE[APATTERN[0]](CMDBASE,PATTERN,COMMAND)
      return
    else: continue
  warn("Error: Wrong command: %s" % (COMMAND))
    

# Color mode activation
if sys.platform == "win32":
  try:
    import colorama
    colorama.init()
  except:
    MODE_COLOR = 0

if MODE_COLOR == 2:
  if sys.stdout.isatty(): MODE_COLOR = 1
  else:                   MODE_COLOR = 0


if __name__ == "__main__":
  if len(sys.argv) > 1:
    minicommand(CMDBASE," ".join(sys.argv[1:]))
  else:
    print manual(MANUAL)


####################################################################### }}} 1
# --- end ---
