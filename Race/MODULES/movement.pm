package movement;

use strict;
use warnings;


#################################
#		SUBS		#
#################################

sub greedy_simple {

  my ($mypos,		# Array (x,y)
      $myvec,		# Array (x,y)
      $nextcheck,	# scalar
      $checkpoints)	# AoA (ID, x,y)
      = @_;

  my @next_checkpoint = @{$checkpoints}[$nextcheck];	# [0]: ID, [1]: x, [2]: y
  
      
      
      
      
}

sub greedy_refined {

}

1;