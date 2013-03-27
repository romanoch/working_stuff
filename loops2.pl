#!/usr/bin/perl
use warnings;
use strict;
 
my @c = (1..6);
for(my $i = 0; $i <= $#c; $i++){
    print("$c[$i] \n");
}

print "$#c\n";
