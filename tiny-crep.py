#!/usr/bin/env python

## MANUAL ############################################################# {{{ 1

VERSION = 2017.102701
MANUAL  = """
NAME: Csv Regular Expression Parser
FILE: crep.py

DESCRIPTION:
  Parses Comma Separated Value files as similar
  as the traditional utility grep does.
  The output are whole lines, but paterns must
  match within defined cells, not anywhere within
  the line. That the main difference from grep.

SYNTAX:
  crep [-f <file>] [-eErR <parametr1>]...

USAGE:
  crep -f DESC.csv -r3 enclosure -r1 005-ba
  cat DESC.csv | crep.pl -r3 enclosure -r1 005-ba
  

PARAMETERS:
  -f  <file>  - source file
  -e? <value> - case insensitive value
  -E? <ValUE> - case sensitive value
  -r? <regex> - case insensitive regular expression
  -R? <RegEx> - case sensitive regular expression

  The question mark in parameters above 
  represents a cell ID.

VERSION: %s TSIF/R4
""" % (VERSION)

####################################################################### }}} 1
## PARAMETERS ######################################################### {{{ 1

import sys
import os
import re
#import str

FILE_INPUT = ""
AFILTER    = []
LINE       = ""

if len(sys.argv) <= 1:
  print MANUAL
  exit(0)


for idx in range(1,len(sys.argv),1):
  argx = sys.argv[idx]
  if re.match("-+f",argx): 
    FILE_INPUT=sys.argv[idx+1]; 
    idx=idx+1; 
    continue
  if re.match("-+[eErRvVqQ][0-9]+",argx):
    dat=sys.argv[idx+1]; idx=idx+1
    txt=re.sub("^-+","",argx)
    typ,cid=(re.match("(.)([0-9]+)",txt)).group(1,2)
    AFILTER.append("%s,%s,%s" % (typ,cid,dat))
    continue

for idx in range(len(AFILTER)):
  DAT=AFILTER[idx]
  if re.match("[ervq]",DAT): AFILTER[idx]=DAT.lower()

if (not FILE_INPUT) and (sys.stdin.isatty): FILE_INPUT = "-"
if not FILE_INPUT: 
  print "#- Error: input file missing !"
  exit(1)

####################################################################### }}} 1
## MAIN ############################################################### {{{ 1

if(FILE_INPUT == "-"):
  fh=sys.stdin
else:
  fh=open(FILE_INPUT,"r")

for LINE in fh:
  LINE=LINE.rstrip("\n")
  if re.match("\s*#",LINE): continue
  if re.match("\s*$",LINE): continue
  ALINE=re.split("\s*;\s*",LINE)
  FFLAG=1
  for ARGP in AFILTER:
    TYP,CID,VAL = re.split(",",ARGP)
    #if ALINE[CID]: 
    ADAT=ALINE[int(CID)]
    #else: 
    #  ADAT=""
    IDAT=ADAT.lower()

    if(TYP=="e") and (IDAT != VAL): FFLAG=0
    if(TYP=="E") and (ADAT != VAL): FFLAG=0
    if(TYP=="v") and (IDAT == VAL): FFLAG=0
    if(TYP=="V") and (ADAT == VAL): FFLAG=0

    if(TYP=="r") and not re.search(VAL,IDAT,re.IGNORECASE): FFLAG=0
    if(TYP=="R") and not re.search(VAL,IDAT): FFLAG=0
    if(TYP=="q") and re.search(VAL,IDAT,re.IGNORECASE): FFLAG=0
    if(TYP=="Q") and re.search(VAL,IDAT): FFLAG=0

    if FFLAG: print LINE
fh.close

####################################################################### }}} 1
# --- end ---

