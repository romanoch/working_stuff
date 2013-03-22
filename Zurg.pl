

use strict;

my @allplayers = ["Woody","Buzz","Hamm","Rex"];
my %players = ( "Buzz",5,"Woody",10,"Hamm",20,"Rex",25);
my @players;


sub PERMUTATE {
	print "$allplayers[0] test\n";}

&PERMUTATE();
# Buzz abzwicken --> Permutationen Woody + Rest durchspielen (immer vorderstes Element
#des Array nach hinten verschieben (N-Ebene mal)
# Dann Woody abzwicken und wiederholen (...N-1-Ebene mal)
#Auf diese Art lassen sich alle Permutationen erstellen. Von diesen weg wird ähnlich
#verfahren. Der Weg wird gespeichert und evaluiert. (Kann in jedem Schritt passieren
#zwecks Ersparnis von Laufzeit.