package movement;

use strict;
use warnings;


#################################
#		SUBS		#
#################################

sub random_walk {
#just drives randomly around

  my ($mypos,	# Array (x,y)
      $myvec)	# Array (x,y)
      = @_;
  
  my @new_pos;
  $new_pos[0] = @{$mypos}[0] + @{$myvec}[0];
  $new_pos[1] = @{$mypos}[1] + @{$myvec}[1];
 
  my $rand = int(rand(10));

return &pos_after_movement(\@new_pos, $rand);
}


sub greedy_simple {
#drives towards the checkpoint, costs or obstacles don't matter

  my ($mypos,		# Array (x,y)
      $myvec,		# Array (x,y)
      $nextcheck,	# scalar
      $checkpoints)	# AoA (ID, x,y)
      = @_;
  
  my @new_pos;
  $new_pos[0] = @{$mypos}[0] + @{$myvec}[0];
  $new_pos[1] = @{$mypos}[1] + @{$myvec}[1];
  
  my @next_checkpoint = @{$checkpoints}[$nextcheck];	# [0]: ID, [1]: x, [2]: y
  my @next_positions;
  
  
  for (1..9) {
   push( @next_positions, &pos_after_movement (\$new_pos, $_));
  }
  
  foreach (@next_positions) {
  
    @{$_}
  
  }
  
      
      
return;      
}


sub greedy_refined {

}

#################################
#	AUXILLIARY SUBS		#
#################################

sub pos_after_movement {

#returns an array reference

# - # - # - #
# 7 # 8 # 9 #
# 4 # 5 # 6 #
# 1 # 2 # 3 #
# - # - # - #

#remember: coorsystem starts in the upper left corner of the map
  
  my ($pos, $cell) = @_;
  
  if ($cell == 1 || 2 || 3) {
    @{$pos}[1]++;	#increase y by 1
    
    if ($cell == 1) {
      @{$pos}[0]--;}
    elsif ($cell == 3) {
      @{$pos}[0]++;}
  
  }
  elsif ($cell == 4 || 5 || 6) {	#y stays the same, x changes
    if ($cell == 4) {
      @{$pos}[0]--;}	#decrease x by 1
      
    elsif ($cell == 6) {
      @{$pos}[0]++;}	#increase x by 1
  
  }
  elsif ($cell == 7 || 8 || 9) {
    @{$pos}[1]--;	#decrease y by 1
    
    if ($cell == 7) {
      @{$pos}[0]--;}	#decrease x
    elsif ($cell == 9) {
      @{$pos}[0]++;}	#increase x
  }

return $pos}  

sub calc_distance {

  my ($vec1, $vec2) = @_;

  
  
}


sub bresenham_algorithm {

}

 
1;