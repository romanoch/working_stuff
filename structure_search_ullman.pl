#!/usr/local/bin/perl -w

use strict;
use warnings;
#use PDL::Matrix;
#use PDL::MatrixOps;

use Math::MatrixReal;

use constant {POS =>0, ELE =>1, NUMBONDS =>2, SEEN =>3};
#use List::MoreUtils qw{minmax};



# Main ---------------------------------------

	# Read Input-----------------------------
	my $filename = shift @ARGV;
	my ($query_adj, $query_graph, $query_vertices) = &READ($filename);	# read query graph grom file
	$filename = shift @ARGV;
	my ($templ_adj, $templ_graph, $template_vertices) = &READ($filename);	# read template graph from file

	# build adjacency matrix objects with PDL
	my $query = PDL::Matrix->pdl(@$query_adj);
	my $templ = PDL::Matrix->pdl(@$templ_adj);
	
	# build matrix M'(ij) rows: query, columns: template #i..rows, j..columns
	# fill with 1 if j>=i else 0
	my @M;
	for my $i (0..($query_vertices-1)) {
		$M[$i] = [];
		
		for my $j (0..($template_vertices-1)) {
		
			if ($j >= $i) { $M[$i][$j] = 1 }
			else { $M[$i][$j] = 0 }
		}
	}
	
	# convert array into matrix object with PDL
	my $M = PDL::Matrix->pdl(@M);
	
	
	# Find Isomorphism(s)--------------------
	
	
sub PERMUTATE MATRIX	

# Subs ---------------------------------------
sub READ {

my @vertices;
my @edges;
my $type;
my %graph_information;		# {position/ID} = [ position, element type, number of bonds ]
my @adj_matrix;
my $filename = shift;

open (FILE,$filename) or die "No Input file(s) given! Input format is: Query graph, Template graph";

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
	my $nr_edges = $edges[0][0];		shift @edges; 

  ### build adjacency matrix
  for my $i (0..($nr_vertices-1)) {
    $adj_matrix[$i] = []; 					# fill with anonymous arrays
    for my $j (0..($nr_vertices-1)) {$adj_matrix[$i][$j] = 0}	# fill all positions with 0 so we later dont get undefs	
    };
 
  foreach (@edges) {							# @edges = array of arrays
    $adj_matrix[ @$_[0] ][ @$_[1] ] = 1; #@$_[2];	# fill with sign that characterizes the edge (: or =)
    $vertices[@$_[0]][2]++;						# increase num of bonds for atom1 
    $vertices[@$_[1]][2]++;						# increase num of bonds for atom2
    }

  ### create hash containing additional information
  foreach (@vertices) {
    $graph_information{@$_[POS]} = [@$_[POS], @$_[ELE], @$_[NUMBONDS], 0 ];		#value: [POS, ELE, NUMBONDS, SEEN]
    }

return (\@adj_matrix, \%graph_information, $nr_vertices);}


