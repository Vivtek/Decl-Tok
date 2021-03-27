#!perl -T
# Wherein we test the tokenization of para text.
use 5.006;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
$Data::Dumper::Useqq = 1;

use Decl::Tok;

my $toks;
my $debug;

# TEST: para 1 basic text
$debug = 0;
# - Trailing blank line is ignored. For para, this is definitely correct (still not sure if it's correct for plain text).
# - This is literally all I can think of to test for para-mode tokenization.

$toks = Decl::Tok->skim(<<'EOF', 'para', $debug)->load;
This is a simple text file.

With a blank
  and an indented line.

EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['tstart', 1, 0, 0,  ''],
 ['text',   1, 0, 27, 'This is a simple text file.'],
 ['end',    1, 0, 0,  ''],
 ['tstart', 3, 0, 0,  ''],
 ['text',   3, 0, 12, 'With a blank'],
 ['text',   4, 2, 21, 'and an indented line.'],
 ['end',    4, 0, 0,  ''],
]);

# DONE
done_testing;
