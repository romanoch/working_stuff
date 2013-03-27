#!/usr/bin/perl
use warnings;
use strict;

#my $search = $ARGV[0];
#my @testhash = ("mahabarata","baghvad gita","koran","bibel","torah","edda","mahagoni");
#    foreach(@testhash) {
#	if ($_ =~ /$search/i) { print $_."\n";}
#}


use Data::Dumper;
 
my $text = <<END;
name: Antonio Vivaldi, period: 1678-1741
name: Andrea Zani,period: 1696-1757
name: Antonio Brioschi, period: 1725-1750
END
 
my %composers;
 
for my $line (split /\n/, $text){
    print $line, "\n";
    if($line =~ /name:\s+(\w+\s+\w+),\s+period:\s*(\d{4}\-\d{4})/){
        $composers{$1} = $2;
    }
}
 
print Dumper(\%composers);
