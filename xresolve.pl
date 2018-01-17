#!/usr/bin/perl

our $VERSION = 2018.011701;
our $MANUAL  = <<__MANUAL__;
NAME: DNS resolving utility for TSIF :-)
FILE: xfqdn.pl

DESCRIPTION:
  Helps to provide DNS vectors DEVIP;HNAME;FQDN
  ... do not worry to much :-)

USAGE:
  ./xfqdn.pl server1 router1.domain.tld switch2 1.2.3.4 2.3.4.5

PARAMETERS;
  

VERSION: ${VERSION}
__MANUAL__


use strict;
use warnings;

use POSIX;
use Socket;

our @ALIST=();
our @ADOMAINS=("",".net.dc.orange.sk",".ip.orange.sk",".net.orange.sk");
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




unless(scalar(@ARGV)) {
  print $MANUAL;
  exit;
}
while(my $ARGX = shift @ARGV) {
  push @ALIST,$ARGX;
}

foreach my $ITEM (@ALIST) {
  my ($DEVIP,$HNAME,$FQDN) = xresolve($ITEM);
  next unless $DEVIP;
  print "${DEVIP};${HNAME};FQDN;${FQDN}\n";
}


