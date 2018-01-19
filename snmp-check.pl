#!/usr/bin/perl

our $VERSION = 2018.011703;
our $MANUAL  = <<__MANUAL__;
NAME: SNMP Check
FILE: snmp-check.pl

DESCRIPTION:
  Helps to recognize devices.
  Input is an incomplete TSIF record containging
  an IP address or hostname and snmp read-only community.
  Then it makes query to find DEVIP,HNAME,FQDN .
  At the end it makes SNMP query ti DEVIP to get sysObjectID.


USAGE:
  ./xresolve.pl server1 router1.domain.tld switch2 1.2.3.4 2.3.4.5

PARAMETERS:
  --tsif  - takes incomplete TSIF records from STDIN
  --short - short hostname as FQDN is enought
  --long  - IP address is translated to FQDN via PTR

VERSION: ${VERSION}
__MANUAL__


use strict;
use warnings;

use POSIX;
use Socket;
use Net::SNMP;

our $MONTI = 2;
our $MONCO = "public";
our $MONVE = "2c";
our $MONRE = 2;

our @ALIST=();
our @ADOMAINS=("",".poznamky.net",".tsian.net");
our $XRESOLVE_FQDN = 1; # 0=HNAME2FQDN=disabled 1=HNAME-to-FQDN=enabled
sub xresolve($) {
  my $ANY = shift;
  my ($DEVIP,$HNAME,$FQDN,$IADDR);

  # IP -> FQDN
  if($ANY =~ /^[0-9]+(\.[0-9]+){3}$/) {
    $DEVIP = $ANY;
    $IADDR = inet_aton($ANY);
    $FQDN=gethostbyaddr($IADDR,AF_INET);    
    unless(defined($FQDN)) { $FQDN=""; }
    $HNAME=$FQDN; $HNAME =~ s/\..*//;

  # FQDN -> IP
  } elsif ( $ANY =~ /^[a-z].*\./) {
    $FQDN  = $ANY;
    $HNAME = $ANY; $HNAME =~ s/\..*//;
    $IADDR = gethostbyname($FQDN);
    unless(defined($IADDR)) { $DEVIP=""; }
    else { $DEVIP = inet_ntoa($IADDR); }

  # HNAME -> IP -> FQDN
  } else {
    $HNAME = $ANY;
    foreach my $DOMAIN (@ADOMAINS) {
      $FQDN = $ANY . $DOMAIN;
      $IADDR = gethostbyname($FQDN);
      unless(defined($IADDR)) { $DEVIP=""; $FQDN=""; next; }
      else { $DEVIP = inet_ntoa($IADDR);   last; }
    }
  }
  if($XRESOLVE_FQDN and $DEVIP and $HNAME and($FQDN !~ /\./)) {
    $IADDR = inet_aton($DEVIP);
    $FQDN=gethostbyaddr($IADDR,AF_INET);    
    unless(defined($FQDN)) { $FQDN=$HNAME; }
  }
  $HNAME = uc $HNAME;
  $FQDN  = lc $FQDN;
  return ($DEVIP,$HNAME,$FQDN);
}

# sysObjectID=xgetoid(DEVIP,MONVE,MONTI,MONCO)
sub xgetoid($$$$) {
  my ($DEVIP,$MONVE,$MONTI,$MONCO)=@_;
  my ($snmp,$err) = Net::SNMP->session(
    -hostname  => $DEVIP,
    -version   => $MONVE,
    -community => $MONCO,
    -timeout   => $MONTI,
    -retries   => $MONRE
  );
  unless(defined $snmp) {
   print "#- Error: ${err}\n"; return "";
  }
  my $SNMP_ANS=$snmp->get_request( -varbindlist => ['1.3.6.1.2.1.1.2.0']);
  unless($SNMP_ANS) { return ""; }
  my $RESULT = $SNMP_ANS->{'1.3.6.1.2.1.1.2.0'};
  $snmp->close();
  unless($RESULT) { $RESULT=""; }
  return $RESULT;
}



our $MODE_TSIF = 0; # --tsif
unless(scalar(@ARGV)) {
  print $MANUAL;
  exit;
}
while(my $ARGX = shift @ARGV) {
  if($ARGX =~ /^-+long/)  { $XRESOLVE_FQDN = 1; next; }
  if($ARGX =~ /^-+short/) { $XRESOLVE_FQDN = 0; next; }
  if($ARGX =~ /^-+tsif/)  { $MODE_TSIF     = 1; next; }
  push @ALIST,$ARGX;
}

if($MODE_TSIF) {
  while(my $LINE=<>) {
    chomp $LINE;
    if($LINE=~/^\s*$/) { print "\n";        next; }
    if($LINE=~/^\s*#/) { print "${LINE}\n"; next; }
    my($DEVIP,$HNAME,$CLASS,$MONVE,$MONTI,$MONCO) = split(/\s*;\s*/,$LINE,6);
    my ($FQDN,$DEOID);
    if($DEVIP) {
      ($DEVIP,$HNAME,$FQDN) = xresolve($DEVIP);
    } elsif($HNAME) {
      ($DEVIP,$HNAME,$FQDN) = xresolve($HNAME);
    }
    if($DEVIP and $MONVE and $MONCO) {
      $DEOID=xgetoid($DEVIP,$MONVE,$MONTI,$MONCO);
    }
    print "${DEVIP};${HNAME};ASSET;${MONVE};${MONTI};${MONCO};${FQDN};${DEOID}\n";
  }
}

foreach my $ITEM (@ALIST) {
  my ($DEVIP,$HNAME,$FQDN) = xresolve($ITEM);
  next unless $DEVIP;
  print "${DEVIP};${HNAME};FQDN;${FQDN}\n";
}


