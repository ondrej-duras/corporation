#!/usr/bin/perl
# enter.pl - used to enter Login/Password on Windows platform
# ~/prog/hello/enter.pl

our $VERSION = 2017.030901;
our $MANUAL  = <<__MANUAL__;
NAME: Enter Value
FILE: enter.pl

DESCRIPTION:
  Use to enter mostly the Login or Password
  into the system environment variables.
  It's bash read command alternative for 
  the Windows platform.

USAGE:
  FOR /F "usebackq" %%X IN (`enter.pl -lp "NTLM Username: "`) do @(SET PASS=%%X)
  FOR /F "usebackq" %%X IN (`enter.pl -sp "NTLM Password: "`) do @(SET PASS=%%X)

PARAMETERS:
  -l  - enter login
  -s  - enter password
  -p  - followed by prompt

VERSION: ${VERSION}
__MANUAL__


use strict;
use warnings;
use Term::ReadKey;


# for /F "usebackq" %X in (`enter.pl`) do @(set XX=%X)
# set /P ANS="Would you like someting [Yes/No] ?"
# if /I not %ANS% == "yes" (
#   some commands
# )

our $MODE_SECRET = 0;
our $MODE_PROMPT = "";

sub printty($) {
  my $MSG = shift;
  if( -t STDOUT) { 
    print $MSG;
    return;
  }
  if( -t STDERR) {
    print STDERR $MSG;
    return;
  }
  open FH,">","CON" or die "#- Error: opening CON !\n";
  print FH $MSG;
  close FH;
}


sub inputSecret($) {
  my $PROMPT = shift;
  unless($PROMPT) {
    $PROMPT = "Password: ";
  }
  printty $PROMPT;
  ReadMode 2;
  my $DATA = <STDIN>;
  ReadMode 0;
  printty "\n";
  chomp $DATA;
  return $DATA;
}

sub inputNormal($) {
  my $PROMPT = shift;
  unless($PROMPT) {
    $PROMPT = "Login: ";
  }
  printty $PROMPT;
  my $DATA = <STDIN>;
  chomp $DATA;
  return $DATA;
}

unless(scalar @ARGV) {
  print $MANUAL;
  exit;
}

while(my $ARGX=shift @ARGV) {
  if($ARGX =~ /^-lp/) { $MODE_PROMPT = shift @ARGV; $MODE_SECRET = 0; next; }
  if($ARGX =~ /^-pl/) { $MODE_PROMPT = shift @ARGV; $MODE_SECRET = 0; next; }
  if($ARGX =~ /^-sp/) { $MODE_PROMPT = shift @ARGV; $MODE_SECRET = 1; next; }
  if($ARGX =~ /^-ps/) { $MODE_PROMPT = shift @ARGV; $MODE_SECRET = 1; next; }
  if($ARGX =~ /^-p/)  { $MODE_PROMPT = shift @ARGV; next; }
  if($ARGX =~ /^-s/)  { $MODE_SECRET = 1; next; }
  if($ARGX =~ /^-l/)  { $MODE_SECRET = 0; next; }
}

if($MODE_SECRET) { print inputSecret($MODE_PROMPT); }
else             { print inputNormal($MODE_PROMPT); }
  
