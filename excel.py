#!/usr/bin/env python2
# Excel.PY
# 20210720, Ing. Ondrej DURAS (dury)

#=vim source $VIM/backup.vim
#=vim call Backup("C:\\usr\\good-oldies\\")
#=vim high Comment ctermfg=darkgreen
# @rem start a8-Core-Drawing-20200820-1.pdf
# @rem for /F "tokens=*" %%D IN ('ls -w1 *Draw*.pdf | tail -1') DO @(start %%D)
# ls -w1 *Draw*.pdf | tail -1 | clip
# paste

VERSION = "2021.092701"
MANUAL  = """
NAME: MS Excel helper
FILE: excel.py

DESCRIPTION:
  searches for the last one *.xlsx file
  Then launches it

USAGE:
  excel.py # Latest *.xlsx
  excel.py -old # Latest *.xls
  excel.py a8 # Latest a8*.xlsx
  excel.py a8 -old # latest a8*.xls
  excel.py -old a8 # latest a8*.xls
  excel.py -zip ARCHIVE.zip a8

PARAMETERS:
  -old   - opens the latest .XLS file except 
           the latest .XLSX file  
  -xls   - --//--
  -help  - this help
  -start - starts empty excel instance
  -ext   - allows to specify another file extension to search
  -zip   - adds the latest excel into specified archive
  -path <path> - path where search a directory content
  -parent      - will search the content in the parent directory

VERSION: %s

SEE ALSO:
  https://github.com/ondrej-duras/
  http://howtomicrosoftofficetutorials.blogspot.com/2017/05/command-line-switches-for-excel.html

""" % (VERSION)
import sys
import os
import os.path
import re

EXCEL  = r"C:\Program Files (x86)\Microsoft Office\Office16\EXCEL.EXE"
PATH   = "."
action =  "open"
dircontent = [] # os.listdir(".")
extension  = "xlsx"
filemask   = ".*"
sys.argv.pop(0)
argct = len(sys.argv)
idx = 0
while idx < argct:
  argx = sys.argv[idx]
  if re.match("-+old",argx):   extension = "xls"; idx += 1; continue # extension mask to .xls (by default there is .xlsx
  if re.match("-+xls",argx):   extension = "xls"; idx += 1; continue # extension mask to .xls
  if re.match("-+ex",argx):    extension = sys.argv[idx+1]; idx += 2; continue # extension mask to <any>
  if re.match("-+m",argx):     filemask  = sys.argv[idx+1]; idx += 2; continue # file mask
  if re.match("-+par",argx):   PATH = ".."; idx += 1; continue  #  PATH ... file search in parent directory
  if re.match("-+p",argx):     PATH = sys.argv[idx+1]; idx += 2; continue # <any> PATH for file search
  if re.match("-+z",argx):     action = "zip"; zipfile   = sys.argv[idx+1]; idx += 2; continue
  if re.match("-+st",argx):    action    = "start"; idx += 1; continue
  if re.match("-+[h?]",argx): print MANUAL; exit()
  filemask = argx + ".*"; idx += 1


if action == "start":
  os.system("\"%s\"" % (EXCEL))
  exit()

# Trying to find the latest file - MyFile
print "EXCEL helper"
dircontent = os.listdir(PATH)
print "File PATH ................ " + PATH
print "File mask ................ " + filemask + "\." + extension
print "Total files found ........ " + str(len(dircontent))
drawings = [ str(f) for f in dircontent if re.match(filemask + "\." + extension,f) ]
print "Matching files found ..... " + str(len(drawings))
if len(drawings) == 0:
  print "None drawing file found."; exit(1);
drawings.sort()
MyFile = PATH + "/" + drawings[-1]

if action == "open":
  print("Trying to open ........... " + MyFile)
  os.system("start " + MyFile)
  exit()

if action == "zip":
  print("Trying to archive ........ " + MyFile)
  print("Archiving to ............. " + zipfile)
  os.system("7za a -tzip %s %s" % (zipfile,MyFile))
  exit()

exit()


# --- end ---

