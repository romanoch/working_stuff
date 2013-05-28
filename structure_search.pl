#!/usr/local/bin/perl -w

use strict;
use warnings;
#use vars qw/@adj_matrix %graph_info $filename/;
use constant {POS =>0, ELE =>1, NUMBONDS =>2, SEEN =>3};
#use PDL::MatrixOps;	#ist installiert
use List::MoreUtils qw{minmax};

# Main ---------------------------------------

	# Read Input-----------------------------
	my $filename = shift @ARGV;
	my ($query_adj, $query_graph) = &READ($filename);	# read query graph grom file
	$filename = shift @ARGV;
	my ($templ_adj, $templ_graph) = &READ($filename);	# read template graph from file

	# Find Isomorphism(s)--------------------
	&FIND_ISOM($query_adj, $query_graph, $templ_adj, $templ_graph);

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
    $adj_matrix[ @$_[0] ][ @$_[1] ] = @$_[2];	# fill with sign that characterizes the edge (: or =)
    $vertices[@$_[0]][2]++;						# increase num of bonds for atom1 
    $vertices[@$_[1]][2]++;						# increase num of bonds for atom2
    }

  ### create hash containing additional information
  foreach (@vertices) {
    $graph_information{@$_[POS]} = [@$_[POS], @$_[ELE], @$_[NUMBONDS], 0 ];		#value: [POS, ELE, NUMBONDS, SEEN]
    }

return (\@adj_matrix, \%graph_information);}



sub FIND_ISOM {

	my ($query_adj, $query_graph, $templ_adj, $templ_graph) = @_;
	#if (!defined ($query_graph)) {print "hottl"}
	local ($start_ID_query, $start_ELE) = &FIND_START($query_graph);
	my @template_start;
	
	#find possible starting points for the search in the template graph
	foreach (keys %$templ_graph) {
	  if (@$_[ELE] eq $start_ELE) {
	    push (@template_start, @$_[ID])}
	  }
	  
	if (!defined(@template_start)) {die "An Element of the Query graph can't be found in the template!"}

	
	&SOLVE( \@template_start, $query_adj, $query_graph, $templ_adj, $templ_graph);
}

sub SOLVE {

  my ($start_ID_query, $template_start, $query_adj, $query_graph, $templ_adj, $templ_graph) = @_;
     #	scalar		array		AoA		hash[]	   AoA		hash[]

  


}


sub FIND_START {

	#this is my "refinement" of the brute-force approach. It tries to make an educated guess for a
	#starting point by choosing the most rare element. This should eliminate most of the possible
	#vertices where a search could be started. If there is an equal number of rare atoms, the one with
	#more non -H bonds is selected, since this atom is more likely to be in a central position, although
	#i am not sure whether this yields any performance increase. In case of no difference in Element frequency
	#nor in number of bonds, one of those vertices is selected randomly.
	
	if (defined (@_)) {print "hottl"}
	print @_;
	my $query_graph = @_;		# ist ein hash mit allerle
	my %query_graph = %$query_graph;
	my %elements;
	#my %bonds;

	#count occurences of elements
	foreach (keys %query_graph) {$elements{ @$_[ELE] }++;}
	
	#and sort this hash by values
	my @keys_sorted_after_values = sort { $elements{$a} <=> $elements{$b} } keys %elements;
	
	# if the vertex your looking at is this element, take it and return it as starting position
	 foreach (keys %query_graph) {
	  if ( @$_[ELE] eq $keys_sorted_after_values[0]) {	
	    return @$_[ID],@$_[ELE]}
	  }
	die "No starting point found";
	}









