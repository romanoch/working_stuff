#!/usr/local/bin/perl -w

use strict;
use warnings;
#use Math::MatrixReal;
use Getopt::Long;

my $file_target;
my $file_query;
my @vertices_left;

GetOptions ( "t=s" => \$file_target, "q=s" => \$file_query );


# Main ---------------------------------------
<<<<<<< HEAD
my ($target_matrix,
    $target_vertices_nr,
    $target_degree) = &READ($file_target);	#read target graph
my ($query_matrix,
    $query_vertices_nr,
    $query_degree) = &READ($file_query);	#read query graph

&SOLVE()

=======
my ($target_matrix,							# Array of Arrays
	$target_vertices_nr,
	$target_degree) = &READ($file_target);	#read target graph
my ($query_matrix,
	$query_vertices_nr,
	$query_degree) = &READ($file_query);	#read query graph
	
	for (1..$target_vertices_nr) {			#fill array with all vertex IDs
		push (@vertices_left, $_);
		}
		
	for ( 1..scalar(@vertices_left) ) {	
		&SOLVE( \@vertices_left );
	}
	
>>>>>>> 63c0cfe59bd8e649bdb1b97513d58f87171237c2
# Subs ---------------------------------------
sub READ {

my $file = shift @_;
my @vertices;
my @edges;
my $type;
my $adj_matrix;
my %graph;


open (FILE,$file) or die "No Input file(s) given! Input format is: Query graph, Template graph";

  while (<FILE>) {
   
    chomp $_;	#remove newline character
    $_ or next;	#ignore empty lines
        
    if ($_ =~ /Knoten|vert/) {$type = "v"};
    if ($_ =~ /Kante|Edges/) { $type = "e"};
    if ($_ =~ /#/) {next};	#ignore commented lines
    
    if ($type eq "v") {
     push ( @vertices, [split(/\s+/,$_)] );	# 0: pos ( = ID), 1: element type
     }
    elsif ($type eq "e") {
     push ( @edges, [split(/\s+/,$_)] );	# pos 0 (vertex1) - pos 1 (vertex2), pos 2: type
     }
  }

close (FILE);
  
  ### get number of vertices/edges (are first elements in both arrays)
my $nr_vertices = $vertices[0][0];	shift @vertices;	#remove first entry from array since it is no vertex/edge
my $nr_edges = $edges[0][0];	shift @edges; #has no real purpose (yet)


#build an empty adjacency matrix
for my $i (0..$nr_vertices) {
	$adj_matrix[$i] = []
	for my $j (0..$nr_vertices) {
		$adj_matrix[$i][$j] = 0;
	}
}

#$adj_matrix = new Math::MatrixReal($nr_vertices,$nr_vertices);

#fill with 1 where vertices are connected
foreach (@edges) {

	$adj_matrix[ @{$_}[0] ][ @{$_}[1] ] = 1;	
	$adj_matrix[ @{$_}[1] ][ @{$_}[0] ] = 1;	#make matrix symmetrical

#$adj_matrix->assign( @$_[0], @$_[1], 1); # assign( row, column, value) note: value replaces old one
#$adj_matrix->assign( @$_[1], @$_[0], 1); # (make it symmetrical)

$graph{@$_[0]}++; $graph{@$_[1]}++;	# record degree of graph
}


return \@adj_matrix, $nr_vertices, \%graph}

sub SOLVE {

	my ($vert, 
		$hist, 
		$last_ID) = @_;
		
	my @vertices_left = @{$vert};
	my @history = @{$hist};
	
	push (@history, $last_ID);
	
	if (scalar(@vertices_left) == 1) {		# start checking if we reached the end of the tree
		&CHECK_GRAPH(@history);
		}
	
	for ( 1..scalar(@vertices_left) ) {
	
		my $current_ID = shift (@vertices_left);
		
		&SOLVE(\@vertices_left, \@history, $current_ID );		# continue with array shortened by 1
		
		push (@vertices_left, $current_ID);						# append element to the end of the array
		
	}
	
}

sub CHECK_GRAPH {

	my ($history) = @_;
	
	
	

	
	
	
	
	
	
	
	
}

<<<<<<< HEAD

}
=======
>>>>>>> 63c0cfe59bd8e649bdb1b97513d58f87171237c2
