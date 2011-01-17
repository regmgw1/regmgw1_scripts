#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Attempts to find DMRs from pippy output using t-test and BH correction.
=head2 Usage

Usage: ./pippy_dmrs_v3.pl path2subject_file path2other_file path2output chr distance_threshold score_difference_threshold

=cut

#################################################################
# pippy_dmrs.pl
#################################################################

use strict;
use Statistics::TTest;
use Statistics::Test::WilcoxonRankSum;
use List::Util qw[ min ];

unless (@ARGV ==6) {
        die "\n\nUsage:\n ./pippy_dmrs.pl path2subject_file path2other_file path2output chr distance_threshold score_difference_threshold\nPlease try again.\n\n\n";}

my $subject_file = shift;
my $other_file = shift;
my $path2output = shift;
my $chr = shift;
my $thresh_distance = shift;
my $thresh_diff = shift;

my (%subject, %other, $type,%string_hash,%t_hash,%wt_hash, %type_hash,%cpg_store);

my $ttest = new Statistics::TTest;  
my $wilcox_test = Statistics::Test::WilcoxonRankSum->new();

open (IN, "$subject_file" ) or die "Can't open $subject_file for reading";
while (my $entry = <IN>)
{
        chomp($entry);
        my @elems = split/\t/,$entry;
        $subject{$elems[3]} = $elems[5];
}
close IN;

open (IN, "$other_file" ) or die "Can't open $other_file for reading";
while (my $entry = <IN>)
{
        chomp($entry);
        my @elems = split/\t/,$entry;
        $other{$elems[3]} = $elems[5];
}
close IN;

open (OUT, ">$path2output") or die "Can't open $path2output for writing";

my $cpg_in_count = 0;
my $found = 0;
my @temp;
my (@x,@y);
my $begin = 0;
my ($prev_pos,$prev_type);

for my $cpg (sort { $a <=> $b }(keys %subject))
{
	my $diff = $subject{$cpg} - $other{$cpg};
	if ($diff >= 0)
	{
		$type = 1;
	}
	else
	{
		$type = 0;
	}
	my $ab_diff = abs($diff);
	if ($ab_diff >=$thresh_diff)
	{
		my $distance = 0;
		if ($begin == 0)
		{
			$begin = 1;
			$prev_type = $type;
		}
		else
		{
			$distance = $cpg - $prev_pos;
		}
		if ($distance <= $thresh_distance && $type == $prev_type)
		{ 
			push @temp, $cpg;
			$cpg_in_count++;
		}
		else
		{
			# parse through temp array,
			if ($#temp > 1)
			{ 
				my $first = 0;
				my $last = 0;
				foreach my $entry (@temp)
				{
					
			
					if ($first == 0)
					{
						$first = $entry;
						push @x, $subject{$entry};
						push @y, $other{$entry};
					}
					else
					{
						push @x, $subject{$entry};
						push @y, $other{$entry};
					}
					$last = $entry;
				}
				$ttest->set_significance(90);
				$ttest->load_data(\@x,\@y);
				my $pval = $ttest->t_prob();
				$wilcox_test->load_data(\@x,\@y);
   				my $wt_prob = $wilcox_test->probability();
				my $dmr_length = $last - $first;
				$string_hash{$first} = "$first\t$last\t$dmr_length\t$cpg_in_count\t$type\t$pval\t$wt_prob";
				$t_hash{$first} = $pval;
				$wt_hash{$first} = $wt_prob;
				$cpg_store{$first} = [];
				foreach my $temp (@temp)
				{
					push @{$cpg_store{$first}}, $temp;
				}
				$type_hash{$first} = $type;
			}
			@temp =();
			@x=();
			@y=();
			$cpg_in_count = 0;
		}
		$found = 1;
	}
	else
	{
		if ($found == 1)
		{
			# parse through temp array, 
			if ($#temp > 1)
			{ 
				my $first = 0;
				my $last = 0;
				foreach my $entry (@temp)
				{
					if ($first == 0)
					{
						$first = $entry;
						push @x, $subject{$entry};
						push @y, $other{$entry};
					}
					else
					{
						push @x, $subject{$entry};
						push @y, $other{$entry};
					}
					$last = $entry;
				}
				$ttest->set_significance(90);
				$ttest->load_data(\@x,\@y);  
				my $pval = $ttest->t_prob();
				$wilcox_test->load_data(\@x,\@y);
   				my $wt_prob = $wilcox_test->probability();
				my $dmr_length = $last - $first;
				$string_hash{$first} = "$first\t$last\t$dmr_length\t$cpg_in_count\t$type\t$pval\t$wt_prob";
				$t_hash{$first} = $pval;
				$wt_hash{$first} = $wt_prob;
				$cpg_store{$first} = [];
				foreach my $temp (@temp)
				{
					push @{$cpg_store{$first}}, $temp;
				}
				$type_hash{$first} = $type;
			}
			@temp =();
			@x=();
			@y=();
			$cpg_in_count = 0;
		}
		$found = 0;
	}
		
	$prev_pos = $cpg;
	$prev_type = $type;
}	

my $corrected_t = bh_correction(\%t_hash);
my %corrected_t = %$corrected_t;
my $corrected_w = bh_correction(\%wt_hash);
my %corrected_w = %$corrected_w;

foreach my $key (sort { $a <=> $b }(keys %string_hash))
{
	if ($corrected_w{$key} <= 0.05)
	{
		print "$string_hash{$key}\t$corrected_t{$key}\t$corrected_w{$key}\n";
		my @entries = @{$cpg_store{$key}};
		foreach my $entry (@entries)
		{
			print OUT "$entry\t$corrected_t{$key}\t$corrected_w{$key}\t$type_hash{$key}\n";
		}
	}
}
close OUT;
sub bh_correction
{
	my $pval_ref = shift;
	my %pvalues = %$pval_ref;
	
	my @orderedKeys = sort {
	    $pvalues{ $b } <=> $pvalues{ $a }
	} keys %pvalues;

	my $d = my $n = values %pvalues;

	$pvalues{ $_ } *= $n / $d-- for @orderedKeys;

	$pvalues{ $orderedKeys[ $_ ] } =
	    min( @pvalues{ @orderedKeys[ 0 .. $_ ] } )
	    for 1 .. $n-1;

	$pvalues{ $_ } = min( $pvalues{ $_ }, 1 ) for keys %pvalues;

	return \%pvalues;	
}
