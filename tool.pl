#!/usr/bin/perl

## Manual ############################################################# {{{ 1

our $VERSION = 2016.121201;
our $MANUAL  = <<__MANUAL__;
NAME: File GET/PUT/DEL/Shell/GetOS toolkit
FILE: tool.pl

DESCRIPTION:
  Command-line utility for simplified  
  file manipulation onto/from server/network device.
  The tool.pl script is a target of 
  xput,xget,xsh,xos,xrem softlinks.
  Action type is taken from script name or from 
  command-line attribute.

ACTIONS:
  --put  - puts a file/s onto server
  --get  - gets a file/s from server
  --rem  - removes a file from server
  --cmd  - connects to server's shell
  --sh   - connects to server's shell
  --os   - checks/confirms OS/PLAX 
  --plax - checks/confirms OS/PLAX 

USAGE:
  xput file.txt
  xput -v -n file1.txt
  xput -t file1.txt file2.txt
  cat <<__END__ | xput -h
    file1.txt file2.txt
    file3.txt
  __END__
  xput [parameters] <file> [<other files>...]

PARAMETERS:
  -v / --verbose  - provides more output
  -n / --no-act   - shows applied commands only
  -r / --root     - 'root' as login
  -a / --admin    - 'administrator' as login
  -k / --learnkey - learns a public key (ssh)
  -t / --temp     - upload into /tmp \%TMP\% folder
  -h / --home     - upload into \$HOME \%USERPROFILE\%
  -d / --fold DIR - upload into destination DIR

ENVIRONEMNT VARIABLES:
  HNAME      - Hostname of server/network device
  DEVIP      - primary management address
  FQDN       - Fully Qualified Domain Name
  CRED_ADMIN - user\%password for access to windows
  CRED_ROOT  - user\%password for access to linux
  SSHPASS    - password 

SEE ALSO:
  https://github.com/ondrej-duras/
 
VERSION: ${VERSION}
__MANUAL__

####################################################################### }}} 1
## Defaults ########################################################### {{{ 1

use strict;
use warnings;
use subs 'warn';
use subs 'die';
use subs 'exit';
#use subs 'debug';
use File::Basename;
use IPC::Open2;
use POSIX;
#use lib dirname (__FILE__);
use PWA;

our $NONE  = "";      # Nothing usefull - destination variable.
our $SELF  = "";      # basename of script itself
our $FILE  = "";      #  Manipulated FILEname
our $PATH  = "";      #  Manipulated Destination PATH
our $FULL  = "";      #  Manipulated PATH.FILE
our $PLAX  = "";      #. Short Patform Name of server/device
our $FQDN  = "";      #. Server/Device FQDN
our $DEVIP = "";      #. Primary Management IP of server/device
our $HNAME = "";      #. Configured HostName of server/device
our $USER  = "";      #. Used User/Login to connect server/device
our $PASS  = "";      #. Used Password to connect server/device
our $JMPX  = "";      #. SSH Jump server
our $LOCAL = $^O;     #. Platform MSWin32/linux

our $MODE_DEBUG = ""; # filters the troubleshooting messages
our $MODE_ALLOW = 0;  # 0=action disabled 1=action allowed
our $MODE_COLOR = 2;  # 0=off 1=on 2=tbd Terminal Colors
our $MODE_HOME  = 0;  # 1=put file into ${HOME} /get it first
our $MODE_TEMP  = 0;  # 1=put file into /tmp or in %TMP% / %TEMP% /get it first
our $MODE_FOLD  = ""; # non-zero means the destination folder to put the file
our $MODE_OPER  = ""; # "put" to upload, "get" to download
our $MODE_KEYS  = 0;  # 1=leard a key (ignore previous key as well)
our $MODE_TEST  = 0;  # 0=off 1=on Script Internal Testing only
our @AFILES=(); # list of file they need to be 

($SELF,$NONE,$NONE) = fileparse($0); # takes the script name
####################################################################### }}} 1
## Interaction exit/die/warn/debug/color/action ####################### {{{ 1

