#!/usr/local/bin/perl -w

use strict;
use warnings;
use Math::MatrixReal;
use Getopt::Long;

my $file_target;
my $file_query;

GetOptions ( "t=s" => \$file_target, "q=s" => \$file_query );


# Main ---------------------------------------
my ($target_matrix,
	$target_vertices_nr,
	$target_degree) = &READ($file_target);	#read target graph
my ($query_matrix,
	$query_vertices_nr,
	$query_degree) = &READ($file_query);	#read query graph

	&SOLVE()
	
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
   
    chomp $_;					#remove newline character
    $_ or next;					#ignore empty lines
        
    if ($_ =~ /Knoten|vert/) {$type = "v"};
    if ($_ =~ /Kante|Edges/) { $type = "e"};
    if ($_ =~ /#/) {next};			#ignore commented lines
    
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
	my $nr_edges = $edges[0][0];		shift @edges; 		#has no real purpose (yet)

	
	#build an empty adjacency matrix
	$adj_matrix = new Math::MatrixReal($nr_vertices,$nr_vertices);
	
	#fill with 1 where vertices are connected
	foreach (@edges) {
	  $adj_matrix->assign( @$_[0], @$_[1], 1); 	# assign( row, column, value) note: value replaces old one
	  $adj_matrix->assign( @$_[1], @$_[0], 1); 	# (make it symmetrical)
		  
	  $graph{@$_[0]}++; $graph{@$_[1]}++;		# record degree of graph
	  }
	

return $adj_matrix, $nr_vertices, \%graph}

sub SOLVE {
	
	


}


