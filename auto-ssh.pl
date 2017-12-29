#!/usr/bin/perl

use IPC::Open2;

$VERSION = 2017.071001;
$MANUAL  = <<__MANUAL__;
NAME: Connect-to-SSH-Device
FILE: auto-ssh.pl

DESCRIPTION:
  Simple example how to automate small SSH tasks.

USAGE:
  export SSHUSER=login SSHPASS=password
  auto-ssh.pl <ROUTER> <COMMAND>
  auto-ssh.pl <ROUTER> <COMMAND>
  unset SSHUSER SSHPASS 

SEE ALSO: https://github.com/ondrej-duras/myPL
VERSION: ${VERSION}
__MANUAL__

if((scalar @ARGV) == 2) { 
  $HOST=$ARGV[0]; $COMD=$ARGV[1];
} else {
  print $MANUAL;
  exit;
}
## tento nedava ziadny prompt do vypisu
#$pid = open2(\*CHLD_OUT,\*CHLD_IN,
#  "ssh -T -l ${USER} -o PubkeyAuthentication=no ${HOST}");

# tento dava prompt aj zadane prikazy do vypisu
$SSH="ssh";
if(exists($ENV{SSHPASS})) { $SSH="sshpass -e ssh"; }
if(exists($ENV{SSHUSER})) { $USER=$ENV{SSHUSER};   }
else                      { $USER=$ENV{USER};      }

$pid = open2(\*CHLD_OUT,\*CHLD_IN,
"${SSH} -tt -l ${USER} -o PubkeyAuthentication=no ${HOST}");
unless($pid) { die "#- ${HOST} nebavi !\n"; }

# Aby sa to nezablokovalo pre --more--
print CHLD_IN "terminal length 0\n";
# Zaciatocny marker
print CHLD_IN "!!! -- zaciatok ---\n";
# zoznam veci, ktore potrebujem
print CHLD_IN "${COMD}\n";
# Koncovy marker
print CHLD_IN "!!! -- koniec ---\n";

# ukoncenie relacie na strane routra
print CHLD_IN "exit\n";
print CHLD_IN "exit\n";
print CHLD_IN "exit\n";

# precitanie vysledkov
$MARKER = 0;
while($LINE=<CHLD_OUT>) {
 if ($LINE=~/-- zaciatok --/) { $MARKER++; next; }
 if ($LINE=~/-- koniec --/)   { $MARKER++; next; }
 next unless $MARKER == 3;
 print $LINE;
}

# ukoncenie prace na strane jump servera
close CHLD_IN;
close CHLD_OUT;