sub color($) {
  my $MSG = shift;

  # drops unexpected escape sequences
  unless($MODE_COLOR) {
    $MSG =~ s/\033\[[;0-9]*[a-zA-Z]//mg;
    return $MSG;
  }

  # color a plain output
  $MSG =~ s/^#:.*$/\033\[1;34m$&\033[m/gm;     # DEBUG - Troubleshooting details
  $MSG =~ s/^#-.*$/\033\[0;31m$&\033[m/gm;     # Warning / Error message / Message of Failure - FAIL
  $MSG =~ s/^#\..*$/\033\[0;34m$&\033[m/gm;    # CONFIDENTIAL detail - deep DEBUG - should not be seen over arm 
  $MSG =~ s/^#\+.*$/\033\[0;32m$&\033[m/gm;    # GOOD. - MEssage of Success - PASS
  $MSG =~ s/^#\&.*$/\033\[0;33m$&\033[m/gm;    # YELLOW automated action - results - PASS/FAIL/EXIT messages
  $MSG =~ s/^#\>.*$/\033\[0;36m$&\033[m/gm;    # Interactive / Notice requesting an user interaction
  $MSG =~ s/^#\?.*$/\033\[0;35m$&\033[m/gm;    # Interactive / user's prompt line
  $MSG =~ s/^#\!.*$/\033\[1;41;37m$&\033[m/gm; # Message of INTRUSIVITY - INTRUSIVE ACTION !!!
  $MSG =~ s/^#\*.*$/\033\[1;42;37m$&\033[m/gm; # Message of INTRUSIVITY - NON-INTRUSIVE ACTION !!!
  $MSG =~ s/^#\~.*$/\033\[1;44;37m$&\033[m/gm; # Message of INTRUSIVITY - READ-ONLY ACTION !!!
  return $MSG;
}

sub exit {
  my $EXIT=shift;
  $EXIT=0 unless $EXIT;
  debug "\n#&EXIT(${EXIT})\n";
  CORE::exit($EXIT);
}

sub warn(;$) {
  my $MSG = shift;
  unless($MSG) {
    my ($package, $filename, $line, $subroutine) = caller(1);
    $MSG = "#- ${subroutine}(${line}): Warning !\n";
  }
  if( -t STDERR) {
    print STDERR color $MSG;
  } else {
    $MSG =~ s/\033\[[;0-9]*[a-zA-Z]//mg;
    print STDERR $MSG;
  }
}

sub die(;$$) {
  my($MSG,$EXIT) = @_;
  if($MSG)      { warn $MSG; }
  unless($EXIT) { $EXIT = 1; }
  CORE::exit($EXIT);
}

no warnings;
sub debug(;$$) {
  my ($MSG,$DAT) = @_;
  return unless $MODE_DEBUG;
  return unless $MSG=~/${MODE_DEBUG}/;
  unless($MSG) { $MSG=""; }
  unless($DAT) { $DAT=""; }
  print color "${MSG}${DAT}";
}
use warnings;

sub action($) {
  my $ACTION=shift;
  my $FHIN;
  my $FHOUT;
  my $PID;
  my $XACTION=$ACTION; $XACTION =~ s/^/#: ACTION> /mg;
  my $SHELL='/bin/bash 2>&1';
  if($^O eq 'MSWin32') { $SHELL="cmd.exe 2>&1"; }
  debug "#: SHELL='${SHELL}'\n";
  debug "${XACTION}\n\n";
  unless($MODE_ALLOW) { return 0; }
  $PID=open2($FHOUT,$FHIN,$SHELL);
  unless($PID) { die "#- Error: Open2 Issue !\n",10; }
  debug "#: Action PID=${PID}\n";
  print $FHIN $ACTION;
  print $FHIN "\nexit\n";
  close $FHIN;
  while(my $LINE=<$FHOUT>) {
    print color $LINE;
  }
  close $FHOUT;
  waitpid($PID,&WNOHANG);
  my $EXIT = $? >> 8; # exitcode;
  debug "#: Action \$?=${EXIT}\n";
}

####################################################################### }}} 1
## Environment ######################################################## {{{ 1

if(exists $ENV{"MODE_DEBUG"}) { $MODE_DEBUG=$ENV{"MODE_DEBUG"}; }
if(exists $ENV{"DEVIP"}) { $DEVIP = $ENV{"DEVIP"}; debug "#: DEVIP=${DEVIP}\n"; } else { die "#- No DEVIP defined !\n"; }
if(exists $ENV{"HNAME"}) { $HNAME = $ENV{"HNAME"}; debug "#: HNAME=${HNAME}\n"; } else { die "#- No HNAME defined !\n"; }
if(exists $ENV{"FQDN"})  { $FQDN  = $ENV{"FQDN"};  debug "#: FQDN=${FQDN}\n";   } else { die "#- No FQDN defined !\n";  }
if(exists $ENV{"PLAX"})  { $PLAX  = $ENV{"PLAX"};  debug "#: PLAX=${PLAX}\n";   } else { die "#- No PLAX defined !\n";  }
if(exists $ENV{"JMPX"})  { $JMPX  = $ENV{"JMPX"};  if($JMPX eq "no") { $JMPX=""; } debug "#: JMPX=${JMPX}\n";   }

if($PLAX =~ /^Win/i) { 
  unless($USER = pwaLogin("admin"))    { $USER="administrator"; } 
  unless($PASS = pwaPassword("admin")) { die "#- None password for windows user '${USER}' defined !\n"; } 
  debug "#: USER='${USER}' by profile 'admin'\n";
}
if($PLAX =~ /^Lnx/i) { 
  unless($USER = pwaLogin("root"))  { $USER="root"; } 
  unless($PASS = pwaPassword("root")) { 
    if(exists $ENV{"SSHPASS"}) { $PASS=$ENV{"SSHPASS"}; }
    else { die "#- None password for linux user '${USER}' defined !\n";} 
  } 
  debug "#: USER='${USER}' by profile 'root'\n";
}

if($SELF =~ /^x?get/i)  { $MODE_OPER="get"; debug "#: MODE_OPER=get\n"; }
if($SELF =~ /^x?put/i)  { $MODE_OPER="put"; debug "#: MODE_OPER=put\n"; }
if($SELF =~ /^x?del/i)  { $MODE_OPER="del"; debug "#: MODE_OPER=del\n"; }
if($SELF =~ /^x?rem/i)  { $MODE_OPER="del"; debug "#: MODE_OPER=del\n"; }
if($SELF =~ /^x?cmd/i)  { $MODE_OPER="cmd"; debug "#: MODE_OPER=cmd\n"; }
if($SELF =~ /^x?sh/i)   { $MODE_OPER="cmd"; debug "#: MODE_OPER=cmd\n"; }
if($SELF =~ /^x?shell/i){ $MODE_OPER="cmd"; debug "#: MODE_OPER=cmd\n"; }
if($SELF =~ /^plax/i)   { $MODE_OPER="plx"; debug "#: MODE_OPER=plx\n"; }
if($SELF =~ /^x?os/i)   { $MODE_OPER="plx"; debug "#: MODE_OPER=plx\n"; }

####################################################################### }}} 1
## Command-Line ####################################################### {{{ 1

while(my $ARGX = shift @ARGV) {
  if($ARGX =~ /^-+test$/)      { $MODE_TEST  = 1; debug "#: MODE_TEST=1\n";  next; }
  if($ARGX =~ /^-+color$/)     { $MODE_COLOR = 1; debug "#: MODE_COLOR=1\n"; next; }
  if($ARGX =~ /^-+no-?color$/) { $MODE_COLOR = 0; debug "#: MODE_COLOR=0\n"; next; }
  if($ARGX =~ /^-+v$/)         { $ENV{"MODE_DEBUG"}=$MODE_DEBUG = ".*";        debug "#: MODE_DEBUG='.*'\n";   next; }
  if($ARGX =~ /^-+verbose$/)   { $ENV{"MODE_DEBUG"}=$MODE_DEBUG = ".*";        debug "#: MODE_DEBUG='.*'\n";   next; }
  if($ARGX =~ /^-+debug$/)     { $ENV{"MODE_DEBUG"}=$MODE_DEBUG = shift @ARGV; debug "#: MODE_DEBUG='${MODE_DEBUG}'\n"; next; }
  if($ARGX =~ /^-+no-?debug$/) { $ENV{"MODE_DEBUG"}=$MODE_DEBUG = "";          debug "#: MODE_DEBUG=''\n";   next; }
  if($ARGX =~ /^-+act/)        { $MODE_ALLOW = 1; debug "#: MODE_ALLOW=1\n"; next; } 
  if($ARGX =~ /^-+no-?act/)    { $MODE_ALLOW = 0; debug "#: MODE_ALLOW=0\n"; next; } 
  if($ARGX =~ /^-+n$/)         { $MODE_ALLOW = 0; debug "#: MODE_ALLOW=0\n"; next; } 
  if($ARGX =~ /^-+r$/)         { $USER = "root";  debug "#: USER='root'\n";  next; }
  if($ARGX =~ /^-+root$/)      { $USER = "root";  debug "#: USER='root'\n";  next; }
  if($ARGX =~ /^-+a$/)         { $USER = "administrator"; debug "#: USER='administrator'\n"; next; }
  if($ARGX =~ /^-+admin$/)     { $USER = "administrator"; debug "#: USER='administrator'\n"; next; }
  if($ARGX =~ /^-+k$/)         { $MODE_KEYS = 1;  debug "#: MODE_KEYS=1\n";  next; }
  if($ARGX =~ /^-+keys?$/)     { $MODE_KEYS = 1;  debug "#: MODE_KEYS=1\n";  next; }
  if($ARGX =~ /^-+no-?keys?$/) { $MODE_KEYS = 0;  debug "#: MODE_KEYS=0\n";  next; }
  if($ARGX =~ /^-+t$/)         { $MODE_TEMP = 1;  debug "#: MODE_TEMP=1\n";  next; }
  if($ARGX =~ /^-+te?mp$/)     { $MODE_TEMP = 1;  debug "#: MODE_TEMP=1\n";  next; }
  if($ARGX =~ /^-+no-?te?mp$/) { $MODE_TEMP = 0;  debug "#: MODE_TEMP=0\n";  next; }
  if($ARGX =~ /^-+h$/)         { $MODE_HOME = 1;  debug "#: MODE_HOME=1\n";  next; }
  if($ARGX =~ /^-+home$/)      { $MODE_HOME = 1;  debug "#: MODE_HOME=1\n";  next; }
  if($ARGX =~ /^-+no-?home$/)  { $MODE_HOME = 0;  debug "#: MODE_HOME=0\n";  next; }
  if($ARGX =~ /^-+d$/)         { $MODE_FOLD = shift @ARGV; debug "#: MODE_FOLD='${MODE_FOLD}'\n"; next; }
  if($ARGX =~ /^-+fold$/)      { $MODE_FOLD = shift @ARGV; debug "#: MODE_FOLD='${MODE_FOLD}'\n"; next; }
  if($ARGX =~ /^-+no-?fold$/)  { $MODE_FOLD = "";          debug "#: MODE_FOLD=''\n"; next; }
  if($ARGX =~ /^-+get$/)       { $MODE_OPER = "get";  debug "#: MODE_OPER=get\n";     next; }
  if($ARGX =~ /^-+put$/)       { $MODE_OPER = "put";  debug "#: MODE_OPER=put\n";     next; }
  if($ARGX =~ /^-+cmd$/)       { $MODE_OPER = "cmd";  debug "#: MODE_OPER=cmd\n";     next; }
  if($ARGX =~ /^-+sh$/)        { $MODE_OPER = "cmd";  debug "#: MODE_OPER=cmd\n";     next; }
  if($ARGX =~ /^-+shell$/)     { $MODE_OPER = "cmd";  debug "#: MODE_OPER=cmd\n";     next; }
  if($ARGX =~ /^-+os$/)        { $MODE_OPER = "plax"; debug "#: MODE_OPER=plax\n";    next; }
  if($ARGX =~ /^-+plax$/)      { $MODE_OPER = "plax"; debug "#: MODE_OPER=plax\n";    next; }
  if($ARGX =~ /^[^-]/) { push @AFILES,$ARGX; debug "#: adding file '${ARGX}' from command-line\n";next; }
#   -v / --verbose  - provides more output
#   -n / --no-act   - shows applied commands only
#   -r / --root     - 'root' as login
#   -a / --admin    - 'administrator' as login
#   -k / --learnkey - learns a public key (ssh)
#   -t / --temp     - upload into /tmp \%TMP\% folder
#   -h / --home     - upload into home \%USERPROFILE\%
#   -d / --fold DIR - upload into destination DIR
# Local platforms: Linux/Windows
# Destination platforms: Linux(SSH/SCP)/Windows(WMI/SMB)
# Operations: get/put/shell/os_check/remove
}

if($MODE_COLOR == 2) {
  if( -t STDOUT ) { $MODE_COLOR=1; }
  else            { $MODE_COLOR=0; }
}

####################################################################### }}} 1
## Testing ############################################################ {{{ 1

if($MODE_TEST) {
 debug "#:DEBUG starts.\n";
 print color "#: DEBUG Message.\n";
 print color "#- WARNING ERROR.\n";
 print color "#. CONFIDENTIAL.\n";
 print color "#+ SUCCESS.\n";
 print color "#& AUTO RESULTS.\n";
 print color "#\> Interaction required.\n";
 print color "#? prompt line.\n";
 print color "#! Intrusive action.\n";
 print color "#* Non-Intrusive action.\n";
 print color "#~ Read-Only action\n";
 print color "\033[1;33m# escape sequences.\033[m\n";
 debug "#:DEBUG ends.\n";

action <<__END__;
  # nic
  ls -l
  date +\%Y\%m\%d-\%H\%M\%S
  echo "ok."
__END__
exit;
}
####################################################################### }}} 1
## Matrix ############################################################# {{{ 1

our $HMATRIX={
 'W-get-NW' => sub{ print color "#- W-get-NW [${FILE}] Not Implemented yet !\n"; },
 'W-get-JW' => sub{ print color "#- W-get-JW [${FILE}] Not Implemented yet !\n"; },
 'W-get-NL' => sub{ print color "#- W-get-NL [${FILE}] Not Implemented yet !\n"; },
 'W-get-JL' => sub{ print color "#- W-get-JL [${FILE}] Not Implemented yet !\n"; },
 'W-put-NW' => sub{ print color "#- W-put-NW [${FILE}] Not Implemented yet !\n"; },
 'W-put-JW' => sub{ print color "#- W-put-JW [${FILE}] Not Implemented yet !\n"; },
 'W-put-NL' => sub{ print color "#- W-put-NL [${FILE}] Not Implemented yet !\n"; },
 'W-put-JL' => sub{ print color "#- W-put-JL [${FILE}] Not Implemented yet !\n"; },
 'W-del-NW' => sub{ print color "#- W-del-NW [${FILE}] Not Implemented yet !\n"; },
 'W-del-JW' => sub{ print color "#- W-del-JW [${FILE}] Not Implemented yet !\n"; },
 'W-del-NL' => sub{ print color "#- W-del-NL [${FILE}] Not Implemented yet !\n"; },
 'W-del-JL' => sub{ print color "#- W-del-JL [${FILE}] Not Implemented yet !\n"; },
 'W-cmd-NW' => sub{ print color "#- W-cmd-NW [${FILE}] Not Implemented yet !\n"; },
 'W-cmd-JW' => sub{ print color "#- W-cmd-JW [${FILE}] Not Implemented yet !\n"; },
 'W-cmd-NL' => sub{ print color "#- W-cmd-NL [${FILE}] Not Implemented yet !\n"; },
 'W-cmd-JL' => sub{ print color "#- W-cmd-JL [${FILE}] Not Implemented yet !\n"; },
 'W-plx-NW' => sub{ print color "#- W-plx-NW [${FILE}] Not Implemented yet !\n"; },
 'W-plx-JW' => sub{ print color "#- W-plx-JW [${FILE}] Not Implemented yet !\n"; },
 'W-plx-NL' => sub{ print color "#- W-plx-NL [${FILE}] Not Implemented yet !\n"; },
 'W-plx-JL' => sub{ print color "#- W-plx-JL [${FILE}] Not Implemented yet !\n"; },
 'L-get-NW' => sub{ 
                    debug "#: L-get-NW ${FILE} ${FULL}\n";
                    action("smbclient -U ${USER}\%${PASS} //${DEVIP}/C\$ -c 'get ${FULL} ${FILE}'"); 
                  },
 'L-get-JW' => sub{ print color "#- L-get-JW [${FILE}] Not Implemented yet !\n"; },
 'L-get-NL' => sub{
                    $ENV{"SSHPASS"}=$PASS;
                    foreach my $FILE (@AFILES) {
                      my $FNAME=basename($FILE);
                      print color "#\> scp ${USER}\@${DEVIP}:${FILE} ${FNAME}\n";
                      system("sshpass -e scp ${USER}\@${DEVIP}:${FILE} ${FNAME}"); 
                    }
                  },
 'L-get-JL' => sub{ 
                    $PID=$$;
                    foreach my $FILE (@AFILES) {
                      my $FNAME=basename($FILE);
                      print color "#\> scp ${USER}\@${DEVIP}:${FILE} ${FNAME}\n";
                      system("ssh ${JMPX} sshpass -p '${PASS}' scp ${USER}\@${DEVIP}:${FILE} ..tmp.${PID}.${FNAME}");
                      system("scp :${FILE} ${FNAME}"); 
                    }
                  },
 'L-put-NW' => sub{ 
                    debug "#: L-put-NW ${FILE} ${FULL}\n";
                    action("smbclient -U ${USER}\%${PASS} //${DEVIP}/C\$ -c 'put ${FILE} ${FULL}'"); 
                  },
 'L-put-JW' => sub{ print color "#- L-put-JW [${FILE}] Not Implemented yet !\n"; },
 'L-put-NL' => sub{ print color "#- L-put-NL [${FILE}] Not Implemented yet !\n"; },
 'L-put-JL' => sub{ print color "#- L-put-JL [${FILE}] Not Implemented yet !\n"; },
 'L-del-NW' => sub{ print color "#- L-del-NW [${FILE}] Not Implemented yet !\n"; },
 'L-del-JW' => sub{ print color "#- L-del-JW [${FILE}] Not Implemented yet !\n"; },
 'L-del-NL' => sub{ print color "#- L-del-NL [${FILE}] Not Implemented yet !\n"; },
 'L-del-JL' => sub{ print color "#- L-del-JL [${FILE}] Not Implemented yet !\n"; },
 'L-cmd-NW' => sub{ print color "#- L-cmd-NW [${FILE}] Not Implemented yet !\n"; },
 'L-cmd-JW' => sub{ print color "#- L-cmd-JW [${FILE}] Not Implemented yet !\n"; },
 'L-cmd-NL' => sub{ $ENV{"PASS"}=$PASS; system("sshpass -e ssh  -o StrictHostKeyChecking=no -l ${USER} ${DEVIP}"); },
 'L-cmd-JL' => sub{
                    print color "#: jump ${JMPX}\n"; 
                    system("ssh -t ${JMPX} sshpass -p '${PASS}' ssh -t -l ${USER} ${DEVIP}"); 
                  },
 'L-plx-NW' => sub{ print color "#- L-plx-NW [${FILE}] Not Implemented yet !\n"; },
 'L-plx-JW' => sub{ print color "#- L-plx-JW [${FILE}] Not Implemented yet !\n"; },
 'L-plx-NL' => sub{ print color "#- L-plx-NL [${FILE}] Not Implemented yet !\n"; },
 'L-plx-JL' => sub{ print color "#- L-plx-JL [${FILE}] Not Implemented yet !\n"; }
};

####################################################################### }}} 1
## Main ############################################################### {{{ 1

# ACID - Action ID - string reference to proper action/command
# it needs to be applied.
# 1-2-34
# W-get-NW
# 1 - L/W source , the platform on which the script is running
# 2 - get/put/del/cmd/plax - the action to be performed
# 3 - J/N - J-used or N-not-used SSH jump to perform an action
# 4 - L/W a destination server platform
#

# - 1 -
my $ACID="";
if($^O eq "MSWin32") { $ACID="W-"; }
elsif($^O eq "linux"){ $ACID="L-"; }
else { die "#- Unknown platform $^O\n"; }

# - 2 -
$ACID .= $MODE_OPER . '-';
# - 3 -
if($JMPX) { $ACID .= 'J'; }
else      { $ACID .= 'N'; }
# - 4 - 
if($PLAX =~ /Win/)    { $ACID .= 'W'; }
elsif($PLAX =~ /Lnx/) { $ACID .= 'L'; }
debug "#: Action '${ACID}'\n";

# for actions cmd/plax the files are not necessary so rewritten by "-" dummy file
# for all other actions - if STDIN redirected, then list of files learned from STDIN
if($MODE_OPER =~ /^(cmd|plx)$/) { @AFILES=('-'); debug "#: AFILES=(-)\n"; }
else {
  unless( -t STDIN ) {
    while(my $LINE=<STDIN>) {
      $LINE =~ s/^\s+//;
      $LINE =~ s/\s+$//;
      push @AFILES,$LINE;
      debug "#: adding file '${LINE}' from STDIN\n";
    }
  }
}

foreach $FILE (@AFILES) {
  $HMATRIX->{$ACID}();
}

####################################################################### }}} 1
# --- end ---
