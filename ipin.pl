#!/usr/bin/perl
# IPIN - IP comparator / calculator
# 20171127, Ing. Ondrej DURAS (dury), Orange Slovensko
# GPL; It' not perfect, but feel free to use.


use strict;
use warnings;

## MANUAL ############################################################# {{{ 1

our $VERSION = 2021.032201;
our $MANUAL  = <<__MANUAL__;
NAME: IPIN
FILE: ipin.pl

DESCRIPTION:
  The script compares two or more IP address ranges.
  The script supports all three usual formats
   - 1.2.3.4 .................. as a single host
   - 1.2.3.4/12 ............... as network range
   - 1.2.3.4/255.240.0.0 ...... as network range

USAGE:
  ipin --includes  172.20.36.0/24 172.20.36.38/27 172.20.36.123
  ipin --contained 172.20.36.123  172.20.36.0/24 172.16.0.0/12 10.0.0.0/8
  ipin --details   172.20.36.123/24
  ipin --network   172.20.36.123/24 172.20.36.127/25
  ipin --line --contained 10.28.17.10/24 -search config.txt
  ipin --contained 10.28.17.10/28 -search config.txt --gw
  ipin --includes 172.20.36.123/24 -grep config.txt
  ipin --include 10.0.0.0/8 -f5 --grep viprion-one-line.txt
  ipin --range 172.20.36.123/27


PARAMETERS:
  --includes   <network/mask> includes following IP/ranges
  --containded <network/mask> is included in following IP/ranges
  --details       calculates all usual details
  --network       calculates network and broadcast addresses
  --search <file> searches for IP addresses - standalone words
  --grep <file>   searches for IP addresses - cuts all non-IP parts
  --line          shows line numbers
  --no-line       hides line numbers
  --gw / --zero   includes 0.0.0.0 (usefull with --contained)
  --no-gw         excludes 0.0.0.0 (default / usefull with --contained)
  --f5            removes F5 routing domains from IP addresses
  --range         provides a range of usefull IPs (Net+4 -dash- Broadcast-1)

SEE ALSO:
  https://github.com/ondrej-duras/

VERSION: ${VERSION} development in progress
__MANUAL__

####################################################################### }}} 1
## IPIN procedures #################################################### {{{ 1

# Declarations of all functions
sub ipin($$);     # compares IPA and IPB
sub ipin2bin($);  # translates IP from ASCII to number
sub ipin2mask($); # translates network mask to number
sub ipin2dot($);  # translates IP from number to ASCII
sub ipin_err($$); # ipin error handling

our $IPIN_ERROR=0;  # error codes
our $IPIN_ETEXT=""; # error translated into human readable reason
our $IPIN_EMODE=0;  # mode of the error handling

# table for IP mask translation from ASCII into BIN
our %IPIN_TRANSLATE=(                     #12345678
 "0"=>0x00000000,         "0.0.0.0"=>0x00000000,
 "1"=>0x80000000,       "128.0.0.0"=>0x80000000,
 "2"=>0xc0000000,       "192.0.0.0"=>0xc0000000,
 "3"=>0xe0000000,       "224.0.0.0"=>0xe0000000,
 "4"=>0xf0000000,       "240.0.0.0"=>0xf0000000,
 "5"=>0xf8000000,       "248.0.0.0"=>0xf8000000,
 "6"=>0xfc000000,       "252.0.0.0"=>0xfc000000,
 "7"=>0xfe000000,       "254.0.0.0"=>0xfe000000,
 "8"=>0xff000000,       "255.0.0.0"=>0xff000000,
 "9"=>0xff800000,     "255.128.0.0"=>0xff800000,
"10"=>0xffc00000,     "255.192.0.0"=>0xffc00000,
"11"=>0xffe00000,     "255.224.0.0"=>0xffe00000,
"12"=>0xfff00000,     "255.240.0.0"=>0xfff00000,
"13"=>0xfff80000,     "255.248.0.0"=>0xfff80000,
"14"=>0xfffc0000,     "255.252.0.0"=>0xfffc0000,
"15"=>0xfffe0000,     "255.254.0.0"=>0xfffe0000,
"16"=>0xffff0000,     "255.255.0.0"=>0xffff0000,
"17"=>0xffff8000,   "255.255.128.0"=>0xffff8000,
"18"=>0xffffc000,   "255.255.192.0"=>0xffffc000,
"19"=>0xffffe000,   "255.255.224.0"=>0xffffe000,
"20"=>0xfffff000,   "255.255.240.0"=>0xfffff000,
"21"=>0xfffff800,   "255.255.248.0"=>0xfffff800,
"22"=>0xfffffc00,   "255.255.252.0"=>0xfffffc00,
"23"=>0xfffffe00,   "255.255.254.0"=>0xfffffe00,
"24"=>0xffffff00,   "255.255.255.0"=>0xffffff00,
"25"=>0xffffff80, "255.255.255.128"=>0xffffff80,
"26"=>0xffffffc0, "255.255.255.192"=>0xffffffc0,
"27"=>0xffffffe0, "255.255.255.224"=>0xffffffe0,
"28"=>0xfffffff0, "255.255.255.240"=>0xfffffff0,
"29"=>0xfffffff8, "255.255.255.248"=>0xfffffff8,
"30"=>0xfffffffc, "255.255.255.252"=>0xfffffffc,
"31"=>0xfffffffe, "255.255.255.254"=>0xfffffffe,
"32"=>0xffffffff, "255.255.255.255"=>0xffffffff,
);

