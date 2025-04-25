#!/usr/bin/perl

no  strict;
use warnings;

our $VERSION = "2025.042501"; 
our $MANUAL  = <<__END__;
PERL shell
---------------------------------------
exit - exit this script
 .   - multiline command
\$val - display value of variable \$val
__END__

print $MANUAL;
our $FLAG=1;
while($FLAG) {
  # prompt and command
  print "\npl> ";
  my $LINE = <>;
  chomp $LINE;
  $LINE =~ s/^\s+//; $LINE =~ s/\s+$//; 

  # exit
  if ($LINE =~ /^exit(\(\))?$/) {
     print("bye.\n");
     exit();    
  }

  # display variables
  if ($LINE=~/^\$[0-9A-Za-z]+$/) {
    eval("print(".$LINE.");");
    next;
  }

  # . multiline command
  if ($LINE eq ".") {
    $LINE="";
    my $FFLAG=1;
    print "use '.' to exit multiline.\n";
    while($FFLAG) {
      print("pl...>> ");
      $XLINE = <>;
      chomp $XLINE;
      if($XLINE =~ /^\.$/) { last; }
      $LINE .= $XLINE . "\n";
    }
  }
  # everything else
  eval($LINE);
}

# --- end ---

