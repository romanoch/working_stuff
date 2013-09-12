package Modules::OUT;

use strict;
use warnings;
use Data::Dumper;
use Carp;

my $verbose;

sub vieRNA_SHAPE {
  
  my @RDAT_files = @_;
  my %seen_files;
  my $count = 1;
  my $bla = 0;
  
  # make directory
  mkdir "RDAT_processed" or print $!,"\n";
  
  foreach (@RDAT_files) {
  
    my %RDAT_file = %{$_};
    my $filename = $RDAT_file{"NAME"};
    my @prob_profile = @{$RDAT_file{"PROBING_PROFILE"}};
    
    $seen_files{$filename}++;
    my $count = $seen_files{$filename};

  
    open OUT, ">", "RDAT_processed/".$RDAT_file{"NAME"}."_$count".".shp" or die "Couldn't open output file!\n"; # or die $!;
#     print OUT ">",$RDAT_file{"NAME"},"\n";
#     print OUT "#\t",$RDAT_file{"SEQUENCE"},"\n";
#     print OUT "#\t",$RDAT_file{"STRUCTURE"},"\n";
    
    #format: ID \t BASE \t REACTIVITY \n
    for (my $i = 0; $i <= $#prob_profile; $i++) {
      print OUT $i,"\t";
      print OUT $prob_profile[$i]{"BASE"},"\t";
      print OUT $prob_profile[$i]{"REACTIVITY"} if ( defined($prob_profile[$i]{"REACTIVITY"}));
      print OUT "\n";
      }
    
    close OUT;
    $bla++;
  }
  print $bla," files processed\n";
#   foreach (keys %seen_files){print $_,"\t",$seen_files{$_},"\n"}
}

1;