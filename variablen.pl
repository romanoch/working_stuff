#!/usr/local/bin/perl -w

use strict;
use warnings;

my $j = "test";
my $i = 11;
my $t;
my %th;

for ($i <= 10){
    $th{$i} = "$j $i";
    #$i=$i + 1
	$t = $th{$i};
	print $t;
}
