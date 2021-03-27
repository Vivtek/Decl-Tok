#!perl -T
# Wherein we test the tokenization of tagged data.
use 5.006;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
$Data::Dumper::Useqq = 1;

use Decl::Tok;

my $toks;
my $debug = 0;
ok(1);

# TEST: tag 1 plain tags
# - Just plain tag structure, one name
$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'tag', $debug)->load;
tag
  tag
    tag t2
    
tag2
EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['start', 1, 0, 0,  ''],
 ['tag',   1, 0, 3,  'tag'],
 ['start', 2, 2, 0,  ''],
 ['tag',   2, 2, 3,  'tag'],
 ['start', 3, 4, 0,  ''],
 ['tag',   3, 4, 3,  'tag'],
 ['name',  3, 8, 2,  't2'],
 ['end',   4, 5, 0,  ''],
 ['end',   4, 3, 0,  ''],
 ['end',   4, 1, 0,  ''],
 ['start', 5, 0, 0,  ''],
 ['tag',   5, 0, 4,  'tag2'],
 ['end',   5, 1, 0,  ''],
]);


# TEST: tag 2 various basic stuff
# - Brackets, quotes, sigiled text both on line and next line, worked first try.
# - Added extra lines when it turned out that more than two were breaking the code.
$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'tag', $debug)->load;
tag
  tag (x=7) "quoted string"
    tag t2: Text here
            and yes, two lines.
            in fact three
    
tag2:!
  text on next line
  second though
EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['start',   1, 0, 0,  ''],
 ['tag',     1, 0, 3,  'tag'],
 ['start',   2, 2, 0,  ''],
 ['tag',     2, 2, 3,  'tag'],
 ['bracket', 2, 6, 5,  '(x=7)'],
 ['quote',   2, 12,15, '"quoted string"'],
 ['start',   3, 4, 0,  ''],
 ['tag',     3, 4, 3,  'tag'],
 ['name',    3, 8, 2,  't2'],
 ['sigil',   3, 10,1,  ':'],
 ['qstart',  3, 12,0,  ''],
 ['text',    3, 0, 9,  'Text here'],
 ['text',    4, 0, 19, 'and yes, two lines.'],
 ['text',    5, 0, 13, 'in fact three'],
 ['end',     6, 12,0,  ''],
 ['end',     6, 5, 0,  ''],
 ['end',     6, 3, 0,  ''],
 ['end',     6, 1, 0,  ''],
 ['start',   7, 0, 0,  ''],
 ['tag',     7, 0, 4,  'tag2'],
 ['sigil',   7, 4, 2,  ':!'],
 ['qstart',  8, 2, 0,  ''],
 ['text',    8, 0, 17, 'text on next line'],
 ['text',    9, 0, 13, 'second though'],
 ['end',     9, 2, 0,  ''],
 ['end',     9, 1, 0,  ''],
]);

# TEST: tag 3 sigiled text
# - A sigiled comment line.
$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'tag', $debug)->load;
tag
  tag
    tag t2
    
# Let's have a comment.
EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['start', 1, 0, 0,  ''],
 ['tag',   1, 0, 3,  'tag'],
 ['start', 2, 2, 0,  ''],
 ['tag',   2, 2, 3,  'tag'],
 ['start', 3, 4, 0,  ''],
 ['tag',   3, 4, 3,  'tag'],
 ['name',  3, 8, 2,  't2'],
 ['end',   4, 5, 0,  ''],
 ['end',   4, 3, 0,  ''],
 ['end',   4, 1, 0,  ''],
 ['start', 5, 0, 0,  ''],
 ['sigil', 5, 0, 1,  '#'],
 ['qstart',5, 2, 0,  ''],
 ['text',  5, 0, 21, "Let's have a comment."],
 ['end',   5, 2, 0,  ''],
 ['end',   5, 1, 0,  ''],
]);

# TEST: tag 4 multiple-line sigiled text
# - More lines in the comment
$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'tag', $debug)->load;
tag
    
# Let's have a comment.
  It has a second line.
  And a third.
EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['start', 1, 0, 0,  ''],
 ['tag',   1, 0, 3,  'tag'],
 ['end',   2, 1, 0,  ''],
 ['start', 3, 0, 0,  ''],
 ['sigil', 3, 0, 1,  '#'],
 ['qstart',3, 2, 0,  ''],
 ['text',  3, 0, 21, "Let's have a comment."],
 ['text',  4, 0, 21, "It has a second line."],
 ['text',  5, 0, 12, "And a third."],
 ['end',   5, 2, 0,  ''],
 ['end',   5, 1, 0,  ''],
]);

