#!/usr/local/bin/perl -w

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

require INOUT;

#################################
#	Options Section		#
#################################

my $map_path = "";
my $p2s_path = "";
my $check_path = "";
my $s2p_path = "";


GetOptions(
	"map=s" => \$map_path,
	"p2s=s" => \$p2s_path,
	"check=s" => \$check_path,
	"s2p=s" => \$s2p_path);

if (!$map_path){
  $map_path = "map.txt";}
if (!$p2s_path){
  $p2s_path = "play2serv.txt";}
if (!$check_path){
  $check_path = "checkpoints.txt";}
if (!$s2p_path) {
  $s2p_path = "serv2play.txt";}


#################################
#		Main		#
#################################

#read map
my $map = &READ_TRACK($map_path);			#returns a 2D Array (x,y)
#read serv2play-file
my ($mypos,		#Array (x,y)
    $myvec,		#Array (x,y)
    $nextcheck,		#Scalar
    $nrplayers,		#Scalar
    $coorplayers) 	#AoA
    = &READ_S2P($s2p_path);
#read checkpoint-file  
my $checkpoints = &READ_CHECKPOINTS($check_path);	#Array (ID, x, y)

my $nextpos = &NEXTPOS($mypos,$myvec,$nextcheck);

&WRITE_P2S($nextpos);


#########################################
#		SUBS			#
#########################################

































