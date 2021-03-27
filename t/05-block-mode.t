#!perl -T
# Wherein we test the tokenization of block text.
use 5.006;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
$Data::Dumper::Useqq = 1;

use Decl::Tok;

my $toks;
my $debug;

# TEST: block 1 basic text
$debug = 0;
# - We start with the same input as para 1, and get the same token stream back.

$toks = Decl::Tok->skim(<<'EOF', 'block', $debug)->load;
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

# TEST: block 2 sigiled quote within text
$debug = 0;

$toks = Decl::Tok->skim(<<'EOF', 'block', $debug)->load;
This starts out the same.
" It has a quoted text.
And goes right on.

" Just
    test
    
And check line#
EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['tstart', 1, 0, 0,  ''],
 ['text',   1, 0, 25, 'This starts out the same.'],
 ['end',    2, 0, 0,  ''],
 ['start',  2, 0, 0,  ''],
 ['sigil',  2, 0, 1,  '"'],
 ['qstart', 2, 2, 0,  ''],
 ['text',   2, 0, 21, 'It has a quoted text.'],
 ['end',    2, 2, 0,  ''],
 ['end',    2, 1, 0,  ''],
 ['tstart', 3, 0, 0,  ''],
 ['text',   3, 0, 18, 'And goes right on.'],
 ['end',    3, 0, 0,  ''],
 ['start',  5, 0, 0,  ''],
 ['sigil',  5, 0, 1,  '"'],
 ['qstart', 5, 2, 0,  ''],
 ['text',   5, 0, 4,  'Just'],
 ['text',   6, 2, 4,  'test'],
 ['end',    7, 2, 0,  ''],
 ['end',    7, 1, 0,  ''],
 ['tstart', 8, 0, 0,  ''],
 ['text',   8, 0, 15, 'And check line#'],
 ['end',    8, 0, 0,  ''],
]);

# DONE
done_testing;