# TEST: tag 5 code sigil
# - More brackets, code sigil with closer, child tag under sigiled text
$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'tag', $debug)->load;
tag {b} <c> (
  some code
  no wait
 )
 
 tag2: x
  tag3
  
EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['start',   1, 0, 0,  ''],
 ['tag',     1, 0, 3,  'tag'],
 ['bracket', 1, 4, 3,  '{b}'],
 ['bracket', 1, 8, 3,  '<c>'],
 ['sigil',   1, 12,1,  '('],
 ['qstart',  2, 2, 0,  ''],
 ['text',    2, 0, 9,  'some code'],
 ['text',    3, 0, 7,  'no wait'],
 ['closer',  4, -1,1,  ')'],
 ['end',     3, 2, 0,  ''],
 ['start',   6, 1, 0,  ''],
 ['tag',     6, 1, 4,  'tag2'],
 ['sigil',   6, 5, 1,  ':'],
 ['qstart',  6, 7, 0,  ''],
 ['text',    6, 0, 1,  'x'],
 ['end',     6, 7, 0,  ''],
 ['start',   7, 2, 0,  ''],
 ['tag',     7, 2, 4,  'tag3'],
 ['end',     7, 3, 0,  ''],
 ['end',     7, 2, 0,  ''],
 ['end',     7, 1, 0,  ''],
]);

# TEST: tag 6 code sigil without closer
# - A code sigil with closer omitted (the closer is more or less a readability comment; it's not really necessary for the syntax)
$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'tag', $debug)->load;
tag <
  some code, no closer

tag2
  
EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['start',   1, 0, 0,  ''],
 ['tag',     1, 0, 3,  'tag'],
 ['sigil',   1, 4, 1,  '<'],
 ['qstart',  2, 2, 0,  ''],
 ['text',    2, 0, 20, 'some code, no closer'],
 ['end',     3, 2, 0,  ''],
 ['end',     3, 1, 0,  ''],
 ['start',   4, 0, 0,  ''],
 ['tag',     4, 0, 4,  'tag2'],
 ['end',     4, 1, 0,  ''],
]);

# TEST: tag 7 glomming
# - Glomming sigils
$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'tag', $debug)->load;
tag:<<EOT
Some unindented text with a delineator

EOT

tag2:<<<
This just goes to the end
  
(and includes the blank)

EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['start',   1, 0, 0,  ''],
 ['tag',     1, 0, 3,  'tag'],
 ['sigil',   1, 3, 6,  ':<<EOT'],
 ['qstart',  2, 0, 0,  ''],
 ['text',    2, 0, 38, 'Some unindented text with a delineator'],
 ['text',    3, 0, 0,  ''],
 ['closer',  4, 0, 3,  'EOT'],
 ['end',     4, 0, 0,  ''],
 ['end',     5, 1, 0,  ''],
 ['start',   6, 0, 0,  ''],
 ['tag',     6, 0, 4,  'tag2'],
 ['sigil',   6, 4, 4,  ':<<<'],
 ['qstart',  7, 0, 0,  ''],
 ['text',    7, 0, 25, 'This just goes to the end'],
 ['text',    8, 0, 0,  ''],
 ['text',    9, 0, 24, '(and includes the blank)'],
 ['text',    10,0, 0,  ''],
 ['end',     10,0, 0,  ''],
 ['end',     10,1, 0,  ''],
]);

# TEST: tag 8 sigiled children
# - Sigiled children under a tag (from the old version)
$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'tag', $debug)->load;
master tag
  - Here is a bullet point
  - And another; they are separate sigiled text children
    and they can be multilined.
EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['start',  1, 0, 0,  ''],
 ['tag',    1, 0, 6,  'master'],
 ['name',   1, 7, 3,  'tag'],
 ['start',  2, 2, 0,  ''],
 ['sigil',  2, 2, 1,  '-'],
 ['qstart', 2, 4, 0,  ''],
 ['text',   2, 0, 22, 'Here is a bullet point'],
 ['end',    2, 4, 0,  ''],
 ['end',    2, 3, 0,  ''],
 ['start',  3, 2, 0,  ''],
 ['sigil',  3, 2, 1,  '-'],
 ['qstart', 3, 4, 0,  ''],
 ['text',   3, 0, 52, 'And another; they are separate sigiled text children'],
 ['text',   4, 0, 27, 'and they can be multilined.'],
 ['end',    4, 4, 0,  ''],
 ['end',    4, 3, 0,  ''],
 ['end',    4, 1, 0,  ''],
]);

# TEST: tag 9 blank
# - Blank text has no tokens.
$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'tag', $debug)->load;

EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
]);

# TEST: tag 10 simple sigil variation
$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'tag', $debug)->load;
x -
EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['start',  1, 0, 0,  ''],
 ['tag',    1, 0, 1,  'x'],
 ['sigil',  1, 2, 1,  '-'],
 ['end',    1, 1, 0,  ''],
]);

# TEST: tag 11 simple sigil variation 2
$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'tag', $debug)->load;
- x
EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['start',  1, 0, 0,  ''],
 ['sigil',  1, 0, 1,  '-'],
 ['qstart', 1, 2, 0,  ''],
 ['text',   1, 0, 1,  'x'],
 ['end',    1, 2, 0,  ''],
 ['end',    1, 1, 0,  ''],
]);

# TEST: tag 12 sigil by itself
$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'tag', $debug)->load;
-
EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['start',  1, 0, 0,  ''],
 ['sigil',  1, 0, 1,  '-'],
 ['end',    1, 1, 0,  ''],
]);

# TEST: tag 13 line continuations
# - Line continuation, single quote, worked first try
$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'tag', $debug)->load;
x name 'q' |
  more |
  (x=1) <
  code
>
EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['start',  1, 0, 0,  ''],
 ['tag',    1, 0, 1,  'x'],
 ['name',   1, 2, 4,  'name'],
 ['quote',  1, 7, 3,  "'q'"],
 ['cont',   1, 11,1,  '|'],
 ['word',   2, 2, 4,  'more'],
 ['cont',   2, 7, 1,  '|'],
 ['bracket',3, 2, 5,  '(x=1)'],
 ['sigil',  3, 8, 1,  '<'],
 ['qstart', 4, 2, 0,  ''],
 ['text',   4, 0, 4,  'code'],
 ['closer', 5,-2, 1,  '>'],
 ['end',    4, 2, 0,  ''],
 ['end',    4, 1, 0,  ''],
]);

# TEST: tag 14 bracket-delimited node
# - Bracket-delimited node, worked first try (not that I really doubted that, as this was a Racket prototype test)
$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'tag', $debug)->load;
[x]: This is a
     bracket-delimited node
EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['start',  1, 0, 0,  ''],
 ['bracket',1, 0, 3,  '[x]'],
 ['sigil',  1, 3, 1,  ':'],
 ['qstart', 1, 5, 0,  ''],
 ['text',   1, 0, 9,  'This is a'],
 ['text',   2, 0, 22, 'bracket-delimited node'],
 ['end',    2, 5, 0,  ''],
 ['end',    2, 1, 0,  ''],
]);

# TEST: tag 15 continuation test
# - Text after the continuation line (special-case comment)
# - Note again, the tag starts but components are still on the next line without a new tag start (that's what line continuation *is*)
# - This is another from the Racket prototype
$debug = 0;
$toks = Decl::Tok->skim(<<'EOF', 'tag', $debug)->load;
tag very-long-line | some text
  "and a quote":
  Here, we have some text
EOF

diag Dumper ($toks) if $debug;

is_deeply ($toks, [
 ['start',  1, 0, 0,  ''],
 ['tag',    1, 0, 3,  'tag'],
 ['name',   1, 4, 14, 'very-long-line'],
 ['cont',   1, 19,1, '|'],
 ['qstart', 1, 21,0,  ''],
 ['text',   1, 0, 9,  'some text'],
 ['end',    1, 21,0,  ''],
 ['quote',  2, 2, 13, '"and a quote"'],
 ['sigil',  2,15, 1,  ':'],
 ['qstart', 3, 2, 0,  ''],
 ['text',   3, 0, 23, 'Here, we have some text'],
 ['end',    3, 2, 0,  ''],
 ['end',    3, 1, 0,  ''],
]);


# DONE
done_testing;
