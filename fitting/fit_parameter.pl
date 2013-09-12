#!/usr/bin/env perl
#============================================================================================
#
#	FILE:	fit_parameter.pl
#	DATE:	27.6.2013
#	AUTHOR:	Roman Ochsenreiter, TBI
#
#
#	DESCRIPTON:
#		This script fits SHAPE-reactivity-parameters, used as in Christoph Kaempffs
#		SHAPE-generator, to data samples. It has to be provided with a reactivity file,
#		containing these parameters and rdat file(s) containing the experimental data.
#
#	For the exact specifications concerning the data format containing probing data (RDAT)
#	please view: http://rmdb.stanford.edu/repository/specs/
#
#============================================================================================

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use File::Find;

use lib '/home/mescalin/romanoch/RNA_PROBING/fitting';	#should be dynamic
require Modules::Chemical;
require Modules::Parse_RDAT;
require Modules::Refine_RDAT;
require Modules::Fit;
# require Modules::OUT;

# Options Section
#########################################################
my $rdat_library =  "rdat_files";
my $chemical_file = "SHAPE.reac";
my $verbose = 0;		# 0-error, 1-warnings, 2-debug
my $split = 0;
my $motif_search = 0;		#enable search for motifs
my $modifier = "SHAPE|NMIA|1M7";
my $fit = 0;			#enable fitting of parameters
my $probing_frame = 2;
my $output = 0;
my @RDAT_files;

GetOptions (
  "rdat=s" => \$rdat_library,		#path of the RDAT-library
  "chemical=s" => \$chemical_file,	#probing reagent used
  "verbose=i" => \$verbose,		#addierbar machen
  "split" => \$split,			#split files with multiple experiments
  "out" => \$output,			#print out the files in
  
  #parameters for motif search:
  "fit" => \$fit,			#enable parameter fitting
  "modifier=s" => \$modifier,		#select probe (SHAPE/NMIA. DMS...)
  
  #parameters for fitting
  "motif_search" => \$motif_search,	#enable motif search
  "frame=i" => \$probing_frame);	#window sizefor reactive motif search
  
if (!$rdat_library) { die "No path to Rdat-Library given\n"}


### Main
###########################################################
if ($motif_search){
  @RDAT_files = &load_files($rdat_library, $modifier, $split);
  Modules::Fit::search_main( $verbose, \@RDAT_files);
  print "Finished Motif evaluation.\n";
  }

if ($output) {
  @RDAT_files = &load_files($rdat_library, $modifier, $split);
  Modules::OUT::vieRNA_SHAPE( @RDAT_files);}

  
#this needs additional attention  
# if ($fit) {
#   @RDAT_files = &load_files($rdat_library, $modifier, $split);
#   ##### Read Chemical-File, taken from Kaempf's probing program
#   my $probing_parameters = Modules::Chemical->new($chemical_file);	# returns object
#   print "Probing-parameters for fitting successfully imported!\n" if (defined $probing_parameters);
# 
#   Modules::Fit::fit_main( $verbose, \@RDAT_files, $probing_parameters);
# 
#   }


### END Main
############################################################





# Subroutines
############################

sub load_files {	#returns the RDAT-files, 
  my @RDAT_paths = &find_files(shift @_);
  my $modifier = shift @_;
  my $split = shift @_;
  my @RDAT_files;
  my $nrfiles = 0;
  
  foreach (@RDAT_paths) {
    my @data = Modules::Parse_RDAT::parse_main( $verbose, $_, $split, $modifier);
    if (@data) {
      push (@RDAT_files, @data);
      $nrfiles++;}
      else {next}
  }
  print $nrfiles," files successfully read!\n";
  print scalar(@RDAT_files)," unique probing experiments successfully read!\n";
  
  my @RDAT_final;
  foreach my $i (@RDAT_files) {
      push @RDAT_final, (Modules::Refine_RDAT::refine_main($verbose, $i) or next);
  }

  print scalar(@RDAT_final)," probing profiles created!\n";
  return @RDAT_final;
}  

sub find_files {	#finds RDAT-files, returns file paths
  my $lib = shift @_;
  my @RDAT_paths;
  
  find (\&get_RDAT, $lib);	#function which searches a directory
  sub get_RDAT {
    push (@RDAT_paths, $File::Find::name) if ($File::Find::name =~ /.rdat/) }
    
  print scalar(@RDAT_paths), " RDAT-Files found!\n";
  return @RDAT_paths;
}

