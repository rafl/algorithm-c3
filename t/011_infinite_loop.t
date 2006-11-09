#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

BEGIN {
    use_ok('Algorithm::C3');
}

=pod

This is like the 010_complex_merge_classless test,
but an infinite loop has been made in the heirarchy,
to test that we can fail cleanly instead of going
into an infinite loop

=cut

my $foo = {
  k => [qw(j i)],
  j => [qw(f)],
  i => [qw(h f)],
  h => [qw(g)],
  g => [qw(d)],
  f => [qw(e)],
  e => [qw(f)],
  d => [qw(a b c)],
  c => [],
  b => [],
  a => [],
};

sub supers {
  return @{ $foo->{ $_[0] } };
}

eval {
    local $SIG{ALRM} = sub { die "ALRMTimeout" };
    alarm(3);
    Algorithm::C3::merge('k', \&supers);
};

if(my $err = $@) {
    if($err =~ /ALRMTimeout/) {
        ok(0, "Loop terminated by SIGALRM");
    }
    elsif($err =~ /Infinite loop detected/) {
        ok(1, "Graceful exception thrown");
    }
    else {
        ok(0, "Unrecognized exception: $err");
    }
}
else {
    ok(0, "Infinite loop apparently succeeded???");
}
