#!/usr/bin/perl -w

use Test::More tests => 5;
use strict;

BEGIN
  {
  $| = 1;
  unshift @INC, '../blib/lib';
  unshift @INC, '../blib/arch';
  unshift @INC, '.';
  chdir 't' if -d 't';
  use_ok ('Games::Console');
  }

can_ok ('Games::Console', qw/ 
  new
  log
  text_color text_alpha
  background_color background_alpha
  screen_width
  screen_height
  render
  _render
  /);

my $console = Games::Console->new (
  );

is (ref($console), 'Games::Console', 'new worked');

is (join(',',@{$console->text_color()}), '0.4,0.6,0.8', 'text color');
is ($console->background_alpha(), '0.5', 'background alpha');

