package Init;

use strict;
use warnings;

# read track
my $track; 	# two-dimensional array containing the racing track	
my $path;	#path of the mapfile


	$track = READ($path);

sub READ {

	my $path = shift @_;
	my @track;

	while (<$path>){
		my @a = split;
		push @track, \@a;
	}
	return \@track;
}
