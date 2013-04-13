#!/usr/local/bin/perl

use strict;
use warnings;
use feature 'say';




my @horizontal_edges;
my @vertical_edges;

open (MATRIXH, ARGV[0]) or die "Can't open ",ARGV[0],"\n";
while (<MATRIXH>) {
	my $i = 0;
	chomp $_;
	split (/\s+/);
	$horizontal_edges[$i] = @_;
	$i++;
	}
close (MATRIXH);

open (MATRIXV, ARGV[1]) or die "Can't open ",ARGV[1],"\n";
while (<MATRIXV>) {
	my $j = 0;
	chomp $_;
	split (/\s+/);
	$vertical_edges[$j] = @_;
	$j++;
	}
close (MATRIXV);

