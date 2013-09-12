package Modules::Parse_RDAT;

use strict;
use warnings;
use Data::Dumper;
use Math::Round;
use RNA;

# Aufgaben:	Einlesen von RDAT-files in hashes, Generierung der Strukturbeschreibung,
#		fuer den Fall dass mehrere Experimente in einem file sind: aufteilen - am
#		Ende sollte jedes RDAT-file nur 1 REACTIVITY-Datensatz haben.

our $verbose;

sub parse_main {
  
  # split the rdat files with multiple experiments into separate files
  $verbose = shift @_;
  my $path = shift @_;
  my $split = shift @_;		#split yes/no
  my $modifier = shift @_;	#return only experiments probed with specific reagent
  my @RDAT_files;
  my %self = &read_RDAT($path, $modifier) or return;	#$verbose geben
  
  #substitute structure through MFE - currently just for files without structure
  if ( !defined($self{"STRUCTURE"}) ) {
    my ($struct, $mfe) = RNA::fold( $self{"SEQUENCE"});
    $self{"STRUCTURE"} = $struct;}
  
  #split
  for my $i (1 .. $self{"EXPERIMENTS"}) {      
      push @RDAT_files, &split_experiment(\%self, $i);
      if (!$split) {return @RDAT_files}	#quit after first round (this way you only get the first experiment)
  }
  return @RDAT_files; 
}

sub split_experiment {

  my ($selfr, $ID) = @_;
  my %self = %{$selfr};
  
  $self{"ID"} = $ID;
  $self{"REACTIVITY"} = $self{"REACTIVITY:"."$ID"};
  $self{"RAW_REACTIVITY"} = $self{"RAW_REACTIVITY:"."$ID"};
  $self{"ANNOTATION_DATA"} = $self{"ANNOTATION_DATA:"."$ID"};
  
  for my $j (1 .. $self{"EXPERIMENTS"}) {
    delete $self{"REACTIVITY:"."$j"};
    delete $self{"RAW_REACTIVITY:"."$j"};
    delete $self{"ANNOTATION_DATA:"."$j"};
    }
    
  return \%self;
}

sub read_RDAT {

  my $path = shift @_;
  my $modifier = shift @_;
  my %self;
  my $rdat_version = 0.32;
  my $logfile = "logfile.log";
  
  $self{"PATH"} = $path;

  open (FI, "<", $path) or die "Could not open file $path!";  
  while (<FI>) {

    chomp $_;
    $_ or next;
    
    my @line = split(/\s+/, $_);
    my $ID = shift @line;		#first element in a line identifies the data
    
    if ( $ID eq "RDAT_VERSION" ) {
	$self{$ID} = join("", @line)}   #scalar

    elsif ( $ID eq "NAME") {
	$self{$ID} = join("", @line)}   #scalar

    elsif ( $ID eq "SEQUENCE") {
	$self{$ID} = join("", @line)}	#string

    elsif ( $ID eq "STRUCTURE") {
	$self{$ID} = join("", @line)}	#scalar

    elsif ( $ID eq "OFFSET") {
	$self{$ID} = join("", @line)}	#scalar

    elsif ( $ID eq "SEQPOS") {
	$self{$ID} = \@line}		#array ref

    elsif ( $ID eq "ANNOTATION") {
	$self{$ID} = \@line}		#array ref
	
    elsif ( $ID eq "COMMENT") {
	$self{$ID} = join(" ",@line)}	#string
	
    elsif ( $ID eq "XSEL") {
	$self{$ID} = \@line}		#array ref
	
    elsif ( $ID eq "MUTPOS") {
	$self{$ID} = \@line}		#array ref
	
    #regexes weil mehrere nummerierte lanes moeglich
    elsif ( $ID =~ "ANNOTATION_DATA") {	
	$self{$ID} = \@line}		#array ref
	
    elsif ( $ID =~ "REACTIVITY_ERROR") {
	$self{$ID} = \@line}		#array ref
	
    elsif ( $ID =~ "REACTIVITY") {
	$self{$ID} = &norm_bp(@line);	#array ref
	$self{"RAW_"."$ID"} = \@line}	#array ref

    elsif ( $ID =~ "XSEL_REFINE") {
	$self{$ID} = \@line}		#array ref
	
    elsif ( $ID =~ "SEQPOS") {
	$self{$ID} = \@line}		#array ref
	
    elsif ( $ID =~ "TRACE") {
	next;}
# 	$self{$ID} = \@line}		#array ref omitted, much data but no use for it
	
    elsif ( $ID eq "READS") {
	$self{$ID} = \@line}		#array ref
	
    else { 
	print  "File $path :", " Could not process ID $ID!\n" if ($verbose >= 2) }
  } 
 close (FI); 

  #return undef (exit) in case the modifier is different
if ($modifier){
  if ( join(" ",@{$self{"ANNOTATION"}}) !~ m/$modifier/) {
    print "Omitting ",$self{"PATH"},": has different modifier than $modifier\n";
    return}
}
 
#sort out files that lack the crucial sections (STRUCTURE), SEQUENCE or REACTIVITY
if ( !defined($self{"SEQUENCE"}) ) {
  print "File $path was omitted due to missing SEQUENCE\n" if ($verbose >= 1);
  return }
  
 elsif ( !defined($self{"REACTIVITY"}) && !defined($self{"REACTIVITY:1"}) ) {
  print "File $path was omitted due to missing REACTIVITY\n" if ($verbose >= 1);
  return }
 
 elsif ( !defined($self{"NAME"}) ) {
  print "File $path was omitted due to missing NAME\n" if ($verbose >= 1);
  return }
  
 elsif ( !defined($self{"RDAT_VERSION"}) ) {
  print "File $path was omitted due to missing RDAT_VERSION\n" if ($verbose >= 1);
  return }
  
 elsif ( !defined($self{"STRUCTURE"}) ) {
  print "Warning, $path lacks section STRUCTURE, using MFE\n" if ($verbose >= 1);
  
  }
 
#warn if version formats are not the same
  if ($verbose == 2) {
  
    if ($self{"RDAT_VERSION"} != $rdat_version  &&  $self{"RDAT_VERSION"} > $rdat_version) {
      print "Warning: $path uses newer Version of the RDAT-Format! (", $self{"RDAT_VERSION"}, ")\n";
      }
    else {
      print "Warning: $path uses older Version of the RDAT-Format! (", $self{"RDAT_VERSION"},")\n";
      }     
  }

 # count the number of experiments in this file
  my $i = 1;
  while ( defined($self{"REACTIVITY:"."$i"}) ) {
    $self{"EXPERIMENTS"}++;
    $i++;
    }
  
return %self; 
}