=pod
SYNTAX: RESULT=ipin(IPrange_A,IPrange_B)
DESCRIPTION:
  Procedure compares two IP ranges or even IP addrreses

PARAMETERS:
  IPrange_A and IPrange_B have the same meaning.
  Both they can occur in three forms:
  1.2.3.4/24 - IP adress and number mask in bits
  1.2.3.4/255.0.0.0 - IP range and bitmask 
  1.2.3.4  - that means the same like 1.2.3.4/32

RESULTS:
  3 - when both ranges are equal
  2 - when IPrange_A is contained in IPrange_B
  1 - when IPrange_B is contained in IPrange_A
  0 - when both ranges are different
=cut

sub ipin($$) {
  # taking parameters IP address IPXx and mask IPMx
  my($IPQA,$IPQB)=@_;

  # parameter handling
  my($IPXA,$IPXB) = ($IPQA,$IPQB);
  my($IPMA,$IPMB) = (0xffffffff,0xffffffff);
  my($NETA,$NETB) = (0x00000000,0x00000000);
  if($IPXA =~ /\//) { ($IPXA,$IPMA) = split(/\//,$IPXA,2); }
  if($IPXB =~ /\//) { ($IPXB,$IPMB) = split(/\//,$IPXB,2); }

  # transform IP adressses to tehir binary form
  $IPXA = ipin2bin($IPXA);
  $IPXB = ipin2bin($IPXB);

  # errors during the translation of IP to binnary
  if(($IPXA == -1) or ($IPXB == -1)) { 
    ipin_err 101,"Wrong IP address or range !";
    return -1; 
  }

  # translating IP masks to binary
  unless($IPMA == 0xffffffff) {
    unless(exists $IPIN_TRANSLATE{$IPMA}) { 
      ipin_err 102,"Wrong network mask (1p) !";
      return -1; 
    }
    $IPMA = $IPIN_TRANSLATE{$IPMA};
  }

  unless($IPMB == 0xffffffff) {
    unless(exists $IPIN_TRANSLATE{$IPMB}) { 
      ipin_err 103,"Wrong network mask (2p) !";
      return -1; 
    }
    $IPMB = $IPIN_TRANSLATE{$IPMB};
  }

  # calculating the network address
  $NETA = $IPXA & $IPMA;
  $NETB = $IPXB & $IPMB;

  # the Network Decission
  my $RESULT = 0;
  if(($IPXA & $IPMB) == $NETB) { $RESULT+=2; }
  if(($IPXB & $IPMA) == $NETA) { $RESULT+=1; }
  return $RESULT;
}

=pod
SYNTAX: $BIN_IP=ipin2bin("1.2.3.4")
DESCRIPTION:
  translates IP address from ASCII
  form into BINary number and returns it.
=cut

sub ipin2bin($) {
  my $IPXA=shift;
  $IPXA =~ s/\/.*//;
  unless ($IPXA =~ /^[0-9]{1,3}(\.[0-9]{0,3}){3}$/) {
    ipin_err 201,"Wrong IP address /regexp !";
    return -1;
  }
  my ($QA,$QB,$QC,$QD)=split(/\./,$IPXA,4);
  unless (($QA<256) and ($QB<256) and ($QC<256) and ($QD<256)) {
    ipin_err 202,"Wrong IP address : octet exceeds 256 !"; 
    return -1;
  }
  my $BIN=((($QA*256)+$QB)*256+$QC)*256+$QD;
  return $BIN;
}

=pod
SYNTAX: 
  $BINMASK = ipin2mask("");  .................. returns 0xffffffff
  $BINMASK = ipin2mask("255.255.0.0") ......... returns 0xffff0000
  $BINMASK = ipin2mask("255.0.0.0") ........... returns 0xff000000
  $BINMASP = ipin2mask("10.1.1.2/16") ......... returns 0xffff0000
  $BINMASK = ipin2mask("1.1.1.1/128.0.0.0") ... returns 0x80000000
DESCRIPTION:
  Simply it proceeds an network mask extranction from the given
  parameter. Then it calculates the binary mask.
=cut

sub ipin2mask($) {
  my $IPMA=shift;

  unless($IPMA) { return 0xffffffff; }
  # stripping predseded IP and slash
  if($IPMA =~ /\//) {
     $IPMA =~ s/^.*\///;
  }
  if(exists $IPIN_TRANSLATE{$IPMA}) {
    return $IPIN_TRANSLATE{$IPMA};
  }
  ipin_err 401,"Wrong network mask !";
  return -1;
}

=pod
SYNTAX: $ASCII_IP = ipin2dot(0x12345678)
DESCRIPTION:
  translates IP from its binary form
  back into ASCII in 3-dots format.
=cut

sub ipin2dot($) {
  my $IPXA=shift;
  unless($IPXA =~ /^[0-9]+$/) {
    ipin_err 301,"Wrong IP ! None valid character found !"; 
    return "-1";
  }
  $IPXA = int $IPXA;
  unless ($IPXA <= 0xffffffff) {
    ipin_err 302,"Wrong IP ! exceeds 32-bit range !"; 
    return "-1";
  }
  unless ($IPXA >= 0x00000000) {
    ipin_err 303,"Wrong IP ! signed interger in IP !"; 
    return "-1";
  }
  my ($QA,$QB,$QC,$QD);
  $QD = $IPXA & 255; $IPXA=$IPXA>>8;
  $QC = $IPXA & 255; $IPXA=$IPXA>>8;
  $QB = $IPXA & 255; $IPXA=$IPXA>>8;
  $QA = $IPXA & 255; $IPXA=$IPXA>>8;
  return sprintf("%d.%d.%d.%d",$QA,$QB,$QC,$QD);
}

=pod
SYNTAX: ipin_err 123,"Something wrong";
DESCRIPTION: handles IPIN related errors
=cut

sub ipin_err($$) {
  my($ECODE,$ETEXT)=@_;

  # storing message for further purposes
  $IPIN_ERROR = $ECODE;
  $IPIN_ETEXT = $ETEXT;
  return if $IPIN_EMODE == 0;

  # displaying message to STDERR
  print STDERR "#- Error(${ECODE}): ${ETEXT}\n";
  return if $IPIN_EMODE == 1;

  # exiting if required
  exit $ECODE;

}
####################################################################### }}} 1
## MAIN - Defaults and CommandLine #################################### {{{ 1

our $IPIN_INC = "";    # --includes
our $IPIN_CON = "";    # --contained 
our $IPIN_DTL = 0;     # --details
our $IPIN_NET = 0;     # --network
our $IPIN_SRC = "";    # --search <file>
our $IPIN_GRP = "";    # --grep <file>
our $IPIN_LIN = 0;     # --line =1 / --no-line =0
our $IPIN_DGW = 0;     # --gw =1 --zero =1 --no-gw =0 --no-zero =0
our $IPIN_F5M = 0;     # --f5 --bigip -rd
our $IPIN_RNG = 0;     # --range
our $MODE_VERBOSE = 0; # 0-silent 1-full listing
our $FFLAG = 0; 
our @ALIST=(); # list of IP addresses
our $FH;               # file handler

# Command-line handling
my $CTARG=scalar(@ARGV);
if($CTARG <2) {
  print $MANUAL;
  exit;
}

while(my $ARGX = shift @ARGV) {
  if($ARGX =~ /^-+line/)         { $IPIN_LIN=1; next; } # --line
  if($ARGX =~ /^-+no-?line/)     { $IPIN_LIN=0; next; } # --no-line
  if($ARGX =~ /^-+(gw|zero)/)    { $IPIN_DGW=1; next; } # --gw  --zero
  if($ARGX =~ /^-+no-?(gw|zero)/){ $IPIN_DGW=0; next; } # --no-gw --no-zero
  if($ARGX =~ /^-+(f5|rd|bigip)/){ $IPIN_F5M=1; next; } # --f5 --bigip -rd
  if($ARGX =~ /^-+v/) { $MODE_VERBOSE = 1; next; }      # --verbose
  if($ARGX =~ /^-+i/) { $IPIN_INC = shift @ARGV; next; }# --includes
  if($ARGX =~ /^-+c/) { $IPIN_CON = shift @ARGV; next; }# --contained
  if($ARGX =~ /^-+d/) { $IPIN_DTL = 1; next; }          # --details
  if($ARGX =~ /^-+n/) { $IPIN_NET = 1; next; }          # --network
  if($ARGX =~ /^-+r/) { $IPIN_RNG = 1; next; }          # --range
  if($ARGX =~ /^-+g/) { $IPIN_GRP = shift @ARGV; next; }# --grep <file>
  if($ARGX =~ /^-+s/) { $IPIN_SRC = shift @ARGV; next; }# --search <file>
  if($ARGX =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}$/) { push @ALIST,$ARGX; next; }
  if($ARGX =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}\/[0-9]+$/) { push @ALIST,$ARGX; next; }
  if($ARGX =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}\/[0-9]{1,3}(\.[0-9]{1,3}){3}$/) { push @ALIST,$ARGX; next; }
  warn "#- Error: wrong parameter '${ARGX}'\n";
  $FFLAG=1;
}
if($FFLAG) { die "#- Errors found.\n"; }

