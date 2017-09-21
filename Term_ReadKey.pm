#
# Term::ReadKey.pm Lite - very lightweight version of Term::ReadKey
# 20170921, Ing. Ondrej DURAS
#
# mkdir Term
# cp -vi Term_ReadKey.pm Term/ReadKey.pm
# ls -l  Term/ReadKey.pm
# pm Term::ReadKey
#

package Term::ReadKey;
use strict;
use warnings;
use Exporter;

our $VERSION='2.30.20170921';
our @ISA    = qw(Exporter);
our @EXPORT = qw(ReadMode);

sub ReadMode($) {
  my $MODE = shift;
  if ($MODE eq "0")      { system("stty  echo"); return; }  # 'restore'
  if ($MODE eq "1")      { system("stty  echo"); return; }  # 'normal'
  if ($MODE eq "2")      { system("stty -echo"); return; }  # 'noecho'
  if ($MODE eq "3")      { system("stty -echo"); return; }  # 'creak'
  if ($MODE eq "4")      { system("stty -echo"); return; }  # 'raw'
  if ($MODE eq "5")      { system("stty -echo"); return; }  # 'ultra-rwa'

  if ($MODE eq "normal") { system("stty  echo"); return; }  # 'normal'
  if ($MODE eq "echo")   { system("stty  echo"); return; }  # 'normal'
  if ($MODE eq "noecho") { system("stty -echo"); return; }  # 'noecho'
}
1;

