#!/usr/bin/perl

##########################################################

#PERMUTATOR - GIVEN A SEQUENCE STORED IN AN ARRAY
#CREATES ALL POSSIBLE PERMUTATIONS AND STORES THEM

##########################################################

use strict;
use warnings;

my @players = ("wood","buzz","hamm","rex","rom","dummy");

PERMUTATE_L (@players);

#print "Array nach Subroutine: @players\n";





sub PERMUTATE_L {	# uebergang von links -> rechts. sprich N-i Teilnehmer links, davon gehen 2 nach rechts. fuehrt permutationen durh

	my @perm = @players;
	my $playersR = \@players;
	my @permutations;
		
	
	foreach(@players) {

		my $first = shift(@perm);

		foreach (@perm){
			print "$first + $_\n";
			push (@permutations, "$first|$_");
			}
		}
	print "@permutations\n";
	return print "routine executed \n\n\n";
	}




#sub PERMUTATE_R () {	# uebergang von rechts -> links, aus einer wachsenden anzahl geht einer zurueck
#	
#	foreach (@input_players){	
#		push (@array,$_);	
#		}
#	return print "permutate_R executed \n\n";
#	}



sub EVALUATE () {	# gibt die kosten der durchgefuehrten transition an. input: die beiden uebergaenger, kosten 
	
		
	
	
	}






