####################################################################### }}} 1
## MAIN - simple line --include --contain --details --net ############# {{{ 1


if($IPIN_INC) {
  foreach my $XIP (@ALIST) {
    next unless(ipin($IPIN_INC,$XIP) & 1);
    print "${XIP}\n";
  }
}

if($IPIN_CON) {
  foreach my $XIP (@ALIST) {
    next unless(ipin($IPIN_CON,$XIP) & 2);
    print "${XIP}\n";
  }
}

if($IPIN_DTL) {
  foreach my $XIP (@ALIST) {
    my $BIP = ipin2bin($XIP);
    my $BMS = ipin2mask($XIP);
    my $NEG = 0xffffffff - $BMS;
    my $NIP = $BIP & $BMS;
    my $BCS = $BIP | $NEG;
    my $GWA = $NIP +1;
    my $ND1 = $NIP +2;
    my $ND2 = $NIP +3;
    my $FST = $NIP +4;
    my $LST = $BCS -1;
    my $HBT = 0;
    my $BXX = $NEG;
    while($BXX > 0 ) { $HBT++; $BXX=$BXX>>1; }
    my $NBT = 32 - $HBT;
    my $URG = ipin2dot($FST) . "-" . ipin2dot($LST);
    if(($HBT>2) && ($HBT<9)) {
      my $LOC = ipin2dot($LST); $LOC=~s/.*\.//;
      $URG = ipin2dot($FST) . "-" . $LOC;
    }
    if($HBT<3) { $URG = "none"; }
    print "IP address ................ " . ipin2dot($BIP) ."\n";
    print "Network Mask .............. " . ipin2dot($BMS) ."\n";
    print "Network Bits .............. " . $NBT ."\n";
    print "Host Bits ................. " . $HBT ."\n";
    print "Network Address ........... " . ipin2dot($NIP) ."\n";
    print "Default Gateway ........... " . ipin2dot($GWA) ."\n" if $HBT > 2;
    print "Primary Node .............. " . ipin2dot($ND1) ."\n" if $HBT > 2;
    print "Secondary Node ............ " . ipin2dot($ND2) ."\n" if $HBT > 2;
    print "Firts Usable IP address ... " . ipin2dot($FST) ."\n" if $HBT > 2;
    print "Last Usable IP address .... " . ipin2dot($LST) ."\n" if $HBT > 2;
    print "Usable IP addresses ....... " . $URG ."\n" if $HBT > 2;
    print "Broadcast address ......... " . ipin2dot($BCS) ."\n\n";
  }
}

