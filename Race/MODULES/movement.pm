package movement;

use strict;
use warnings;
use Data::Dumper;

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

return &possible_positions(\@new_pos, $rand);
}


sub greedy_simple {
#drives towards the checkpoint, costs or obstacles don't matter....MUST WIN THE GAME

  my ($mypos,		# Array (x,y)
      $myvec,		# Array (x,y)
      $nextcheck,	# scalar
      $checkpoints)	# AoA (ID, x,y)
      = @_;
  
  my @new_pos;
  $new_pos[0] = @{$mypos}[0] + @{$myvec}[0];
  $new_pos[1] = @{$mypos}[1] + @{$myvec}[1];
  
  my $next_checkpoint = @{$checkpoints}[$nextcheck];	# [0]: ID, [1]: x, [2]: y
  shift @{$next_checkpoint}; #get rid of ID
  
  my %next_positions;
  my %dist_next_position;

  
  for my $i (1..9) {	#generate possible positions
    $next_positions{$i} = &possible_positions (\@new_pos, $i) ;
    $dist_next_position{$i} = &calc_distance ($next_positions{$i}, $next_checkpoint);
    }
    # this is not optimal and should be coded properly
  my $comp = 9999999999;
  my $ID;
  foreach (keys %dist_next_position) {	#take the closest position
    if ($dist_next_position{$_} < $comp) {
      $comp = $dist_next_position{$_};
      $ID = $_;
      }
    }  
      
return $next_positions{$ID};      
}


sub greedy_refined {

  my ($mypos,		# Array (x,y)
      $myvec,		# Array (x,y)
      $nextcheck,	# scalar
      $checkpoints,	# AoA (ID, x,y)
      $map)		# AoA (x,y)
      = @_;

      
      
      
}

#################################
#	AUXILLIARY SUBS		#
#################################

sub possible_positions {

#returns an array reference

# - # - # - #
# 7 # 8 # 9 #
# 4 # 5 # 6 #
# 1 # 2 # 3 #
# - # - # - #

#remember: coorsystem starts in the upper left corner of the map
  
  my $pos = shift @_;	# Array (x,y), the position where we are
  my $cell = shift @_;	# the adjacent (or middle) cell we want to go to 
  
  if ($cell == 1 || $cell == 2 || $cell == 3) {
    @{$pos}[1]++;	#increase y by 1
    
    if ($cell == 1) {
      @{$pos}[0]--;}
    elsif ($cell == 3) {
      @{$pos}[0]++;}
  
  }
  elsif ($cell == 4 || $cell == 5 || $cell == 6) {	#y stays the same, x changes
    if ($cell == 4) {
      @{$pos}[0]--;}	#decrease x by 1
      
    elsif ($cell == 6) {
      @{$pos}[0]++;}	#increase x by 1
  
  }
  elsif ($cell == 7 || $cell == 8 || $cell == 9) {
    @{$pos}[1]--;	#decrease y by 1
    
    if ($cell == 7) {
      @{$pos}[0]--;}	#decrease x
    elsif ($cell == 9) {
      @{$pos}[0]++;}	#increase x
  }

return $pos;		# (x,y)
}  

sub calc_distance {
  
  #simple pyhagoras
  my $coor1 = shift @_;
  my $coor2 = shift @_;
  
  my @coor1 = @{$coor1};
  my @coor2 = @{$coor2};
  my $distance;
  
  my @coor_diff;
  $coor_diff[0] = ($coor1[0] - $coor2[0]);	#x
  $coor_diff[1] = ($coor1[1] - $coor2[1]);	#y
  
  $coor_diff[0] **= 2;
  $coor_diff[1] **= 2;
  
  $distance = sqrt( $coor_diff[0] + $coor_diff[1]);

  return $distance;
}

sub bresenham {
  
  #returns the coordinates of the pixels which are covered by the vector
  my ($coor_start, $coor_end) = @_;
  my @pixels;
  
  my $dx = @{$coor_end}[0] - @{$coor_start}[0];
  my $dy = @{$coor_end}[1] - @{$coor_start}[1];
  my $error = ($dx/2);
  
  #initialize
  my $x = @{$coor_start}[0];
  my $y = @{$coor_start}[1];
  
  if ($dy > 0){	#positive steigung
    if ($dx > $dy) {
    
    while ($x < @{$coor_end}[0]) {
      
      $x++;
      push @pixels, [$x,$y];
      $error -= $dy;
            
      if ($error < 0) {
	$y++;
	push @pixels, [$x, $y];}
    }
  }
    elsif ($dy >= $dx) {
    while ($y < @{$coor_end}[1]) {
      $y++;
      push @pixels, [$x,$y];
      $error -= $dx;
            
      if ($error < 0) {
	$x++;
	push @pixels, [$x, $y];}
    }
  }
  }
  if ($dy <= 0) {	#negative steigung
    if ($dx > $dy) {
      
      while ($x > @{$coor_end}[0]) {
      
	$x--;
	push @pixels, [$x,$y];
	$error -= $dy;
            
	if ($error < 0) {
	  $y++;
	  push @pixels, [$x, $y];}
      }
    }
    elsif ($dy >= $dx) {
    
         while ($y < @{$coor_end}[0]) {
      
	$y++;
	push @pixels, [$x,$y];
	$error -= $dx;
            
	if ($error < 0) {
	  $x--;
	  push @pixels, [$x, $y];}
      }   
      
      }

  }

    
    
    
return \@pixels;
}
1;