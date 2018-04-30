#!/usr/bin/perl

our $VERSION = 2018.043001;
our $MANUAL  = <<__MANUAL__;
NAME: shell template
FILE: tiny-shell.pl

DESCRIPTION:
  Template for small interpretors/shells like lab.pl etc.
 
USAGE:
  tiny-shell.pl
  tiny-shell.pl some command
  cat some-commands.txt | tiny-shell.pl

PARAMETERS:
  none for now

INTERNAL COMMANDS:
  help   - shows this help
  exit   - terminates a program
  color no|off - turs colored output on/off
  color  - tells about color setting
  ?? some command - provides grammar of command

VERSION: ${VERSION}
__MANUAL__


use strict;
use warnings;

our $LINE  = "";
our @ALINE = ();
our $MODE_COLOR = 2;

# attempt to load module handling escape sequences
if($^O eq "MSWin32") {
 $MODE_COLOR = eval "require Win32::Console::ANSI;return 2;";
 unless( -t STDOUT) { $MODE_COLOR=0; }
}

# declarations
sub qqhelp($@);

# list of commands
our $HCMDS={
'002;help|\?' => sub { print $MANUAL; },
'003;sh(ow)?\s+ver(sion)?' => sub{ print "${VERSION}\n"; },
'004;(\?\?|qqhelp)( .*)?' => \&qqhelp,
'005;exit|quit|logout' => sub { print "\033[1;33mdone.\033[m\n"; exit; },
'006;col(or)?' => sub{ print color( "\033[32;1m color is " . ($MODE_COLOR?"on":"off") ."\033[m\n"); },
'007;col(or)?\s+on' => sub{ $MODE_COLOR=1; },
'008;col(or)?\s+off'=> sub{ $MODE_COLOR=0; }
};


# grammar of commands at "??"
sub qqhelp($@) {
 my ($LINE,@ALINE)=@_;
 my $FILTER=".*";
 if(exists $ALINE[1]) { $FILTER=$ALINE[1]; }
 my $TEXT = join("\n",grep( /${FILTER}/, sort keys %$HCMDS));
 print $TEXT . "\n";
}

# procedure suppresing colors or any other terminal escape sequences
sub color($) {
  my $MSG = shift;
  if($MODE_COLOR) { return $MSG; }
  $MSG =~ s/\033\[[;0-9]*[a-zA-Z]//g;
  return $MSG;
}

# single command line interpretor
sub line($@) {
  my ($LINE,@ALINE)=@_;
  foreach my $KEY (sort keys %$HCMDS) {
    my ($PRIORITY,$PATERN) = split(/;/,$KEY,2);
    next unless $LINE =~ /^\s*(${PATERN})\s*$/i;
    my $CALL = $HCMDS->{$KEY};
    &$CALL($LINE,@ALINE);
    return;
  }
  print "\033[1;31mError: ${LINE}\033[m\n";
}

# interpeting command given as cmd-line parameters
if(scalar @ARGV) {
  my $LINE=join(" ",@ARGV);
  line($LINE,@ARGV);
  exit;
}
# interactive mode main cycle
print "\033[1;33mOrange DNE LAB\033[m\n";
while(1) {
  print color ("\033[1;33m>>\033[m ");
  $LINE=<STDIN>;
  chomp $LINE;
  next if $LINE =~ /^\s*$/;
  next if $LINE =~ /^\s*#/;
  @ALINE = split(/\s+/,$LINE);
  line($LINE,@ALINE);
}

# --- end ---

