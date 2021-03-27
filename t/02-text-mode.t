#!perl -T
# Wherein we test the tokenization of plain text to warm up.
use 5.006;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
$Data::Dumper::Useqq = 1;

use Decl::Tok;

my $toks;

# TEST: text 1 basic text
# - Trailing blank line is ignored. (Unlike glomming sigils.) This might be wrong.
$toks = Decl::Tok->skim(<<'EOF', 'text')->load;
This is a simple text file.

With a blank
  and an indented line.

EOF

is_deeply ($toks, [
 ['text', 1, 0, 27, 'This is a simple text file.'],
 ['text', 2, 0, 0,  ''],
 ['text', 3, 0, 12, 'With a blank'],
 ['text', 4, 2, 21, 'and an indented line.'],
]);

# TEST: text 2 basic text with trailing spaces
# - Trailing spaces are ignored in both blank and non-blank lines.
$toks = Decl::Tok->skim(<<'EOF', 'text')->load;
This is a simple text file.
 
With a blank 
  and an indented line.
 
EOF

is_deeply ($toks, [
 ['text', 1, 0, 27, 'This is a simple text file.'],
 ['text', 2, 0, 0,  ''],
 ['text', 3, 0, 12, 'With a blank'],
 ['text', 4, 2, 21, 'and an indented line.'],
]);

# DONE
done_testing;
