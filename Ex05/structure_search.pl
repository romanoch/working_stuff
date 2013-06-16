#!/usr/local/bin/perl -w

use strict;
use warnings;
use Math::MatrixReal;
#todo: proper matrix permutation, solution output, bugfixing

# Main ---------------------------------------

	# Read Input-----------------------------
	my $filename = shift @ARGV;							# query graph
	my ($query_adj, $nr_vertices_query, $degree_query) = &READ($filename);		# returns matrix object and scalar
	
	$filename = shift @ARGV;							# target graph
	my ($target_adj, $nr_vertices_target, $degree_target) = &READ($filename);	# returns matrix object and scalar
	
	# Build empty Transformation Matrix M' with dimensions (query vertices x target vertices)
	my $M0 = new Math::MatrixReal($nr_vertices_query, $nr_vertices_target);
	
	#fill with 1 if degree of jth point in target >= ith point in query
	for my $i (0..($nr_vertices_query-1)) {
		for my $j (0..($nr_vertices_target-1)) {

			if (%$degree_target{$j} >= %$degree_query{$i}) {$M0->assign( $i, $j, 1)} else { $M0->assign( $i, $j, 0);}
	}	}
	
	# Find Isomorphism(s)--------------------
	my $depth = -1;
	my @solution;	#, vector, will store solution ~global
	&SOLVE($query_adj,$target_adj,$nr_vertices_query,$M0,$depth) or print "No Isomorphisms found!\n", exit;
	
	

# Subs ---------------------------------------
sub READ {

my @vertices;
my @edges;
my $type;
my $adj_matrix;
my %graph;
my $filenam = shift;

open (FILE,$filenam) or die "No Input file(s) given! Input format is: Query graph, Template graph";

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
  #recursive permutation of matrix M + ckeck whether isomorphism was found,
  #returns true if solution found (stop looking), false if not found (continue)
  #omits multiple solutions!
  
  
  my ($A,$B,$vert_query,$M,$depth) = @_;
  $depth++;
  if ($depth > $vert_query){return 0}		#stop if depth == number of vertices
  
  
  #matrix permutation..
  #for (0..($columns der matrix -1){
  #
  #  for my $j (0..($nr_vertices_target-1){	#$depth = $i
#	$M->assign( $depth, $j, 1)
  
 

  
  
  #check 
  my $C = &CALC_MATRIX($M,$B);				#calculate C = M x Transpos( M x B )
  if ( &CHECK($C,$A,$vert_query) ) {return 1}		#return true, end
  
  #call self (returns true/false)
  &SOLVE($A,$B,$vert_query,$M) && return 1;				#return true if successful match
  
  #end while
  
  #if every permutation gave no result (true): return 0
  return 0;
}

sub CALC_MATRIX {  	#Perform Operation C = M x Transpos( M x B )
  
  my ($M, $B) = @_;
  
  my $product = $M->multiply($B);
     $product->transpos($product);
  my $C = $M->multiply($product);
  
  return $C;
}

sub CHECK {  		#checks whether matrix A corresponds to (a part of) matrix C
  
  my ($C,$A,$nr_vertices_quer) = @_;	# C..transformed matrix, A..query graph
  
  for my $i (0..($nr_vertices_quer-1)) {
    for my $j (0..$nr_vertices_quer-1) {
    
      if ( $A->element($i,$j) == 1 && $C->element($i,$j) != 1) { return 0}	#end when there is even 1 mismatching pair, return false
  }}
  return 1; #return true when complete matrix matched = isomorphism found
}