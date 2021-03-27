#!perl -T
# Wherein we check our different pattern matchers against test patterns.
use 5.006;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
$Data::Dumper::Useqq = 1;

use Decl::Tok;

my @tests;
my $trial;

# ------------------------------------------------------ match_white
@tests = (
   ['this', undef],
   ['  this', [2, '  ']],
);

foreach $trial (@tests) {
   my ($text, $result) = @$trial;
   is_deeply (Decl::Tok::match_white ($text), $result, "whitespace test: '$text'");
}

# ------------------------------------------------------ match_bareword
@tests = (
  ['this text',   [4, 'this']],
  ['this: text',  [4, 'this']],
  ['-',            undef],
  ['this-text',   [9, 'this-text']],
  ['this-',       [5, 'this-']],
  ['this:',       [4, 'this']],
  ['this?:',      [5, 'this?']],
  ['this:text',   [9, 'this:text']],
  ['10',          [2, '10']],
  ['.',            undef],
  [10.3,          [4, '10.3']],
  ['10(2): test', [5, '10(2)']],
  ['1,2: test',   [3, '1,2']],
  ['A&E yeah',    [3, 'A&E']],
  ['a#11: test',  [4, 'a#11']],
  ['# test',       undef],
  ['(parameter)',  undef],
  ['{code]',       undef],
  ['3{code}: a', [7, '3{code}']],
  ['3 <',        [1, '3']],
  ['a|b | cont', [3, 'a|b']],
  [':a|b | cont', undef],
  ['x:<<EOF stuff', [1, 'x']],
  ['x:# table',     [1, 'x']],
  ['x:@ table',     [1, 'x']],
  ['x:x:x table',   [5, 'x:x:x']],
  ['x:x: table',    [3, 'x:x']],
  ['rest:<<<',      [4, 'rest']],
);

foreach $trial (@tests) {
   my ($text, $result) = @$trial;
   is_deeply (Decl::Tok::match_bareword ($text), $result, "bareword test: '$text'");
}

# ------------------------------------------------------ match_quoted
@tests = (
  ['"this" text',   [6, '"this"']],
  ['"a \\" " bob',  [7, '"a \\" "']],
  ['"not closed',    undef],
  ["'this' text",   [6, "'this'"]],
  ["'a \\' ' bob",  [7, "'a \\' '"]],
  ["'not closed",    undef],
  ['" " "',         [3, '" "']],
  ['x" " "',         undef],
);

foreach $trial (@tests) {
   my ($text, $result) = @$trial;
   is_deeply (Decl::Tok::match_quoted ($text), $result, "quote test: '$text'");
}

# ------------------------------------------------------ match_brackets
@tests = (
  ['(x="y"): stuff',     [7, '(x="y")']],
  ['(x=")"): stuff',     [7, '(x=")")']],
  ['(x=\\) "a"): stuff', [10, '(x=\\) "a")']],
  ['<x="<">: stuff',     [7, '<x="<">']],
  ['x="<">: stuff',       undef],
  ['( this is a sigil',   undef],
  ['[x="["]: stuff',     [7, '[x="["]']],
  ['{x="{"}: stuff',     [7, '{x="{"}']],
  ['{x={<<}}: stuff',    [8, '{x={<<}}']],
  ['{x={<<}: stuff',      undef],
  ['x{x={<<}}: stuff',    undef],
);

foreach $trial (@tests) {
   my ($text, $result) = @$trial;
   is_deeply (Decl::Tok::match_brackets ($text), $result, "bracket test: '$text'");
}

# ------------------------------------------------------ match_sigil
@tests = (
  [': stuff',          [1, ':']],
  [':+ stuff',         [2, ':+']],
  [':: stuff',         [2, '::']],
  [':<<EOF stuff',     [6, ':<<EOF']],
  ['x:<<EOF stuff',     undef],
  [':<<< stuff',       [4, ':<<<']],
  ['<<EOF stuff',      [5, '<<EOF']],
  [':<<00EOF-- stuff', [10, ':<<00EOF--']],
  ['x:<<00EOF-- stuff', undef],
  ['x: blah',           undef],
  ['" This quote',     [1, '"']],
  ['# A comment',      [1, '#']],
);

foreach $trial (@tests) {
   my ($text, $result) = @$trial;
   is_deeply (Decl::Tok::match_sigil ($text), $result, "bracket test: '$text'");
}

# ------------------------------------------------------ match_plus
@tests = (
  ['+tag',          [1, '+']],
  ['stuff',         undef],
);

foreach $trial (@tests) {
   my ($text, $result) = @$trial;
   is_deeply (Decl::Tok::match_plus ($text), $result, "plus test: '$text'");
}

done_testing();


