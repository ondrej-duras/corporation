#!/usr/bin/env python2
# 20220510, Ing. Ondrej DURAS (dury)
## MANUAL ############################################################# {{{ 1

VERSION = "2022.051001"
MANUAL  = """
NAME: DIG.py - simplified 'dig' utility for DNS troubleshooting
FILE: dig.py

DESCRIPTION:
  ... have a look into 'dig' manual page
  But in this case it's a simplified python script
  demonstrating how to troubleshoot DNS issues 
  against remote DNS servers using python 
  with dnspython or dnspython3 package

  Script uses pure python2 or 3
  pip install dnspython
  is an only package you need for both
  dns.resolver and dns.reversename
  or 
  pip install dnspython[doh,dnssec,idna]
  pip install dnspython[wni]
  Where 
  doh - is DNS over HTTPs (used by browsers)
  dnssec - allows troubleshoot DNSSEC features
  idna - internationalized domain names
  wmi - uses WMI in windows except to 
        determine DNS except the registry scanning

USAGE:
  dig.py www.google.com www.zoznam.sk
  dig.py @8.8.8.8 =A www.google.com
  dig.py @8.8.8.8 @8.8.4.4 =CNAME poznamky.net
  dig =SOA orange.sk
  dig.py 8.8.8.8 8.8.4.4 # =PTR is authomaticaly

PARAMETERS:
  @ - is a prefix of IP address or or FQDN of DNS server
  = - is a prefix of type of DNS record

RECORD TYPES:
  =A ........ Host address (default)
  =AAAA ..... IPv6 Host address
  =AFSDB .... AFS Database location
  =ALIAS .... Auto resolved alias
  =CAA ...... Certification Authority Authorization
  =CERT ..... Certificate / CRL
  =CNAME .... Canonical name for alias
  =DHCID .... DHCP Information
  =DNAME .... Non-Terminal DNS Name Redirection
  =DNSKEY ... DNSSEC public key
  =DS ....... Delegation Signer
  =HINFO .... Host Information
  =HTTPS .... HTTPS Service binding and parameter specification
  =LOC ...... Location Information
  =MX ....... Mail eXchange
  =NAPTR .... Naming Authority Pointer
  =NS ....... Name Server
  =NSEC ..... Next Secure
  =NSEC3 .... Next Secure v.3
  =NSEC3PARAM NSEC3 parameters
  =PTR ...... Pointer for reverse translation (all IPv4 aut.)
  =RP ....... Responsible Person
  =RRSIG .... RRset Signature
  =SOA ...... Start Of Authority
  =SRV ...... Location of Service
  =TLSA ..... Transport Layer Security Authentication
  =TXT ...... Desciptive Text

SEE ALSO:
  xhost.py - hostlist managing utility
  https://github.com/ondrej-duras/
  https://www.dnspython.org/
  https://pypi.org/project/dnspython3/
  https://stackoverflow.com/questions/5235569/using-the-dig-command-in-python
  https://github.com/rthalley/dnspython/blob/master/examples/reverse_name.py
  https://dnspython.readthedocs.io/en/latest/resolver-class.html
  https://simpledns.plus/help/dns-record-types

VERSION: %s
""" % (VERSION)
####################################################################### }}} 1
## MAIN ############################################################### {{{ 1


import socket
import dns.reversename
import dns.resolver
import sys
import re

NEXTARG=True
DNSSRV=[]
DNSTYPE="A"


#  manual page if none parameter provided
sys.argv.pop(0)
if len(sys.argv) == 0:
  print(MANUAL)
  exit()

# main cycle of the script
while NEXTARG:
  if len(sys.argv) == 0: NEXTARG=False; break
  ARGX = sys.argv.pop(0)
  
  # adding new DNS server to the list
  if ARGX[0] == "@":
    DNSSRV.append(socket.gethostbyname(ARGX[1:]))
    continue

  # changing type of queried DNS record
  if ARGX[0] == "=":
    DNSTYPE = ARGX[1:]
    continue

  # if queried FQDN is an IP address, change DNS record type to PTR
  ITEM = ARGX
  TYPE = DNSTYPE
  if re.match("[0-9]{1,3}(\.[0-9]{1,3}){3}$",ITEM):
    ITEM = dns.reversename.from_address(ITEM)
    TYPE = "PTR"

  # query a system default DNS servers
  if len(DNSSRV) == 0:
    try:
      reply = dns.resolver.query(ITEM,TYPE)
      for rdata in reply: 
        print(rdata)
    except:
      print("# none %s record found for '%s'" % (TYPE,ITEM))
    continue

  # query an explicit DNS server/s provides via @ at command-line
  else:
    resolver = dns.resolver.Resolver()
    resolver.nameservers=DNSSRV
    try:
      for rdata in resolver.query(ITEM,TYPE):
        print(rdata)
    except:
      print("# none %s record found for '%s' (dns: %s)" % (TYPE,ITEM,str(DNSSRV)))
    continue


####################################################################### }}} 1
# --- end ---

