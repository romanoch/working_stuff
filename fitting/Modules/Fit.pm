package Modules::Fit;

use strict;
use warnings;
use Data::Dumper;
use RNA;
use Carp;

my $verbose;

#################### REACTIVE MOTIVE SECTION ##################
# workflow: 	generate possible motifs, print all reactivity values matching
# 		this motif to a file and analyse (boxplot) with R

  #global variables for generate_motifs()
  my @alphabet = ("U", "P");
  my $depth = 0;
  my $maxdepth = 3;
  my @motifs;

  
sub search_main {
  $verbose = shift @_;
  my @RDAT_files = @{shift @_};
  &generate_motifs(""); 
  my @motives = @motifs;	#copy the global variable
  
#   print Dumper @motifs;
  
  foreach my $mot (@motives) {
    
    my @str_desc_matches;
    my @str_desc_simple_matches;
    
    foreach (@RDAT_files) {
      my %set = %{$_};
      my $strdesc = $set{"STRUCTURE_DESCRIPTION"};
      my $strdesc_simp = $set{"STRUCTURE_DESCRIPTION_SIMPLE"};
      my @RNA = @{ $set{"PROBING_PROFILE"} };
      
      while ($strdesc =~ /$mot/g){
	 push @str_desc_matches, $-[0];}	
      
      #still have to alter $mot
#       while ($stdesc_sim =~ /$mot_diff/g){
# 	push @str_desc_simple_matches, $-[0];}
      
      
      }
    
    }
  
  
  #gives you all possible combinations of the elements of your alphabet up to the length of $maxdepth
    
  
#   foreach my $seq (@motifs) {
#     
#     open DATA, ">", "tmp.txt";
#     
#     foreach (@RDAT_files) {
#       my $sdfs###
#       
#       }
#       
#     close DATA;
#     
#     }
#   
   
}

sub generate_motifs {
  
  my $motif = shift @_;
  
  if ($depth >= $maxdepth) {return}
  else {
    $depth++;
    foreach (@alphabet) {
      &generate_motifs($motif.$_);
      push @motifs, $motif.$_;
      }
    $depth--;
    return;
    }
}




sub search_main_old {
  
  $verbose = shift @_;
  my $RDAT_ref = shift @_;
  my $probing_frame = shift @_;
  my @RDAT_files = @{$RDAT_ref}; #Array mit (referenzen auf) hashes, jeder hash enthaelt die gesamte experimentelle information, unter key PROBING_PROFILE liegt ein (referenziertes) array in dem wi
 
  my %motifs;
  #for output purposes
  #my $curr = 0;
  #my $progress;
  
  foreach (@RDAT_files) {
      my %dataset = %{$_};
      my $stru_dsc = $dataset{"STRUCTURE_DESC"};
      my @profile = @{$dataset{"PROBING_PROFILE"}};
      
    for (my $i = 0; $i <= $#profile; $i++) {
      my %profile = %{$profile[$i]};
      
      if (!defined($profile{"REACTIVITY"})) {
	next};
      if ($profile{"REACTIVITY"} >= 0.7  &&  $profile{"REACTIVITY"} <= 2.0) {
	  if ($i-$probing_frame >= 0  &&  $i+$probing_frame <= length($stru_dsc) ) {
	      $motifs{substr $stru_dsc, $i-$probing_frame, (2 * $probing_frame +1) }++}
      }
    }
    
  }
  return %motifs;
}





######################## FITTING SECTION ###################

#not finished
sub fit_main_old {
  
  #try different parameters, generate multidimensional data structure and look for minimum
  
  my $verbose = shift @_;		#scalar
  my @RDAT_files = @{shift(@_)};	#hashrefs
  my $probe = shift @_;			#object
  my $modifier = shift @_;		#string
  my $SCORE = 0;
  
#   print $probe->probe_name(),"\n";
#   print Dumper($probe->probe_seq());
#   print Dumper($probe->probe_str());
#   print Dumper($probe->probe_reac());
  print Dumper($probe->probe_cut());
  
  exit; ###########################################################3
  #modifizieren der parameter LOOP
  $SCORE = &fit_to_db(\@RDAT_files, $probe);
  #END LOOP
  
}


