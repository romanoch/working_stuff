package Modules::Refine_RDAT;

use strict;
use warnings;
use Data::Dumper;
use Carp;
use RNA;

#aufgaben: 	Erstellen von Probingprofilen aus den Probingdaten,
#		Normalisierung, Generierung von Sekundaerstrukturen, M&M-Modifikationen

#		Das Probingprofil enthaelt fuer jede Position die miteinander verknuepften Daten -
#		sprich, Sequenzposition, Base, Struktur, Beschreibung und Reaktivitaet

#todo:  predict secondary structure

# probing profile ist: array mit laenge der struktur, jedes element hat hash mit BASE, STRUCTURE, STRUCTURE_DES, REACTIVITY

my $verbose;

sub refine_main {
  
  $verbose = shift @_;
  my $rdatref = shift @_;
  my %self = %{$rdatref};
  my @RDAT_profile;
  
  my @SEQUENCE = split(//, $self{"SEQUENCE"});
  my @STRUCTURE = split (//, $self{"STRUCTURE"});
  my @STRUCTURE_DESC = &db2sd($self{"STRUCTURE"}); 
    $self{"STRUCTURE_DESC"} = join('', @STRUCTURE_DESC);
    $self{"STRUCTURE_DESC_SIMPLE"} = $self{"STRUCTURE_DESC"};	#simple structure description with just U and P
    $self{"STRUCTURE_DESC_SIMPLE"} =~ s/[HIBM]/U/g;
  my @STRUCTURE_DESC_SIMPLE = split (//, $self{"STRUCTURE_DESC_SIMPLE"});
  my @SEQPOS = @{$self{"SEQPOS"}};
  my @REACTIVITY = @{$self{"REACTIVITY"}};
  my @ANNOTATION_DATA = @{$self{"ANNOTATION_DATA"}};
  my $OFFSET = $self{"OFFSET"};
  
  # check data for errors
  if (scalar(@REACTIVITY) != scalar(@SEQPOS)) {
    print $self{"PATH"}," Experiment:", $self{"ID"}," has more/less probed residues than reactivities!\n" if ($verbose >= 1);
    return;
    }	
  elsif (scalar(@SEQUENCE) != scalar(@STRUCTURE)) {
    print $self{"PATH"}," Experiment:", $self{"ID"}," SEQ/STRU different!\n" if ($verbose >= 1);
    return;
    }
  elsif (scalar(@STRUCTURE) != scalar(@STRUCTURE_DESC)) {
    print $self{"PATH"}," Experiment:", $self{"ID"}," STRU_DESC/STRU different!\n" if ($verbose >= 1);
    }
    
  # fill with arrays containing sequence and structure
  for (my $pos = 0; $pos <= $#SEQUENCE; $pos++) { 
    $RDAT_profile[$pos] = { "BASE" => $SEQUENCE[$pos], 
			    "STRUCTURE" => $STRUCTURE[$pos],
			    "STRUCTURE_DESC" => $STRUCTURE_DESC[$pos],
			    "STRUCTURE_DESC_SIMPLE" => $STRUCTURE_DESC_SIMPLE[$pos]};
    }
  
  # insert reactivities if existing
  for (my $pos = 0; $pos <= $#SEQPOS; $pos++) {
    $RDAT_profile[&correct_offset($SEQPOS[$pos], $OFFSET)]{"REACTIVITY"} = $REACTIVITY[$pos];
    #missing: maybe fill empty reactivities with -1 ?
    }
    
  #correct sequence of mutate and map-data missing: also correct structure foreach since it can hold many annotations
  foreach (@ANNOTATION_DATA) {
    
    if ($_ !~ m/mutation/) {
      next;
      }
    else {
      @RDAT_profile = (&implement_mutation($_, \@RDAT_profile, $OFFSET)) or return;
      }
    }#soll self zureuckgeben damit keine information verloren geht
  
  $self{"PROBING_PROFILE"} = \@RDAT_profile;
  return \%self;
}

sub correct_offset { 
  my ($pos, $offset) = @_;
  
  if ($offset < 0) {
    return ($pos + abs($offset));
    }
  elsif ($offset >= 0) {
    return ($pos-$offset);  
    } 
}

sub implement_mutation {

  my $annotation = shift @_;
  my $ref = shift @_;
  my $OFFSET = shift @_;
  my @RDAT_profile = @{$ref};
    
  #einbau v. mutation im format BASE ZAHL BASE  
  if ($annotation =~ m/([A-Z])([0-9]+)([A-Z])/) {
       
    #kontrolle weil bei annotation data bzw mutationen beginnt .rdat bei 1 zu zaehlen, sonst i.d.R. bei 0
    if ($1 eq $RDAT_profile[&correct_offset($2-1, $OFFSET)]{"BASE"} || $1 eq "N") {
      $RDAT_profile[&correct_offset($2-1, $OFFSET)]{"BASE"} = $3;
      return @RDAT_profile;
      }
      #ein set von files soll immer nur auf eine art (pos oder pos-1) mutiert werden sonst entsteht mist
#     elsif ($1 eq $RDAT_profile[&correct_offset($2, $OFFSET)]{"BASE"} || $1 eq "N") {
#       $RDAT_profile[&correct_offset($2, $OFFSET)]{"BASE"} = $3; print "2\n";
#       return @RDAT_profile;
#       }
    else {
      print "Mutation Data and Sequence differ from each other\n" if ($verbose >= 1);
      return;
      }
  }
  
  #einbau v mutationen im format BASEN(ZAHL:ZAHL)BASEN  
  elsif ($annotation =~ m/([A-Z]+)\(([0-9]+)\W([0-9]+)\)([A-Z]+)/) {
    my @from = split //, $1;
    my @to = split //, $4;
    my $start_ID = $2;
    my $stop_ID = $3;    
    
    #kontrolle ob annotation stimmt + einbau der mutation
    my $pos = 0;
    if ($start_ID > $stop_ID) {
      print "Reversed order of mutations\n";
      }
      foreach (@from) {
	if ($_ eq $RDAT_profile[&correct_offset($2+$pos-1, $OFFSET)]{"BASE"} || $_ eq "N") {
	  $RDAT_profile[&correct_offset($2+$pos-1, $OFFSET)]{"BASE"} = $to[$pos];
	  }
	  #siehe oben, entweder nur pos oder pos-1
# 	elsif ( $_ eq $RDAT_profile[&correct_offset($2+$pos, $OFFSET)]{"BASE"} || $_ eq "N" ) {
# 	  $RDAT_profile[&correct_offset($2+$pos, $OFFSET)]{"BASE"} = $to[$pos];
# 	  }
	else {
	  print "Error while trying to implement Mutation Data (Annotation data doesn't match SEQUENCE)\n" if ($verbose >= 1);
	  print $annotation,"\n" if ($verbose >= 2);
	  return;
	  }
      }
      return @RDAT_profile;
  }
  
  elsif ( $annotation =~ m/mutation:WT/ ) {
    return @RDAT_profile;	#return unmodified data
    }
    
  else {
    print $annotation,"\n";
    print "Could not process annotation data!\n" if ( $verbose >= 1);
    return;
    }
    
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
    #push(@structure_description, join("",@struc_dec));	#original version
    push(@structure_description, @struc_dec);
}
return @structure_description;
}

1;