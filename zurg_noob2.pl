#!/usr/local/bin/perl -w

use strict;
use warnings;
use feature 'say';

my %playersH = ( a => 5, b => 10, c => 15, d => 20, e => 20, f => 25);		#Namen der mitspieler mit ihren geschwindigkeiten

our @players = keys %playersH;
my $num = @players;							#Anzahl Spieler (laenge des arrays)

my $score = 9999999;							#Startscore, Wert ist beliebig gewaehlt, soll nur hoch sein
my $optimal_score = 110;
our @memory;

my %state_lef = %playersH;
my %state_rig = %playersH;


OUTER:while($score > $optimal_score){					#suche laeuft so lange bis optimaler score erreicht wird

#initialisieren der states, 0/1 => anwesend/nicht anwesend
	foreach (keys %state_lef){
		$state_lef{$_} = 1}
		
	foreach (keys %state_rig){
		$state_rig{$_} = 0}

	@memory = ();	
	$score = 0;	

	for (1..($num-2)){					# N-2 zyklen (N..Spielerzahl) Anm.: Eigentlich sind es N-1 zyklen, doch die letzte Iteration ist der triviale Fall,
								# da nur noch 2 Spieler links vorhanden sind und beide hinuebergehen muessen.
		say "DEBUG1: $_";
		
		my @helpl = ();
		my @helpr = ();

		foreach (keys %state_lef){			# schreibt alle links anwesenden in ein array	
			if (($state_lef{$_}) == 1){		# 1-> ist hier
				push(@helpl,$_);}		#hilfsarray, nimmt alle leute auf die da sind
		}
		
		say "DEBUG3: @helpl";
								#Randomisierte Auswahl von 2 Personen die von links nach rechts gehen
		my $leng_l = @helpl;				#laenge des linken arrays
		
		my $rand1 = int(rand($leng_l));			# zufallsvar 1
		my $rand2;

		do {						# zufallsvar 2 != zufallsvar 1
		$rand2 = int(rand($leng_l));
		}while ($rand2 == $rand1);


		$state_lef{$helpl[$rand1]} = 0;			# person 1 links entfernen
		$state_lef{$helpl[$rand2]} = 0;			# person 2 links entfernen

		$state_rig{$helpl[$rand1]} = 1;			# person 1 rechts hinzufuegen
		$state_rig{$helpl[$rand2]} = 1;			# person 2 links hinzufuegen

		push (@memory, "left -> right: $helpl[$rand1]");	#"merken" v Person 1
		push (@memory, "and $helpl[$rand2]\n");			#"merken" v Person 2

		$score += &MAX ($playersH{$helpl[$rand1]}, $playersH{$helpl[$rand2]});	#evaluieren und dazuzaehlen



								#Randomisierte Auswahl von 1 Person, die von rechts nach links geht
		foreach (keys %state_rig){			# schreibt alle rechts anwesenden in ein array	
			if (($state_rig{$_}) == 1){		# 1-> ist hier
				push(@helpr,$_);}		#hilfsarray, nimmt alle leute auf die da sind
		}
		
		my $leng_r = @helpr;
		my $rand3 = int(rand($leng_r));
		
		$state_lef{$helpr[$rand3]} = 1;			# links hinzufuegen
		$state_rig{$helpr[$rand3]} = 0;			# rechts entfernen

		push (@memory, "back: $helpr[$rand3]\n");

		$score += $playersH{$helpr[$rand3]};
	}

	my @helpl = ();
	foreach (keys %state_lef){			# schreibt alle links anwesenden in ein array	
		if (($state_lef{$_}) == 1){		# 1-> ist hier
			push(@helpl,$_);}		#hilfsarray, nimmt alle leute auf die da sind
		}
	say "Last guys here: @helpl";

	$score += &MAX ($playersH{$helpl[0]}, $playersH{$helpl[1]});		# Die letzten beiden evaluieren
		
	push (@memory, "left -> right: $helpl[0]");
	push (@memory, "and $helpl[1]");
}
open (OUT, ">solution_zurg.txt");
print OUT "@memory \n";
print OUT "Score: $score\n";
close (OUT);

print "Program successfully exited.\n";

# gibt die groessere von 2 Zahlen wieder
sub MAX {
	if ($_[0] >= $_[1]) {
		return $_[0];}
	else {return $_[1];}	
	}

