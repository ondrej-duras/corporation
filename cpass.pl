#!/usr/bin/perl
#

## MANUAL ############################################################# {{{ 1

our $VERSION = 2017.040701;
our $MANUAL  = <<__MANUAL__;
NAME: Cisco Password EN/DEcryption utility
FILE: cpass.pl

DESCRIPTION:
  Helps encrypt and/or decrypt Cisco IOS 7 type passwords
  shown/stored in most of cisco devices

USAGE:
  cpass --encrypt hello123 --salt 10
  cpass --decrypt 9878778978979

PARAMETERS:
  --encrypt encrypt following plain text
  --decrypt decrypt encrypted cisco password
  --salt    hexadecimal constant, helps to crypt

VERSION: ${VERSION}
__MANUAL__

####################################################################### }}} 1
## EN/DEcoding ######################################################## {{{ 1

use strict;
use warnings;

our @CISCO_XLAT = (
  0x64, 0x73, 0x66, 0x64, 0x3b, 0x6b, 0x66, 0x6f, 0x41,
  0x2c, 0x2e, 0x69, 0x79, 0x65, 0x77, 0x72, 0x6b, 0x6c,
  0x64, 0x4a, 0x4b, 0x44, 0x48, 0x53, 0x55, 0x42 );

sub cisco_encrypt($;$) {
  my ($TEXT,$SALT)=@_;
  chomp $TEXT;
  my $LEN=length $TEXT;
  unless($SALT) { $SALT = rand(scalar @CISCO_XLAT); }
  my $CODE=sprintf("%02X",$SALT);
  for(my $I=0; $I < $LEN; $I++) {
    $CODE .= sprintf("%02X",
      ord(substr($TEXT,$I,1)) ^ $CISCO_XLAT[$SALT++]
    );
  }
  return $CODE;
}

sub cisco_decrypt($) {
  my $CODE = shift;
  my $SALT = hex(substr($CODE,0,2));
  my $LEN  = length $CODE;
  my $TEXT = "";
  for(my $I=2; $I<$LEN; $I+=2) {
    $TEXT .= chr( hex(substr($CODE,$I,2)) ^ $CISCO_XLAT[$SALT++]);
  }
  return $TEXT;
}

####################################################################### }}} 1
## MAIN ############################################################### {{{ 1

our $MODE_ENCRYPT = "";
our $MODE_DECRYPT = "";
our $MODE_SALT    = undef;

unless(scalar @ARGV) {
  print $MANUAL;
  exit;
}

while(my $ARGX = shift @ARGV) {
 if($ARGX =~ /^-+e/) { $MODE_ENCRYPT = shift @ARGV; next; }
 if($ARGX =~ /^-+d/) { $MODE_DECRYPT = shift @ARGV; next; }
 if($ARGX =~ /^-+s/) { $MODE_SALT    = shift @ARGV; next; }
 warn "#-cpass: warning: Unknown argument !\n";
}

if($MODE_ENCRYPT) { print cisco_encrypt($MODE_ENCRYPT,$MODE_SALT); }
if($MODE_DECRYPT) { print cisco_decrypt($MODE_DECRYPT);            }
if( -t STDOUT )  { print "\n"; }

####################################################################### }}} 1
