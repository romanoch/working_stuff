#!/usr/bin/perl
use warnings;
use strict;
 
my ($l_curr, $f_curr, $l_amount, $f_amount);
 
my %rates = (  
     USD => 1,
     YPY => 82.25,
     EUR => 0.78,
     GBP => 0.62,
     CNY => 6.23
);
 
# print supported currencies
print("Supported currency:\n");
for(keys %rates){
    print(uc($_),"\n");
}
 
# get inputs from users:
print("Enter local currency:\n");
$l_curr = uc(<STDIN>);
 
print("Enter foreign currency:\n");
$f_curr = uc(<STDIN>);
 
print("Enter amount:\n");
$l_amount = <STDIN>;
 
chomp($l_curr,$f_curr,$l_amount);
 
# check user's inputs.
if(not exists $rates{$l_curr}){
     print("Local currency is not supported\n");
}
elsif(not exists $rates{$f_curr}){
     print("Foreign currency is not supported\n");
}
else{
     # convert from local currency to foreign currency
     $f_amount = ($rates{$f_curr} / $rates{$l_curr}) * $l_amount;
 
     # print out the result
     print("$l_amount $l_curr = $f_amount $f_curr","\n");
}
