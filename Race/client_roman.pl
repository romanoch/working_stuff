#!/usr/local/bin/perl -w

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

require MODULES::INOUT;
require MODULES::movement;

#########################################
#		Options Section		#
#########################################

my $map_path = "";
my $p2s_path = "";
my $check_path = "";
my $s2p_path = "";
my $mode = "";
#my $mem_path = "memory.txt";

GetOptions(
	"map=s" => \$map_path,
	"p2s=s" => \$p2s_path,
	"check=s" => \$check_path,
	"s2p=s" => \$s2p_path,
	"mode=s" => \$mode);

if (!$map_path){
  $map_path = "../map.txt";}
if (!$p2s_path){
  $p2s_path = "../play2serv.txt";}
if (!$check_path){
  $check_path = "../checkpoints.txt";}
if (!$s2p_path) {
  $s2p_path = "../serv2play.txt";}


#########################################
#		Main			#
#########################################

#read map
my ($map,					# 2D Array (x,y)
   $checksum)					# scalar
   = &INOUT::READ_TRACK( $map_path);
   
#load memory
#my $memory = &INOUT::READ_MEMORY( $mem_path, $checksum) or &INIT_MEMORY();
  
#read serv2play-file
my ($mypos,		#Array (x,y)
    $myvec,		#Array (x,y)
    $nextcheck,		#Scalar
    $nrplayers,		#Scalar
    $coorplayers) 	#AoA
    = &INOUT::READ_S2P( $s2p_path);

#read checkpoint-file  
my $checkpoints = &INOUT::READ_CHECKPOINTS( $check_path);	#Array (ID, x, y)
#calculate next position
my $nextpos = &NEXTPOS( $mypos,$myvec,$nextcheck,$map,$mode);
#write output file
&INOUT::WRITE_P2S( $p2s_path, $nextpos) or die "No Coordinates given. Couldn't write play2serv!";


#########################################
#		SUBS			#
#########################################

sub NEXTPOS {

  my ($mypos,
      $myvec,
      $nextcheck,
      $map,
      $mode) 
      = @_;
      
if (!$mode) {
  return &movement::greedy_simple ( $mypos, $myvec, $nextcheck, $checkpoints);
  }
elsif ($mode eq "random") {
  return &movement::random_walk ( $mypos, $myvec);
  }
# elsif ($mode eq "greedy_refined") {
#   return &movement::greedy_simple ( $mypos, $myvec, $nextcheck, $checkpoints, $map) ;
#   }
else {
  return &movement::greedy_simple ( $mypos, $myvec, $nextcheck, $checkpoints);
  }
}

# sub INIT_MEMORY {
# 
# }






























print "################\n#Stechus Kaktus#\n################\n";