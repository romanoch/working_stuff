#!/usr/local/bin/perl -w

use strict;
use warnings;

my @ar = (1,2,3,4,5);
my $te = 3;

my @test = &CUT_OUT(\@ar,$te);

#print @test."\n";



sub CUT_OUT {		# parameter: array for cutting out, what to cut out. returns array where elements have been cut out: ARRAY(reference),ELEMENTS........
	
	my @input_array = $_[0];
	my $deletion = $_[1];
	my @output_array;	

	foreach $a (@input_array) {
		unless ($deletion == $a) {
			push (@output_array, $a) } 
	}
	
	print "@output_array\n";
	return @input_array;
};
