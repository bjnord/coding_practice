#!/usr/bin/env perl
use strict;
use warnings;

my %seen = ();

while (<>) {
	s/\s+//;
	if ($seen{$_}) {
		die "repeated $_\n";
	}
	$seen{$_} = 1;
}
exit(0);
