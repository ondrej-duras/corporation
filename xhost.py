#!/usr/bin/env python2
## MANUAL ############################################################# {{{ 1

VERSION = "2021.122902"
MANUAL  = """
NAME: xHOST resolver
FILE: xhost.py

DESCRIPTION:
  simple utility

EXAMPLES:
  xhost 1.2.3.4 2.3.4.5
  xhost www.orange.sk
  xhost -a www.orange.sk
  xhost -ptr 1.2.3.4
  xhost -L L-001-BB-DI
  xhost -l l-001-bb-di

OPER_MODE: parameter/s

     raw:    -l --raw --list
     RAW:    -L --RAW --LIST
     host:   -r --host --resolve
     tsif:   -t --tsif
     TSIF:   -T --TSIF
     ip:     -ip --ip
     name:   -name --name
     ipname: -ipname --ipname
     nameip: -nameip --nameip

NOTE:
  Uppercase OPER_MODE is case sensitive
  lowercase OPER_MODE is case insensitive

SEE ALSO:
  https://github.com/ondrej-duras/

VERSION: %s
""" % (VERSION)



####################################################################### }}} 1
## DEFAULTS ########################################################### {{{ 1

import socket
import re
import sys
import os

OPER_MODE = "host" 
# host - system resolver used,
# raw  - hostlist-raw.csv used; case insensitive
# RAW  - hostlist-raw.csv used; case sensitive
# tsif - hostlist-tsif.csv used; case insensitive
# TSIF - hostlist-tsif.csv used; case sensitive
# ip   - trying to find PTR
# name - trying to find A

# HOSTLIST = os.path.dirname(os.path.realpath(__file__)) + "/" + "hostlist-raw.csv"

####################################################################### }}} 1
## LIBRARY ############################################################ {{{ 1

def xresolve_a(host):
  try:
    result = socket.gethostbyname(host)
  except:
    result = ""
  return result


def xresolve_ptr(host):
  try:
    result = str(socket.gethostbyaddr(host)[0])
  except:
    result = ""
  return result


def xresolve_host(host):
  if re.match("[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$",host):
    result = xresolve_ptr(host)
  else:
    result = xresolve_a(host)
  return result


def homefile(fname):
  return os.path.dirname(os.path.realpath(__file__)) + "/" + fname


def grepline(fname,host,ignore=True):
  fh = open(fname,'r')
  if ignore:
    rx = re.compile(host,re.IGNORECASE)
  else:
    rx = re.compile(host)
  for xline in fh.readlines(False):
    line = xline.strip()
    if rx.search(line):
      print(line)
  fh.close()


####################################################################### }}} 1
## MAIN ############################################################### {{{ 1


if __name__ == "__main__":
    #print(xresolve_a("www.orange.sk"))
    #print(xresolve_ptr("213.151.200.101"))
    #print(xresolve_host("www.orange.sk"))
    #print(xresolve_host("213.151.200.101"))
    sys.argv.pop(0)
    if len(sys.argv) == 0:
      print MANUAL
      exit()
    #for argx in sys.argv:
    #  print("%s %s" % (argx,xresolve_host(argx)))
    while True:
      try:
        argx = sys.argv.pop(0)
      except:
        exit()

      # OPER_MODE changes
      if argx in ("-l","--raw","--list"):
        OPER_MODE = "raw"; continue
      if argx in ("-L","--RAW","--LIST"):
        OPER_MODE = "RAW"; continue
      if argx in ("-r","--host","--resolve"):
        OPER_MODE = "host"; continue
      if argx in ("-t","--tsif"):
        OPER_MODE = "tsif"; continue
      if argx in ("-T","--TSIF"):
        OPER_MODE = "TSIF"; continue
      if argx in ("-ip","--ip"):
        OPER_MODE = "ip"; continue
      if argx in ("-name","--name"):
        OPER_MODE = "name"; continue
      if argx in ("-ipname","--ipname"):
        OPER_MODE = "ipname"; continue
      if argx in ("-nameip","--nameip"):
        OPER_MODE = "nameip"; continue
      

      # OPER_MODE application
      if OPER_MODE == "host":
        print("%s %s" % (argx,xresolve_host(argx))); continue

      if OPER_MODE in ("ip","name","ipname","nameip"):
        HOST = argx
        DEVIP = xresolve_host(argx) 
        if re.match("[0-9]+\.[0-9]+\.[0-9]+\.[0-9]$",HOST):
          X=HOST; HOST=DEVIP; DEVIP=X

        if OPER_MODE == "ip":
          print(DEVIP); continue
        if OPER_MODE == "name":
          print(HOST);  continue 
        if OPER_MODE == "ipname":
          print("%s %s" % (DEVIP,HOST)); continue
        if OPER_MODE == "nameip":
          print("%s %s" % (HOST,DEVIP)); continue

      elif OPER_MODE == "raw":
        grepline(homefile("hostlist-raw.csv"),argx); continue
      elif OPER_MODE == "RAW":
        grepline(homefile("hostlist-raw.csv"),argx,False); continue

      elif OPER_MODE == "tsif":
        grepline(homefile("hostlist-tsif.csv"),argx); continue
      elif OPER_MODE == "TSIF":
        grepline(homefile("hostlist-tsif.csv"),argx,False); continue



####################################################################### }}} 1
# --- end ---
