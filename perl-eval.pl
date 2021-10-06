#!/usr/bin/perl

print <<__END__;
Perl Test Interpretor
Terminate by "exit" command
__END__

print "Perl>> ";
while($LINE=<>) {
 print eval($LINE);
 print "\nPerl>> ";
}

# --- end ---