if($IPIN_RNG) {
  foreach my $XIP (@ALIST) {
    my $BIP = ipin2bin($XIP);
    my $BMS = ipin2mask($XIP);
    my $NEG = 0xffffffff - $BMS;
    my $NIP = $BIP & $BMS;
    my $BCS = $BIP | $NEG;
    my $GWA = $NIP +1;
    my $ND1 = $NIP +2;
    my $ND2 = $NIP +3;
    my $FST = $NIP +4;
    my $LST = $BCS -1;
    my $HBT = 0;
    my $BXX = $NEG;
    while($BXX > 0 ) { $HBT++; $BXX=$BXX>>1; }
    my $NBT = 32 - $HBT;
    my $URG = ipin2dot($FST) . "-" . ipin2dot($LST);
    if(($HBT>2) && ($HBT<9)) {
      my $LOC = ipin2dot($LST); $LOC=~s/.*\.//;
      $URG = ipin2dot($FST) . "-" . $LOC;
    }
    if($HBT<3) { $URG = "none"; }
    if( -t STDOUT) {
      print "${URG}\n";
    } else {
      if(scalar(@ALIST) == 1) {
        print "${URG}";
      } else {
        print "${URG}\n";
      }
    }
  }
}

if($IPIN_NET) {
  my %QLIST=();
  my $FFLAG = "";
  my $FCOUNT= 64;
  foreach my $XIP (@ALIST) {
    my $BIP = ipin2bin($XIP);
    my $BMS = ipin2mask($XIP);
    my $NEG = 0xffffffff - $BMS;
    my $NIP = $BIP & $BMS;
    my $BCS = $BIP | $NEG;
    if(exists($QLIST{$NIP})) { 
      $FFLAG=chr($QLIST{$NIP}); }
    else {
      $FCOUNT++ if $FCOUNT<ord('Z');
      $QLIST{$NIP} = $FCOUNT;
      $FFLAG=chr($FCOUNT);
    }
    printf("%15s %15s %15s  %s\n",ipin2dot($BIP),ipin2dot($NIP),ipin2dot($BCS),$FFLAG); 
  }
}

