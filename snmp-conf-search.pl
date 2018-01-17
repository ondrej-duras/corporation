#!/usr/bin/perl

our $VERSION = 2018.011701;
our $MANUAL  = <<__MANUAL__;
NAME: SNMP Search
FILE: snmp-conf-search.pl

DESCRIPTION:
  Script searches text config files to
find snmp communities and to create 
an "ASSET LIST".

USAGE:
  snmp-conf-search.pl -d \$HOME/nw_config -o SNMP-DEVICES.csv

PARAMETERS:
  -d - directory/folder with configuration files
  -o - output file

VERSION: ${VERSION}
__MANUAL__

use strict;
use warnings;
our $CONF_FOLD = "";
our $CONF_FILE = "-";
our $FI;
our $FO;

unless(scalar(@ARGV)) {
  print $MANUAL;
  exit;
}
while(my $ARGX = shift @ARGV) {
 if($ARGX =~ /^-+d/) { $CONF_FOLD = shift @ARGV; next; }
 if($ARGX =~ /^-+o/) { $CONF_FILE = shift @ARGV; next; }
 die "#- Error: Wrong argument '${ARGX}' !\n";
}

open $FI,"grep -H -i \"snmp.*community\" ${CONF_FOLD}/* --exclude=vlan.dat* |" or 
  die "#- Error: no sources !\n";
if($CONF_FILE eq "-") { open $FO,">&",STDOUT or die "#- Error: STDOUT trouble !\n"; }
else { open $FO,">",$CONF_FILE or die "#- Error: File '${CONF_FILE}' trouble !\n"; }

while(my $LINE=<$FI>) {
  chomp $LINE;
  next unless $LINE =~ /snmp.*community/i;
  my ($DEVICE,$LINE)=split(/:/,$LINE,2);
  my @PARTS = split(/\s+/,$LINE);
  my $MONVE = "2c";
  my $MONCO = "public";
  my $MONTI = "2";
  while( my $ITEM = shift @PARTS) {
    if($ITEM =~ /community/) { $MONCO = shift @PARTS; next; }
    if($ITEM =~ /version/)   { $MONVE = shift @PARTS; next; }
  }
  $DEVICE =~ s/^.*(\/|\\)//;
  $DEVICE =~ s/\..*$//;
  $DEVICE =~ s/(-|_)(confg?|now|redback)$//;
  print $FO ";${DEVICE};ASSET;${MONVE};${MONTI};${MONCO}\n";
}
close $FO;
close $FI;