sub norm_heur {
  #heuristic approach as described in Paper Low & Weeks 2010
  #remove top 2%, take average of next 8%, every value by this
  #Normalization method: Define Average Reactivity of top 10% as 1.0
  
  my @raw = @_;    
  my @raw_sorted = sort {$b <=> $a} @raw;  
  my $size = scalar(@raw);

  my $top2 = round(($size / 100) * 2);
  $top2 = 1 if ($top2 < 1);
  
  my $top8 = round(($size / 100) * 8);
  $top8 = 1 if ($top8 < 1);

  #remove top 2%
  for (1 .. $top2) {
    shift @raw_sorted;
    }
    
  #find top 8%
  my $avg = 0;
  for (0 .. $top8-1) {
    my $dat = shift @raw_sorted;
    $avg += $dat;
    }
  
  $avg /= $top8;
    
  for (0 ..  scalar(@raw)-1) {
    $raw[$_] /= $avg;
    }
    
 return @raw;
}

sub norm_bp {
  
  # outliers = values of 4th quartile greater than 1.5 x interquartile range
  # average next 10%, divide every value by this

  my @raw = @_;
  my @sorted = sort {$a <=> $b} @raw;		#sort numerically descending (first element is largest) 
  
  #rewrite this, under the assumption that....
  return \@raw if ($sorted[-1] <= 4); 		#check whether data is already normalized, needs to be reworked!!
  
  my $quart1 = round(scalar(@sorted) / 4);
  my $quart3 = ($quart1 * 3);
  my $range = ($sorted[$quart3] - $sorted[$quart1]) * 1.5;	#interquartile range

  LOOP: for (1 .. $quart1) {
	  if ($sorted[-1] > $range) {pop @sorted}
	  else {last LOOP}	  
	  }
    
  my $tenpercent = round(scalar(@sorted) / 10);
  my $average = 0;
  
  for (1..$tenpercent) {
    my $b = pop @sorted;
    $average += $b;
  }
  
  $average /= $tenpercent;
  
  for (0 .. scalar(@raw)-1) {
    $raw[$_] /= $average;
    }

  return \@raw;
}


1;