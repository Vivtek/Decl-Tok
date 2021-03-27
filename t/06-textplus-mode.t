#!perl -T
# Wherein we test the tokenization of textplus.
use 5.006;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
$Data::Dumper::Useqq = 1;

use Decl::Tok;

my $toks;
my $debug;

# TEST: textplus 1 basic text
# - We start with the same input as para 1 and block 1, and get the same token stream back.

$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'textplus', $debug)->load;
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

# TEST: textplus 2 sigiled quote within text
# - We start with the same input as block 2, and get the same token stream back.

$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'textplus', $debug)->load;
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

# TEST: textplus 3 embedded tag
# - We do a simple textplus test, alternating between text blocks and plus tags.

$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'textplus', $debug)->load;
This starts out the same.

+tag "quote"
  tag2: x
 
And more text here.
+tag
EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['tstart', 1, 0, 0,  ''],
 ['text',   1, 0, 25, 'This starts out the same.'],
 ['end',    1, 0, 0,  ''],
 ['start',  3, 0, 0,  ''],
 ['plus',   3, 0, 1,  '+'],
 ['tag',    3, 1, 3,  'tag'],
 ['quote',  3, 5, 7,  '"quote"'],
 ['start',  4, 2, 0,  ''],
 ['tag',    4, 2, 4,  'tag2'],
 ['sigil',  4, 6, 1,  ':'],
 ['qstart', 4, 8, 0,  ''],
 ['text',   4, 0, 1,  'x'],
 ['end',    5, 8, 0,  ''],
 ['end',    5, 3, 0,  ''],
 ['end',    5, 1, 0,  ''],
 ['tstart', 6, 0, 0,  ''],
 ['text',   6, 0, 19, 'And more text here.'],
 ['end',    7, 0, 0,  ''],
 ['start',  7, 0, 0,  ''],
 ['plus',   7, 0, 1,  '+'],
 ['tag',    7, 1, 3,  'tag'],
 ['end',    7, 1, 0,  ''],
]);

# TEST: textplus 4 mock note
# - Just a simple test of my notes format

$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'textplus', $debug)->load;
+z test: This is a test note
+date: 2020-10-22

Let's see how well we can handle a mock note.
" \ Initial indentation
  second line
EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['start',  1, 0, 0,  ''],
 ['plus',   1, 0, 1,  '+'],
 ['tag',    1, 1, 1,  'z'],
 ['name',   1, 3, 4,  'test'],
 ['sigil',  1, 7, 1,  ':'],
 ['qstart', 1, 9, 0,  ''],
 ['text',   1, 0, 19, 'This is a test note'],
 ['end',    1, 9, 0,  ''],
 ['end',    1, 1, 0,  ''],
 ['start',  2, 0, 0,  ''],
 ['plus',   2, 0, 1,  '+'],
 ['tag',    2, 1, 4,  'date'],
 ['sigil',  2, 5, 1,  ':'],
 ['qstart', 2, 7, 0,  ''],
 ['text',   2, 0, 10, '2020-10-22'],
 ['end',    3, 7, 0,  ''],
 ['end',    3, 1, 0,  ''],
 ['tstart', 4, 0, 0,  ''],
 ['text',   4, 0, 45, "Let's see how well we can handle a mock note."],
 ['end',    5, 0, 0,  ''],
 ['start',  5, 0, 0,  ''],
 ['sigil',  5, 0, 1,  '"'],
 ['qstart', 5, 2, 0,  ''],
 ['text',   5, 0, 21, '\ Initial indentation'],
 ['text',   6, 0, 11, 'second line'],
 ['end',    6, 2, 0,  ''],
 ['end',    6, 1, 0,  ''],
]);


# DONE
done_testing;
