#!/usr/bin/env python2
##!/usr/bin/env python3
20210514, Ing. Ondrej DURAS (dury)


VERSION = "2021.070601"
MANUAL  = """
NAME: BTU to kW
FILE: btu.py

DESCRIPTION:
  kW = BTU/hr * 0.000293071
  It's a simple calculator for deployment
  of devices into datacenter.

  BTU is a British Termal Unit.
  The British thermal unit (BTU or Btu) is a unit of heat
  It is defined as the amount of heat required to raise 
  the temperature of one pound of water by one degree.

  Expression above depicts how to calculate expected
  permanent electricity consuption of the device in kW.

  Usually a BTU/hr for particular kind of device
  can be found mentioned within its datasheet.

USAGE:
  btu.py 1328
  0.389 kW = 1328.000 BTY/hr * 0.000293071

SEE ALSO:
  https://github.com/ondrej-duras/
  
VERSION: %s
""" % (VERSION)


BTU=0.000293071  # kW
def btu2kw(b):
  b = float(b)
  w = b*BTU
  print ("%5.3f kW = %5.3f BTY/hr * 0.000293071" % (w,b))
  return w

import sys

if __name == "__main__":
  argc = len(sys.argv) 
  if argc < 2:
    print(MANUAL)
    exit()
  
  argi=1
  while argi < argc:
    print (btu2kw(sys.argv[argi]))
    argi += 1

# --- end ---


 
