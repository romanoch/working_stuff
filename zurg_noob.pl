#!/usr/local/bin/perl -w
#Flucht von Zurg, Roman Ochsenreiter

#Der Name Zurg_noob soll die ausgefeiltheit des Loesungsansatzes beschreiben
#Es werden nur beliebige (zufaellige) Kombinationen durchprobiert.
#Beim Erreichen eines vorher festgelegten Schwellenwertes werden sie ausgeschrieben

use strict;
use warnings;

our @players = ("a","b","c","d","e"); #Namen der N mitspieler eintragen
my %playersH;		#Namen der mitspieler mit ihren geschwindigkeiten

my @randv_lef;		#beinhaltet die Zufallsvariablen fuer jeden durchgang links ->rechts
my @randv_rig;		# rand variable rechts -> links

my $opt_score = 10;	#optimaler score, vom user festzulegen
my $score = 15;
my $num = @players;	#laenge des arrays

#my $count;		#anzahl der iterationen
#my $countmax=1000;	#maximale anzahl von iterationen

my $a;		#hilfsvariable


# Subroutine die die groessere von 2 input-zahlen widergibt
sub MAX {
	if (@_[0] >= @_[1]) {
		return @_[0];}
	else {return @_[1];}	
}

####### START DES PROGRAMMS #######

OUTER: while ($score >= $opt_score) {			#programm laeuft so lange bis momentane score besser als gewuenschte (keine garantie dass die auch jemals erreicht wird

	
	#Zufallsvariablen berechnen (N-2 Durchgaenge weil A) N-1 iterationen benoetigt werden und B) der letzte uebergang trivial ist (2 aus 2)
	#Die zufallswerte werden chronologisch angefuegt, sprich beim spaeteren durchrechnen muss immer nur der erste wert genommen werden
	
	INNER: for my $i(0..($num-3)) {		# bis N-3 weil die schleife von 0 anfaengt
		
		push(@randv_lef, int(rand(1)*($num-$i)));		#zufallsvar 1 (erster der ruebergeht), liefert wert 0 bis (N-(runde))
		
		do {
		$a = int(rand(1)*($num-$i));		# zufallsvar 2 (zweiter der ruebergeht), darf nicht == erster sein
		}while ($a == $randv_lef[-1]);

		push(@randv_lef, $a);
		}


	#generiert die zufallswerte fuer den uebergang rechts -> links	(auch N-2 mal)

	INNER2: for my $i(0..($num-3)) {					# bis N-3 weil die schleife von 0 anfaengt		
			push(@randv_rig, int(rand(1)*($i+2)));		#zufallsvar 2, derjenige der die taschenlampe zurueckbringt
			}

		print "Random variables right to left: @randv_rig\n";
		print "Random variables left to right: @randv_lef\n";


	#for (0..($num-3)) {	
	#	
	#	}

	








	last OUTER;
	}



sub CUT_OUT {		# parameter: array for cutting out, what to cut out. returns array where elements have been cut out: ARRAY(reference),ELEMENTS........
	
	my @input_array = @_[0];
	
	for () {
	}

	return 
};














