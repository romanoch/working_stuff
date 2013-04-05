#!/usr/local/bin/perl -w
#Flucht von Zurg, Roman Ochsenreiter

#Der Name Zurg_noob soll die ausgefeiltheit des Loesungsansatzes beschreiben
#Es werden nur beliebige (zufaellige) Kombinationen durchprobiert.
#Beim Erreichen eines vorher festgelegten Schwellenwertes werden sie ausgeschrieben

use strict;
use warnings;

our @players = ("a","b","c","d","e"); #Namen der N mitspieler eintragen
my %playersH = ( a => 5, b => 10, c => 15, d => 20, e => 25);		#Namen der mitspieler mit ihren geschwindigkeiten

my @randv_lef;		#beinhaltet die Zufallsvariablen fuer jeden durchgang links ->rechts
my @randv_rig;		# rand variable rechts -> links

my $opt_score = 10;	#optimaler score, vom user festzulegen
my $score = 9999;	#startscore
my $num = @players;	#laenge des arrays

my @helpl;		#hilfsarray, nimmt leute auf die links da sind
my @helpr;		#hilfsarray, nimmt leute auf die rechts da sind

#my $count;		#anzahl der iterationen
#my $countmax=1000;	#maximale anzahl von iterationen

my $a;		#hilfsvariable




# Subroutine die die groessere von 2 input-zahlen widergibt
sub MAX {
	if ($_[0] >= $_[1]) {
		return $_[0];}
	else {return $_[1];}	
}


####### START DES PROGRAMMS #######

OUTER: while ($score >= $opt_score) {			#programm laeuft so lange bis momentane score besser als gewuenschte (keine garantie dass die auch jemals erreicht wird

	
	#Zufallsvariablen berechnen (N-2 Durchgaenge weil A) N-1 iterationen benoetigt werden und B) der letzte uebergang trivial ist (2 aus 2)
	#Die zufallswerte werden chronologisch angefuegt, sprich beim spaeteren durchrechnen muss immer nur der erste wert genommen werden
	
	INNER: for my $i(0..($num-3)) {					# bis N-3 weil die schleife von 0 anfaengt
		
		push(@randv_lef, int(rand(1)*($num-$i)));		#zufallsvar 1 (erster der ruebergeht), liefert wert 0 bis (N-(runde))
		
		do {
		$a = int(rand(1)*($num-$i));				# zufallsvar 2 (zweiter der ruebergeht), darf nicht == erster sein
		}while ($a == $randv_lef[-1]);

		push(@randv_lef, $a);
		}


	#generiert die zufallswerte fuer den uebergang rechts -> links	(auch N-2 mal)

	INNER2: for my $i(0..($num-3)) {					# bis N-3 weil die schleife von 0 anfaengt		
			push(@randv_rig, int(rand(1)*($i+2)));		#zufallsvar 2, derjenige der die taschenlampe zurueckbringt
			}

		#print "Random variables right to left: @randv_rig\n";
		#print "Random variables left to right: @randv_lef\n";



	#initialisieren der states, 0/1 => anwesend/nicht anwesend
	my %state_lef = (a=>1,b=>1,c=>1,d=>1,e=>1);	
	my %state_rig = (a=>0,b=>0,c=>0,d=>0,e=>0);
	

	#zaehlvariable
	my $i2 = -1;
	my $i3 = -1;

	############################################################################################
	########			start programm						####
	############################################################################################

	$score = 0;

	for (0..($num-3)) {

	@helpl = ();
	@helpr = ();
	
		foreach (keys %state_lef){			# schreibt alle links anwesenden in ein array	
			if (($state_lef{$_}) == 1){		# 1-> ist hier
				push(@helpl,$_);}		#hilfsarray, nimmt alle leute auf die da sind
		}
	
	$i2++;							#variable i2 dient dazu auf das array mit den zufallszahlen zuzugreifen
	$state_lef{$helpl[$randv_lef[$i2]]} = 0;		#person links geht (auf 0 gesetzt)
	$state_rig{$helpl[$randv_lef[$i2]]} = 1;		#person kommt rechts an (auf 1)
	#push (@helpr,$helpl[$randv_lef[$i2]]);			#gegangene person wird in hilfsarray eingetragen (fuer rechts)

	#$score =  ($score + &MAX ($playersH{$helpl[$randv_lef[$i2]]}, $playersH{$helpl[$randv_lef[($i2+1)]]}));

	$i2++;							#wie oben
	$state_lef{$helpl[$randv_lef[$i2]]} = 0;		#wie oben
	$state_rig{$helpl[$randv_lef[$i2]]} = 1;		#wie oben
	#push (@helpr,$helpl[$randv_lef[$i2]]);


	# nun wurden im hash links 2 personen entfernt (auf 0 gesetzt) und in den rechten hash auf 1 gesetzt (sie "sind da")
	#fuer das zurueckgehen muss eine person ausgewaehlt werden

		foreach (keys %state_rig){			# schreibt alle rechts anwesenden in ein array
		
			if (($state_lef{$_}) == 1){		# 1-> ist hier
				push(@helpr,$_);}		#hilfsarray, nimmt alle leute auf die da sind
		}

	#zurueckgehen: 

	$i3++;
	$state_rig{$helpr[$randv_rig[$i3]]} = 0;
	$state_lef{$helpr[$randv_rig[$i3]]} = 1;


	print "Nach Durchgang $i2 links: @helpl \n";
	print "Nach Durchgang $i2 rechts: @helpr \n";
	print $score."\n";
	
	}	
print "stechus kaktus \n";
last OUTER;}