####################################################################### }}} 1
## MAIN - --search --grep for --include and --contained ############### {{{ 1


if($IPIN_SRC and $IPIN_INC) {
  if($IPIN_SRC eq "-") { open $FH,"<&STDIN" or die "#- Error: STDIN unreachable !\n"; }
  else { open $FH,"<",$IPIN_SRC or die "#- Error: File  '${IPIN_SRC}' unreachable !\n"; }
  my $CTLINE = 0;
  while( my $LINE=<$FH>) {
   chomp $LINE;
   $CTLINE++;
   my @AITEMS = split(/\s+/,$LINE);
   foreach my $ITEM (@AITEMS) {
     next unless $ITEM =~ /^[0-9]/;
     my $FFLAG=0;
     $ITEM=~s/\%[0-9]+// if $IPIN_F5M;
     $FFLAG=1 if( $ITEM =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}$/);
     $FFLAG=1 if( $ITEM =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}\/[0-9]{1,3}(\.[0-9]{1,3}){3}$/);
     $FFLAG=1 if( $ITEM =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}\/[0-9]{1,2}$/);
     next unless $FFLAG;
     if(ipin($IPIN_INC,$ITEM) & 1) { 
       if($IPIN_LIN) { print "$CTLINE;${LINE}\n"; }
       else          { print "${LINE}\n"; }
       last; 
     }
   }
  }
  close $FH;
}

