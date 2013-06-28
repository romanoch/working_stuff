package INOUT;

use strict;
use warnings;

#################################################
#			SUBS			#
#################################################

sub READ_TRACK {

	my $path = shift @_;
	my @track;				#2D-Array
	my @track_parameters;
	my $line = 1;
	
	open (TRACK, "<", $path) or
	  die "Couldn't open $path\n";
	while (<TRACK>){
		if ($line == 1){
			push @track_parameters, [split(/\s+/, $_)];
			$line++;
			}
		push @track, [split(//, $_)];
		}
	close (TRACK);
	
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
	
	open (S2P, "<", $path) or 
	  die "Couldn't open $path\n";
	while (<S2P>){
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
	close (S2P);
return \@mypos, \@myvec, $nextcheck, $players, \@players;
}

sub READ_CHECKPOINTS {

	my $path = shift @_;
	my @checkpoints;				#2D-Array

	open (CHECK, "<", $path) or
	  die "Couldn't open $path\n";
	while (<CHECK>){
		if ($_ =~ /^#/){ 
			next}
		push (@checkpoints, [split(/\s+/, $_)]);
		}
	close (CHECK);
return \@checkpoints;
}

sub WRITE_P2S {
	
	my $path = shift @_;
	my $coor = shift @_;
	
	if (!$coor) {return 0}
	
	open (OUT, ">", $path) or
	  die "Couldn't open $path\n";
	print OUT "@{$coor}[0]", " ", "@{$coor}[1]";
	close (OUT);

return 1;
}

1; #is needed that the module can be loaded correctly

