#!/usr/bin/perl

## MANUAL ############################################################# {{{ 1

our $VERSION = 2017.102401;
our $MANUAL  = <<__MANUAL__;
NAME: Csv Regular Expression Parser
FILE: crep.pl

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

VERSION: ${VERSION} TSIF/R4
__MANUAL__

####################################################################### }}} 1
## PARAMETERS ######################################################### {{{ 1

use strict;
use warnings;

our $FILE_INPUT="";
our @AFILTER=();
our $LINE = "";
our $FH   = undef;
our $MODE_TEST = 0;

unless(scalar(@ARGV)) {
  print $MANUAL;
  exit;
}
while(my $ARGX=shift @ARGV) {
  if($ARGX =~ /^-+f/) { $FILE_INPUT = shift @ARGV; next; }
  if($ARGX =~ /^-+a/)  { 
    my $DAT=shift @ARGV;
    unless($DAT=~/^[0-9]+(\.[0-9]+){3}$/) { 
      die "#- Error: '${DAT}' is not an IP address !\n"; 
    }
    push @AFILTER,"E,0,${DAT}";
    next;
  }
  if($ARGX =~ /^-+d/) {
    my $DAT = lc shift @ARGV;
    push @AFILTER,"r,1,${DAT}";
    next;
  }
  if($ARGX =~ /^-+[eErRvVqQ][0-9]+/) { 
    my $DATA=shift @ARGV;
    $ARGX =~ s/^-+//; 
    $ARGX =~ s/^(\S)/$1,/;
    push @AFILTER,"${ARGX},${DATA}";
    next;
  }
  if($ARGX =~ /^-+t/) { $MODE_TEST =1; next; }
  warn "#- wrong argument '${ARGX}'\n";
}

for(my $I=0, my $CT=scalar @AFILTER; $I<$CT; $I++) {
  if($AFILTER[$I] =~ /^[ervq]/) { $AFILTER[$I] = lc $AFILTER[$I]; }
}
if($MODE_TEST) { print "#:" . join("\n#:",@AFILTER) . "\n"; }

####################################################################### }}} 1
## MAIN ############################################################### {{{ 1


unless($FILE_INPUT) { unless( -t STDIN ) { $FILE_INPUT="-"; } }
if($FILE_INPUT eq "-") { open $FH,"<&STDIN" or die "#- Error: STDIN issue !\n"; }
else { open $FH,"<",$FILE_INPUT or die "#- Error: File '${FILE_INPUT}' issue !\n"; }

while($LINE=<$FH>) {
  chomp $LINE;
  next if $LINE =~ /^\s*$/;
  next if $LINE =~ /^\s*#/;
  my @ALINE = split(/\s*;\s*/,$LINE);
  my $FFLAG=1;
  foreach my $ARGP (@AFILTER) {
    my ($TYP,$CID,$VAL) = split(/,/,$ARGP);
    my $ADAT; my $IDAT;
    if(exists($ALINE[$CID])) { $ADAT=$ALINE[$CID]; } else { $ADAT=""; }
    $IDAT=lc $ADAT;

    if($TYP eq "e") { unless($IDAT eq $VAL) { $FFLAG=0; }}
    if($TYP eq "E") { unless($ADAT eq $VAL) { $FFLAG=0; }}
    if($TYP eq "v") { if    ($IDAT eq $VAL) { $FFLAG=0; }}
    if($TYP eq "V") { if    ($ADAT eq $VAL) { $FFLAG=0; }}

    if($TYP eq "r") { unless($IDAT =~ /${VAL}/i) { $FFLAG=0; }}
    if($TYP eq "R") { unless($ADAT =~ /${VAL}/)  { $FFLAG=0; }}
    if($TYP eq "q") { if    ($IDAT =~ /${VAL}/i) { $FFLAG=0; }}
    if($TYP eq "Q") { if    ($ADAT =~ /${VAL}/)  { $FFLAG=0; }}
  }
  if($FFLAG) {
    print "${LINE}\n";
  }
}
close $FH;


####################################################################### }}} 1
# --- end ---

