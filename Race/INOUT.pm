package INOUT;

use strict;
use warnings;

# read track
my $track; 	# two-dimensional array containing the racing track	
my $path_track;	#path of the mapfile
my $s2p;
my $path_s2p;

	#$track = READ_TRACK($path_track);
	



#############################################
#					SUBS					#
#############################################

sub READ_TRACK {

	my $path = shift @_;
	my @track;				#2D-Array
	my @track_parameters;
	my $line = 1;

	while (<$path>){
		if ($line == 1){
			push @track_parameters, [split(/\s+/, $_)];
			$line++;
			}
		push @track, [split(//, $_)];
		}

	return \@track;
}

sub READ_S2P {

	my $path = shift @_;
	my $linenr = 1;	
	my @mypos;
	my @myvec;
	my $nextcheck;
	my $players;
	my @players;

	while (<$path>){
		chomp $_;
		if ( $_ =~ /^#*/ ) { next }
			
		if ($linenr == 1){
			@mypos = split( /\s+/, $_)}
		elsif ($linenr == 2){
			@myvec = split( /\s+/, $_)}
		elsif ($linenr == 3){
			$nextcheck = $_}
		elsif ($linenr == 4){
			$players = $_}
		elsif ($linenr > 4){
			push( @players, [split(/s+/, $_)])}
		$linenr++;
		}
return \@mypos, \@myvec, $nextcheck, $players, \@players;
}

sub READ_CHECKPOINTS {

	my $path = shift @_;
	my @checkpoints;				#2D-Array


	while (<$path>){
		if ($_ =~ /^#/){ 
			next}
		push (@checkpoints, [split(/\s+/, $_)]);
		}
	}
return \@checkpoints;
}

sub WRITE_P2S {
	
	my $path = shift @_;
	my $coor = shift @_;

	open (OUT, ">", $path);
	print OUT "@{$coor}[0]", " ", "@{$coor}[1]";
	close (OUT);
}



