#!/usr/bin/perl

our $VERSION = 2018.011704;
our $MANUAL  = <<__MANUAL__;
NAME: DNS resolving utility for TSIF :-)
FILE: xresolve.pl

DESCRIPTION:
  Helps to provide DNS vectors DEVIP;HNAME;FQDN
  ... do not worry to much :-)

USAGE:
  ./xresolve.pl server1 router1.domain.tld 1.2.3.4 2.3.4.5
  cat snmp1.csv | ./xresolve.pl --tsif | tee -a snmp2.csv

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
    my($DEVIP,$HNAME,$REST) = split(/\s*;\s*/,$LINE,3);
    my $FQDN;
    if($DEVIP) {
      ($DEVIP,$HNAME,$FQDN) = xresolve($DEVIP);
    } elsif($HNAME) {
      ($DEVIP,$HNAME,$FQDN) = xresolve($HNAME);
    }
    print "${DEVIP};${HNAME};${REST};${FQDN}\n";
  }
}

foreach my $ITEM (@ALIST) {
  my ($DEVIP,$HNAME,$FQDN) = xresolve($ITEM);
  next unless $DEVIP;
  print "${DEVIP};${HNAME};FQDN;${FQDN}\n";
}


