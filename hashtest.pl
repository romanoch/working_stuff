#!/usr/local/bin/perl -w

use strict;
use warnings;
use feature 'say';

my @a = ("a","b","c");
our @ele;
our %has;

while (<>) {
	print "1: $_";	
	@ele = ();
	chomp $_;
	my $b = $_;	
	@ele = split (/\s+/, $b);
	say "2: @ele";
	$has{$ele[0]} = $ele[1];


	}
#say  keys %has;