sub fit_main {
  #fit to database, given a certain parameter set
#   my @RDAT_files = @{shift(@_)};	#hashrefs  
#   my $chemical = shift @_;		#object
#   my $score;
#   my $counter = 0;
  
  #########begin here
  my $verbose = shift @_;		#scalar
  my @RDAT_files = @{shift(@_)};	#hashrefs, SHAPE-experiments
  my $chemical = shift @_;		#object, parameters of the probe
  my $score = 0;
  my $counter = 0;			#for progress display
  
  #check probing parameters
  &check_probe($chemical) or die "Invalid reactivity file (*.reac) given!\n";
  #inculde something that checks the validity of the probing parameters
  #
  
  
  #actual probing starts here
  foreach (@RDAT_files) {
    my %file = %{$_};
    my @structures = &stochastic_sampling($file{"SEQUENCE"}, 10000);
    my @structure_desc = &db2sd(@structures);
    
    $score = &get_score(\@structure_desc, $file{"PROBING_PROFILE"}, $chemical);
  
  #update console, show progress
  $counter++;
#   print $counter,"\n";
  print "\r",(($counter / $#RDAT_files)*100),"% done!";
  if ($counter == 5) {print $score,"\n"; exit}
  }
  return $score;
}


sub get_score {
    my ($structure_description, $data, $chemical) = @_; #$seq, $chemical) = @_;
    my $score = 0;
    my @experiment = @{$data};
    
    foreach my $str_desc (@{$structure_description}) {
    
      for ( my $i = 0; $i < scalar(@{$chemical->probe_reac()}); $i++ ) {
        my $prob_reac = ${$chemical->probe_reac()}[$i];
#         my $prob_seq = ${$chemical->probe_seq()}[$i];		don't need this
        my $prob_str = ${$chemical->probe_str()}[$i];
        my $prob_cut = ${$chemical->probe_cut()}[$i];
	my $probe_score = 0;

	$prob_cut =~ m/\|/;
	my $cut_pos = $-[0];
	
	#find matches
	my @structure_matches;
	while ($str_desc =~ /$prob_str/g){
	  push @structure_matches, $-[0]+$cut_pos;}	#array holding the start of each matches
	
	#calculate score
	foreach my $pos (@structure_matches) {
	  if ( defined($experiment[$pos]{"REACTIVITY"}) ) {
	    $score += (($experiment[$pos]{"REACTIVITY"} - $prob_reac) ** 2);}
	  else {
	    $score += ($prob_reac ** 2);}
	  $experiment[$pos]{"SEEN"} = 1;}
      }
      #evaluate positions which weren't matched
      for (my $i = 0; $i <= $#experiment; $i++) {
	if ( !$experiment[$i]{"SEEN"} ) {
	  $score += ($experiment[$i]{"REACTIVITY"} ** 2) if (defined( $experiment[$i]{"REACTIVITY"}) );}
	  
	else {
	  $experiment[$i]{"SEEN"} = 0;}	#erase memory for next experiment
	  
    }
    
    #missing: multiple matches
    $score /= scalar(@{$structure_description});
  }
  return $score;
}

# sub simulate_probing {
#     my ($structure_description, $data, $chemical) = @_; #$seq, $chemical) = @_;
#     my $score = 0;
#     my @experiment = @{$data};
#     
#     for ( my $i = 0; $i < scalar(@{$chemical->probe_reac()}); $i++ ) {
#         my $prob_reac = ${$chemical->probe_reac()}[$i];
#         my $prob_seq = ${$chemical->probe_seq()}[$i];
#         my $prob_str = ${$chemical->probe_str()}[$i];
#         my $prob_cut = ${$chemical->probe_cut()}[$i];
# 
#         # create regex from probing sequence
# #         $prob_seq =~ s/N/[ACGTU]/g;
# 
#         # create regex from probing structure
#         $prob_str =~ s/U/[HBIMn]/g;
#         $prob_str =~ s/n/U/g;
# 
#         foreach my $str_desc (@{$structure_description}) {
#             # Find the modification/cut point
#             $prob_cut =~ /\|/;
#             my $cut_pos = $-[0];
# 
# 
# #             my @seq_matches = &match_all_positions($prob_seq, $seq, $cut_pos);
#             my @str_matches = &match_all_positions($prob_str, $str_desc, $cut_pos);
# 
# 
#             if (scalar(@seq_matches) > scalar(@str_matches) ) {
#                 my $more_matches = join(",",@seq_matches);
#                 foreach (@str_matches) {
#                     ${probing_profile}[$_] += $prob_reac if ($more_matches =~ /,$_,/);#probing profile entfernen
#                 }
#             }
#             else {
#                  my $more_matches = join(",",@str_matches);
#                 foreach (@seq_matches) {
#                     ${probing_profile}[$_] += $prob_reac  if ($more_matches =~ /,$_,/);#probing profile entfernen
#                 }
#             }
# 
#     #        print(join("",@{$probing_profile})."\n");
#     #        print("$seq\n");
#         }
#     }
#     return $score;
# }

sub match_all_positions {
    my ($regex, $string, $cut_pos) = @_;
    my @ret;
    while ($string =~ /(?=$regex)/g) {
        push(@ret,  $-[0] + $cut_pos);
    }
    return @ret
}

sub stochastic_sampling {
    my ($seq, $sample_size) = @_;
    # compute partition function and pair pobabilities
    my $structure;
    $RNA::st_back = 1;
    my $gfe = RNA::pf_fold($seq, $structure);
    my @structures;

    for (my $i = 0; $i < $sample_size; $i++){
        push( @structures, RNA::pbacktrack($seq) );
    }

    return @structures;
}

sub db2sd {

my (@structures) = @_;
my @structure_description = ();
foreach (@structures) {
        
    my @db = split('', $_);
    my @dots = (-1);
    my @opening_br = (-1);

    # at first we expect every nucleotide to be unpaired "U"
    my @struc_dec = ("U") x length($_);

    # fill arrays with positions
    for (my $i = 0; $i < scalar(@db); $i++) {
        push(@dots, $i) if ( $db[$i] eq "." );
        push(@opening_br, $i) if ( $db[$i] eq "(" );

        # closing bracket found, so lets classify enclosed unpaired nucleotides
        # if there are any
        # if clause leads to errors, if @db contains substrings like "()"
        if ( $db[$i] eq ")" && $dots[$#dots] > $opening_br[$#opening_br] ) {

            # declare enclosing bracket positions
            my $op_br_pos = pop(@opening_br);
            my $cl_br_pos = $i;

            # Declare paired nucleotides
            $struc_dec[$op_br_pos] = "P";
            $struc_dec[$cl_br_pos] = "P";


            my @enclosed_dots = ();
            # count the number of stems enclosed by the unpaired nucleotides
            my $enclosed_stems = 0;

            # collect all enclosed nucleotides in @enclosed_dots
            while ( $dots[$#dots] > $op_br_pos ) {
                push(@enclosed_dots, pop(@dots));
                # stop if you reached the last enclosed nucleotide
                last if ($dots[$#dots] < $op_br_pos);
                # if found non-continous numbers we found an enclosed stem
                if ( $dots[$#dots]+1 < $enclosed_dots[$#enclosed_dots]) {
                    $enclosed_stems++;
                }
            }
#           print("Enclosed unpaired nucleotides: "                    .join(",", @enclosed_dots)."\n");

            # Hairpin or bulge detected
            if ( $enclosed_stems == 0 ) {
                # Hairpin detected if the enclosed dots reach from opening to
                # closing bracket
                if ($op_br_pos + 1 == $enclosed_dots[$#enclosed_dots] &&
                    $cl_br_pos - 1 == $enclosed_dots[0] ) {            
                    foreach (@enclosed_dots) { $struc_dec[$_] = "H" }
#                    print("Hairpin found.\n");
                }
                # bulge detected if the enclosed dots just touch one bracket
                elsif ( $op_br_pos + 1 == $enclosed_dots[$#enclosed_dots] ||
                        $cl_br_pos - 1 == $enclosed_dots[0] ) {
                    foreach (@enclosed_dots) { $struc_dec[$_] = "B" }
#                    print("Bulge found.\n");
                }
            }
            # Multi loop with two included stems or an interior loop detected
            elsif ( $enclosed_stems == 1 ) {
                # Interior loop detected if the enclosed dots reach from opening
                # to closing bracket
                if ($op_br_pos + 1 == $enclosed_dots[$#enclosed_dots] &&
                    $cl_br_pos - 1 == $enclosed_dots[0] ) {
                    foreach (@enclosed_dots) { $struc_dec[$_] = "I" }
#                    print("Interior loop found.\n");
                }
                # Multi loop with two stems detected if the enclosed dots just
                # touch one bracket
                elsif ( $op_br_pos + 1 == $enclosed_dots[$#enclosed_dots] ||
                        $cl_br_pos - 1 == $enclosed_dots[0] ) {
                    foreach (@enclosed_dots) { $struc_dec[$_] = "M" }
#                    print("Multi loop found.\n");
                }
            }
            # Multi loop detected if more than one stem is enclosed
            elsif( $enclosed_stems > 1 ) {
                    foreach (@enclosed_dots) { $struc_dec[$_] = "M" }
#                    print("Multi loop found.\n");
            }
        }
        # No enclosed unpaired nucleotides so lets declare the base pair
        elsif ( $db[$i] eq ")" ) {
            $struc_dec[$i] = "P";
            my $rel_open_br = pop(@opening_br);
            $struc_dec[$rel_open_br] = "P";
        }
    }
    my $str_desc = join("",@struc_dec);
#    print("$_\n$str_desc\n");
    push(@structure_description, join("",@struc_dec));	#original version
#     push(@structure_description, @struc_dec);
}
return @structure_description;
}

sub check_probe {
  
  my $chemical = shift @_;
  my $die = 0;
  
  for (my $i = 0; $i <= scalar(@{$chemical->probe_reac()}); $i++) {
    my $prob_reac = ${$chemical->probe_reac()}[$i];
    my $prob_seq = ${$chemical->probe_seq()}[$i];
    my $prob_str = ${$chemical->probe_str()}[$i];
    my $prob_cut = ${$chemical->probe_cut()}[$i];
  
    if (!defined $prob_reac){
      print "Probe reactivity missing!\n"; $die++}
    if (!defined $prob_seq){
      print "Probe sequence missing!\n"; $die++}
    if (!defined $prob_str){
      print "Probe structure missing!\n"; $die++}
    if (!defined $prob_cut){
      print "Probe cut point missing!\n"; $die++}
    if ( scalar(@{$chemical->probe_seq()})  !=  scalar(@{$chemical->probe_str()}) ) {
      print "Probe nucleotide Sequence has different size than its corresponding structure!\n"; $die++}
    if ( scalar(@{$chemical->probe_str()}) < scalar(@{$chemical->probe_str()}) ){
      print "Cut point lies outside of Sequence\n"; $die++;}
         
    if ($die > 0) {return}
    else {return 1}
  }
  
}
1;