#!/usr/local/bin/perl -w
#Wordcount 1.0 von Roman Ochsenreiter

use strict;
my $line;
my @single_words;
my @clean_words;
my %hash;

#read line by line from file
while(<>){
    $line = $_;
    chomp $line;

#convert to lower case and split
    $line = lc($line);
    @single_words = split(/\s+/, $line);

#remove all non-lower case elements
    foreach (@single_words){
	$_ =~ s/[^a-z]//g;
    }
    push(@clean_words, @single_words); 
}

#sort into hash
foreach my $element(@clean_words){
     $hash{$element}++;
}

#write to output file, sorted after most frequent words
open(OUTPUT, ">wc_freq.txt"); #output, sorted after frequencies
open(OUTPUT2, ">wc_alphab.txt"); #output, sorted alphabetically

foreach my $key (sort keys %hash){
    print OUTPUT2 "$key: $hash{$key}\n"}

foreach my $value (sort { $hash{$b} <=> $hash{$a} } keys %hash){
    print OUTPUT "$value $hash{$value}\n"}

my $size = @clean_words;
print OUTPUT "Number of words: $size\n";
print OUTPUT2 "Number of words: $size\n";

close(OUTPUT);
close(OUTPUT2);
