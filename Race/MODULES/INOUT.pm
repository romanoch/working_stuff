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
	my $checksum = 0;
	
	open (TRACK, "<", $path) or
	  die "Couldn't open $path\n";
	while (<TRACK>){
		if ($line == 1){
			@track_parameters = split(/\s+/, $_);
			$line++;
			next;
			}
		push @track, [split(//, $_)];
		}
	close (TRACK);
	
	foreach my $ele (@track) {
	  foreach (@{$ele}){
	    if ($_ eq "#"){ $checksum += 1}
	    elsif ($_ eq ".") { $checksum += 2}
	    elsif ($_ eq "v") { $checksum += 3}
	  }
	}
	
	return \@track, $checksum;
}

sub READ_MEMORY {

  # structure of a memory is checksum in the first line,
  # and in each following line <NEXTCHECK> whitespace <STATE>
  
  my $path = shift;
  my $checksum = shift;
  my $line = 0;
  my %states;
  
  open (MEMO, "<", $path) or print "No memory found. Create new one."; return 0;
  while (<MEMO>){
    chomp $_;
    
      if ($line == 0) {
	if ($_ != $checksum) {
	  close MEMO;
	  print "Memory doesn't match track. Creating new one.\n";
	  return 0;
	  }
	$line++;
      }
   my @line = split;
   $states{$line[0]} = $line[1];
   }
  return \%states;
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
		if ( $_ =~ /#/ ) { next }
			
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
	#print @mypos,"\n", @myvec,"\n", $nextcheck,"\n", $players,"\n";#, \@players;
	#print $mypos[1];
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
	#print @{$coor};
	
	open (OUT, ">", $path) or
	  die "Couldn't open $path\n";
	print OUT "@{$coor}[0]", " ", "@{$coor}[1]";
	close (OUT);

return 1;
}

1;

