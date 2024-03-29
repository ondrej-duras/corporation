#!/usr/bin/env python2
# Drawing.PY
# 20201007, Ing. Ondrej DURAS (dury)

## MANUAL ############################################################# {{{ 1


VERSION = "2021.092701"
MANUAL  = """
NAME: Drawing
FILE: drawing.py

DESCRIPTION:
  searches for the last one *Drawing*.PDF file
  Then launches it.
  If you start a script with -edit, then it
  searches for the latest *Draw*.VSDX and
  opens it for editing.
  In case you start the script with the -new <file>
  the script will copy drawing.vsdx template
  to the .\<file>-Drawing-YYYYmmdd-1.vsdx and opens it.

USAGE:
  drawing.py # Latest *Draw*.pdf
  drawing.py -edit # Latest *Draw*.vsdx
  drawing.py a8 # Latest a8*.pdf
  drawing.py a8 -edit # latest a8*.vsdx
  drawing.py -edit a8 # latest a8*.vsdx
  drawing.py -new a8-Topo # copies drawing-new.vsdx 
             # to a8-Topo-Drawing-YYYYmmdd-1.vsdx

PARAMETERS:
  -edit - opens the latest .VSDX file except 
          the latest .PDF file  

  -help - this help

  -mask <fm> - file mask
  -ext <fe>  - file extension
  -path <fp> - file path (directory where resides)
  -parent    - parent directory as the file path

  -new  - copies a template as a new file

VERSION: %s

SEE ALSO:
  https://github.com/ondrej-duras/

""" % (VERSION)

####################################################################### }}} 1
## DECLARATION ######################################################## {{{ 1

#=vim source $VIM/backup.vim
#=vim call Backup("C:\\usr\\good-oldies\\")
#=vim high Comment ctermfg=darkgreen
# @rem start a8-Core-Drawing-20200820-1.pdf
# @rem for /F "tokens=*" %%D IN ('ls -w1 *Draw*.pdf | tail -1') DO @(start %%D)
# ls -w1 *Draw*.pdf | tail -1 | clip
# paste
# ...adding to .ZIP
# 7za a -tzip e21-C-285-SE-NavstevaPapeza-2021-Config.zip *.txt

import sys
import os
import os.path
import re
import datetime

PATH       = "."
dircontent = [] # os.listdir(".")
extension  = "pdf"
filemask   = ".*Draw"
template   = re.sub(r"py$","vsdx",__file__)
sys.argv.pop(0)
argct = len(sys.argv)
idx = 0
new_mode = False # causes to copy new Drawing from template
action = "view"  # view(PDF) edit(VSDX) zip(adding to .ZIP)
zipfile = ""

####################################################################### }}} 1
## PARAMETERS / CLI ################################################### {{{ 1

while idx < argct:
  argx = sys.argv[idx]
  if re.match("-+ed",argx):   action = "edit"; extension = "vsdx"; idx += 1; continue
  if re.match("-+ex",argx):   extension = sys.argv[idx+1]; idx += 2; continue
  if re.match("-+m",argx):    filemask  = sys.argv[idx+1]; idx += 2; continue
  if re.match("-+par",argx):  PATH      = "..";            idx += 1; continue
  if re.match("-+p",argx):    PATH      = sys.argv[idx+1]; idx += 2; continue
  if re.match("-+[h?]",argx): print MANUAL; exit()
  if re.match("-+n",argx):    action = "new"; filemask  = sys.argv[idx+1]; idx += 2; new_mode = True; continue
  if re.match("-+z",argx):    action = "zip"; zipfile = sys.argv[idx+1]; idx +=2; continue

  filemask = argx ; idx += 1

####################################################################### }}} 1
## MAIN ############################################################### {{{ 1

# discovering current directory
print "DRAWING helper"
dircontent = os.listdir(PATH)
print "File PATH ..................... " + PATH
print "File mask ..................... " + filemask + ".*\." + extension
print "Total files found ............. " + str(len(dircontent))
drawings = [ str(f) for f in dircontent if re.match(filemask + ".*" + r"\." + extension,f) ]
print "Matching files found .......... " + str(len(drawings))

# Creating new file
#if new_mode:
if action == "new":
  # preparing filenames
  print "Template .................... " + template
  if not os.path.exists(template):
    print "Error: None template '%s' found !" % (template); exit()
  # check existing drawings (should not for -new)
  if len(drawings) > 0:
    print "Error: some drawings exist already. Use -edit !"
  new_file = PATH + "/" + filemask + "-Drawing-" + datetime.datetime.today().strftime("%Y%m%d-1.vsdx")
  print "New file .................... " + new_file
  if os.path.exists(new_file):
    print "Error: File '%s' exists already !" % (new_file)
    exit()
  # copying template and starting it for editing
  os.system("copy %s %s" % (template,new_file))
  os.system("start " + new_file)
  exit()

# based on extension
# opening the last file for viewing(.PDF) or for editing(.VSDX)
if len(drawings) == 0:
  print "Error: None drawing file found."; exit(1);
drawings.sort()
MyFile = PATH + "/" + drawings[-1]
if action == "view":
  print "Trying to open for view ..... " + MyFile
  os.system("start " + MyFile)
  exit()

if action == "edit":
  print "Trying to open for view ..... " + MyFile
  os.system("start " + MyFile)
  exit()

if action == "zip":
  print "Archiving to .ZIP file ..... " + MyFile
  os.system("7za a -tzip %s %s" % (zipfile,MyFile))
  exit()


####################################################################### }}} 1
# --- end ---

