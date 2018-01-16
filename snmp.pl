#!/usr/bin/perl


our $VERSION = 2018.011601;
our $MANUAL  = <<__MANUAL__;
NAME: SNMP tshoot
FILE: snmp.pl

DESCRIPTION:
  It's a SNMP troubleshooting portable script.

USAGE:
  snmp.pl -ver 2c -comm xyPublic -try 1.2.3.4 2.3.4.5

PARAMETERS:
  --version 2c   - version of SNMP protocol (1/2/2c)
  --community xy - SNMP community
  --timeout 3    - 3 seconds of timeout
  --info         - query for sysName sysTime sysDesc
  --detype       - give me a type of device

SEE ALSO:
  https://github.com/ondrej-duras/

VERSION: ${VERSION}
__MANUAL__


use strict;
use warnings;
use Net::SNMP;

our @IPLIST=();
our @OBJLST=();
our @TABLST=();
our $MONVE = "2c";
our $MONCO = "public";
our $MONTI = 2;     # in seconds
our $MONRE = 2;     # 2x retries
our $MODE_INFO = 0; # --info
our $MODE_DETY = 0; # --detype
our $MODE_OBJ  = 0; # --object
our $MODE_TAB  = 0; # --table
our $ERR = 0;

our %CONF_MIB=(
   'sysDescr'    =>   '1.3.6.1.2.1.1.1.0', # 0
   'sysObjectID' =>   '1.3.6.1.2.1.1.2.0', # 1
   'sysUpTime'   =>   '1.3.6.1.2.1.1.3.0', # 2 in hundreds of second since the last start of the device
   'sysContact'  =>   '1.3.6.1.2.1.1.4.0', # 3
   'sysName'     =>   '1.3.6.1.2.1.1.5.0', # 4 
   'sysLocation' =>   '1.3.6.1.2.1.1.6.0', # 5
   'sysServices' =>   '1.3.6.1.2.1.1.7.0',  # 6
   'ifPhysAddress' => '1.3.6.1.2.1.2.2.1.6.1'   # MAC address of the 1st interface
);

our @CONF_RQOIDS=(
      '1.3.6.1.2.1.1.1.0',    # 0 - sysDescr
      '1.3.6.1.2.1.1.2.0',    # 1 - sysObjectID
      '1.3.6.1.2.1.1.3.0',    # 2 - sysUpTime
      '1.3.6.1.2.1.1.4.0',    # 3 - sysContact
      '1.3.6.1.2.1.1.5.0',    # 4 - sysName
      '1.3.6.1.2.1.1.6.0',    # 5 - sysLocation
      '1.3.6.1.2.1.1.7.0',    # 6 - sysServices
      '1.3.6.1.2.1.2.2.1.6.1' # ifPhysAddress of the first interface
);



unless(scalar(@ARGV)) {
  print $MANUAL;
  exit;
}


while(my $ARGX = shift @ARGV) {
  if($ARGX =~ /^-+v/) { $MONVE = shift @ARGV; next; } # --version 
  if($ARGX =~ /^-+c/) { $MONCO = shift @ARGV; next; } # --community
  if($ARGX =~ /^-+t/) { $MONTI = shift @ARGV; next; } # --timeout
  if($ARGX =~ /^-+r/) { $MONRE = shift @ARGV; next; } # --retries
  if($ARGX =~ /^-+d/) { $MODE_DETY = 1; next; } # --detype
  if($ARGX =~ /^-+i/) { $MODE_INFO = 1; next; } # --info
  unless($ARGX =~ /^-/) { push @IPLIST,$ARGX; next; } # IPaddress/HostName
  warn "#- Warning: wrong argument '${ARGX}' !\n";
  $ERR =1;
}
if($ERR) { die "#- Error.\n"; }

if($MODE_INFO) {
  foreach my $DEVIP (@IPLIST) {
    my ($snmp,$err) = Net::SNMP->session(
     -hostname  => $DEVIP,
     -version   => $MONVE,
     -community => $MONCO,
     -timeout   => $MONTI,
     -retries   => $MONRE
    );
    unless(defined $snmp) {
      print "#- Error: ${err}\n"; next;
    }
    # Getting response from device
    my $SNMP_ANS=$snmp->get_request( -varbindlist=>\@CONF_RQOIDS );
    foreach my $KEY ( sort keys %CONF_MIB ) {
      my $DATA=$SNMP_ANS->{$CONF_MIB{$KEY}};
      $DATA=~s/;|\n/,/g; $DATA=~s/\r//g; $DATA=~s/\x00//g;
      $DATA="#noSuchInstance#" if $DATA eq "noSuchInstance";
      printf("%-25s ..... %s\n",$KEY,$DATA);
    }
    $snmp->close();
  }
}

