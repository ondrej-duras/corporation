#!/usr/bin/perl

use IPC::Open2;

$USER = 'USER';      #<<<
$HOST = "ROUTER_IP"; #<<<

## tento nedava ziadny prompt do vypisu
#$pin = open2(\*CHLD_OUT,\*CHLD_IN,
#  "ssh -T -l ${USER} -o PubkeyAuthentication=no ${HOST}");

# tento dava prompt aj zadane prikazy do vypisu
$pid = open2(\*CHLD_OUT,\*CHLD_IN,
"ssh -tt -l ${USER} -o PubkeyAuthentication=no ${HOST}");

unless($pid) { die "#- ${HOST} nebavi !\n"; }

# Aby sa to nezablokovalo pre --more--
print CHLD_IN "terminal length 0\n";
# Zaciatocny marker
print CHLD_IN "!!! -- zaciatok ---\n";
# zoznam veci, ktore potrebujem
print CHLD_IN "show version\n";
# Koncovy marker
print CHLD_IN "!!! -- koniec ---\n";

# ukoncenie relacie na strane routra
print CHLD_IN "exit\n";
print CHLD_IN "exit\n";
print CHLD_IN "exit\n";

# precitanie vysledkov
$MARKER = 0;
while($LINE=<CHLD_OUT>) {
 if ($LINE=~/-- zaciatok --/) { $MARKER=1; next; }
 if ($LINE=~/-- koniec --/)   { $MARKER=0; next; }
 next unless $MARKER;
 print $LINE;
}

# ukoncenie prace na strane ju8mp servera
close CHLD_IN;
close CHLD_OUT;
