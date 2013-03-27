#!/usr/bin/perl
use warnings;
use strict;
 
my @a = ();
my $j = min(@a);
 
if(defined $j){
   print("Min of @a is $j \n");
}
else{
   print("The array a is empty.\n");
}
 
my @b = (100,12,31);
my $k = min(@b);
if(defined $k){
  print("Min of @b is $k \n");
}
else{
   print("The array b is empty.\n");
}
 
sub min{
   my $m = shift;
   return undef unless defined $m;
   for (@_){
      $m = $_ if $m > $_;
   }
   return $m;
}