if($IPIN_SRC and $IPIN_CON) {
  if($IPIN_SRC eq "-") { open $FH,"<&STDIN" or die "#- Error: STDIN unreachable !\n"; }
  else { open $FH,"<",$IPIN_SRC or die "#- Error: File  '${IPIN_SRC}' unreachable !\n"; }
  my $CTLINE = 0;
  while( my $LINE=<$FH>) {
   chomp $LINE;
   $CTLINE++;
   my @AITEMS = split(/\s+/,$LINE);
   foreach my $ITEM (@AITEMS) {
     next unless $ITEM =~ /^[0-9]/;
     my $FFLAG=0;
     $ITEM=~s/\%[0-9]+// if $IPIN_F5M;
     $FFLAG=1 if( $ITEM =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}$/);
     $FFLAG=1 if( $ITEM =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}\/[0-9]{1,3}(\.[0-9]{1,3}){3}$/);
     $FFLAG=1 if( $ITEM =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}\/[0-9]{1,2}$/);
     next unless $FFLAG;
     unless($IPIN_DGW) { # ---no-gw - skips the item if equal 0.0.0.0/x
       next if(ipin2bin($ITEM) == 0)
     }
     if(ipin($IPIN_CON,$ITEM) & 2) { 
       if($IPIN_LIN) { print "$CTLINE;${LINE}\n"; }
       else          { print "${LINE}\n"; }
       last; 
     }
   }
  }
  close $FH;
}


if($IPIN_GRP and $IPIN_INC) {
  if($IPIN_GRP eq "-") { open $FH,"<&STDIN" or die "#- Error: STDIN unreachable !\n"; }
  else { open $FH,"<",$IPIN_GRP or die "#- Error: File  '${IPIN_GRP}' unreachable !\n"; }
  my $CTLINE = 0;
  while( my $LINE=<$FH>) {
   chomp $LINE;
   $CTLINE++;
   my $XLINE=$LINE; $XLINE=~s/[^0-9\/\.%]/ /g;
   my @AITEMS = split(/\s+/,$XLINE);
   foreach my $ITEM (@AITEMS) {
     next unless $ITEM =~ /^[0-9]/;
     my $FFLAG=0;
     $ITEM=~s/\%[0-9]+// if $IPIN_F5M;
     $FFLAG=1 if( $ITEM =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}$/);
     $FFLAG=1 if( $ITEM =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}\/[0-9]{1,3}(\.[0-9]{1,3}){3}$/);
     $FFLAG=1 if( $ITEM =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}\/[0-9]{1,2}$/);
     next unless $FFLAG;
     if(ipin($IPIN_INC,$ITEM) & 1) { 
       if($IPIN_LIN) { print "$CTLINE;${LINE}\n"; }
       else          { print "${LINE}\n"; }
       last; 
     }
   }
  }
  close $FH;
}

if($IPIN_GRP and $IPIN_CON) {
  if($IPIN_GRP eq "-") { open $FH,"<&STDIN" or die "#- Error: STDIN unreachable !\n"; }
  else { open $FH,"<",$IPIN_GRP or die "#- Error: File  '${IPIN_GRP}' unreachable !\n"; }
  my $CTLINE = 0;
  while( my $LINE=<$FH>) {
   chomp $LINE;
   $CTLINE++;
   my $XLINE=$LINE; $XLINE=~s/[^0-9\/\.%]/ /g;
   my @AITEMS = split(/\s+/,$XLINE);
   foreach my $ITEM (@AITEMS) {
     next unless $ITEM =~ /^[0-9]/;
     my $FFLAG=0;
     $ITEM=~s/\%[0-9]+// if $IPIN_F5M;
     $FFLAG=1 if( $ITEM =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}$/);
     $FFLAG=1 if( $ITEM =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}\/[0-9]{1,3}(\.[0-9]{1,3}){3}$/);
     $FFLAG=1 if( $ITEM =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}\/[0-9]{1,2}$/);
     next unless $FFLAG;
     unless($IPIN_DGW) { # ---no-gw - skips the item if equal 0.0.0.0/x
       next if(ipin2bin($ITEM) == 0)
     }
     if(ipin($IPIN_CON,$ITEM) & 2) { 
       if($IPIN_LIN) { print "$CTLINE;${LINE}\n"; }
       else          { print "${LINE}\n"; }
       last; 
     }
   }
  }
  close $FH;
}


####################################################################### }}} 1
# --- end ---
