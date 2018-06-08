#!/usr/bin/perl
#=vim high perlPOD ctermfg=brown

use strict;
use warnings;

our $VERSION = 2018.060801;
our $MANUAL  = <<__MANUAL__;
NAME: CRAW - cisco config parser
FILE: craw.pl

DESCRIPTION:
  Script helps to find some parts
  of cisco configuration within the file.

USAGE:
  craw --parent "network 1.2.3.4"  --file ROUTER-conf.txt
  craw --secion "description Enclosure" --file ROUTER-conf.txt
  craw --interface gi1/0/23   --file ROUTER-conf.txt
  craw --snmp   --file ROUTER-conf.txt
  craw --line --parent "23[89]\\.[0-9]+\\.[0-9]\\." -f CONFIG.txt
  find . -type f -exec craw -name -line -parent 213\\.151\\. --file % \\;

PARAMETERS:
  --file <File>   - configuration file
  --parent <RegEx> - searches for RegEx, writes all parent details
  --section <RegEx> - searches for RegEx, writes whole section
  --interface <ifName> - searches for interface config
  --snmp    - provides all interesting SNMP configuration details
  --line    - shows the line numbers
  --no-line - suppress the line numbers
  --name    - shows the filename
  --no-name - suppress the filename

SEE ALSO:
  https://github.com/ondrej-duras/

VERSION: ${VERSION}
__MANUAL__

our $FH;
our $FNAME  = "";
our $PARENT = "";
our $SECTION= "";  
our $LINE   = "";  # handled line
our $INDENT = 0;
our $FFLAG  = 0;
our $TEXT   = 0;
our $STACK  = [];
our $MODE_PARENT    = 0;   # mode to find all parent settings related to the match
our $MODE_SECTION   = 0;   # mode to find whole section related to the match
our $MODE_INTERFACE = 0;   # mode to find configuration of interface, focused on interface name translations
our $MODE_SNMP      = 0;   # mode to finde all snmp settings
our $MODE_LINE      = 0;   # mode to display line numbers in front of text on output  (--line / --no-line)
our $MODE_NAME      = 0;   # mode to display a source FileName in front of text output (--name/ --no-name)
our $MODE_DELIMITER = ";"; # string used as the delimiter for output
our @APARAMS = (); # List of all RegularExpressions/Interfaces/...
=pod
1. Subor je spracovavany poriadkoch
2. Aktualny riadok sa vklada na vrch zasobnika
3. Kazdy riadok v zasobniku ma 3 atributy:
   -- priznak, ci riadok uz bol vypisany
   -- pocet medzier odsadenia riadku
   -- vlastny obsah riadku bez odsadenia
4. predtym, ako je riadok vlozeny do zasobnika,
   su zo zasobnika vyhodene vsetky riadky
   ktorych odsadenie je vacsie, alebo rovnake
   ako odsadenie aktualneho riadku
5. Ak je riadok matchnuty, potom je vypisany,
   aj vsetky riadky zo zasobnika, ktore este 
   neboli vypisane. 
6. Kazdy riadok, ktory je vypisany, je oznaceny priznakom
7. Prazdne a komentove riadky ignorujeme
=cut

unless(scalar @ARGV) {
  print $MANUAL;
  exit;
}

while(my $ARGX = shift @ARGV) {
  if($ARGX =~ /^-+snmp/) { $MODE_SNMP = 1; next; }  # --snmp
  if($ARGX =~ /^-+f/)     { $FNAME = shift @ARGV; next; }  # --file <FileName>
  if($ARGX =~ /^-+p/)     { $MODE_PARENT    = 1; my $X=shift @ARGV; push @APARAMS,$X; next; }      # --parent
  if($ARGX =~ /^-+s/)     { $MODE_SECTION   = 1; my $X=shift @ARGV; push @APARAMS,$X; next; }      # --section
  if($ARGX =~ /^-+i/)     { $MODE_INTERFACE = 1; my $X=shift @ARGV; push @APARAMS,$X; next; }      # --interface
  if($ARGX =~ /^-+d/)     { $MODE_DELIMITER = shift @ARGV;  next; }      # --delimiter ";"
  if($ARGX =~ /^-+li/)    { $MODE_LINE = 1; next; }      # --line
  if($ARGX =~ /^-+no-?li/){ $MODE_LINE = 0; next; }      # --line
  if($ARGX =~ /^-+na/)    { $MODE_NAME = 1; next; }      # --name
  if($ARGX =~ /^-+no-?na/){ $MODE_NAME = 0; next; }      # --name
  push @APARAMS,$ARGX;
}

if((not $FNAME) and ( not -t STDIN)) { $FNAME="-"; }

if($MODE_PARENT) {
  if($FNAME eq "-") { open $FH,"<&STDIN" or die "#- Error: somwthing worng with STDIN !\n"; }
  else { open $FH,"<",$FNAME or die "#- Error: unreachable file '${FNAME}' !\n"; }
  my $CTLINE=0;
  while($LINE = <$FH>) {

    # customizing line
    $CTLINE++;
    chomp $LINE;
    next if $LINE =~ /^\s*$/;
    next if $LINE =~ /^\s*!/;
    next if $LINE =~ /^\s*#/;

    # disassembling line
    ($INDENT,$TEXT) = $LINE =~ m/(^\s*)(\S.*)/;
    $INDENT = length($INDENT);
    #$FFLAG  = 0;

    # flushing childs or brothers, keeping parents in stack
    unless($INDENT) { $STACK = [];  } # pure non-indented line
    else {  # child or brothers
      while($INDENT <= $STACK->[0]->[0]) {
        shift @$STACK;
      }
    }

    # pushing new line to stack
    my $ZTEXT = "";
    if($MODE_LINE) { $ZTEXT = sprintf("%7i",$CTLINE) . $MODE_DELIMITER . $ZTEXT; }
    if($MODE_NAME) { $ZTEXT = $FNAME . $MODE_DELIMITER . $ZTEXT; }
    my $PT = [];
    $PT->[0] = $INDENT;
    $PT->[1] = 0;
    $PT->[2] = $TEXT;
    $PT->[3] = $ZTEXT;
    unshift @$STACK,$PT;

    # checking whether the LINE matches one of paterns/parameters 
    $FFLAG = 0;
    foreach my $PARAM (@APARAMS) {
      my $XTEXT = $PARAM;
      if($TEXT =~ /${XTEXT}/) { $FFLAG = 1; last; }
    }
    # displaying Stacked lines
    if($FFLAG) {
      foreach my $PARAM (reverse @$STACK) {
        if($PARAM->[1] == 1) { next; }
        $PARAM->[1] = 1;
        my $XTEXT = $PARAM->[2];
        my $INDENT= $PARAM->[0];
        my $YTEXT = substr("                  ",0,$INDENT);
        my $ZTEXT = $PARAM->[3];
        print "${ZTEXT}${YTEXT}${XTEXT}\n";
      }
    }
  }
  close $FH;
}
