#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
measure batscore across cpg islands
=head2 Usage

Usage: ./cpg_island_bat_bin.pl path2data path2bat path2output chr
 
=cut

#################################################################
# cpg_island_bat_bin.pl 
#################################################################

use strict;
use Math::Round qw(:all);

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./cpg_island_bat_bin.pl path2data path2bat path2output chr\nPlease try again.\n\n\n";}

my $path2data = shift;
my $path2bat = shift;
my $path2output = shift;
my $chr = shift;

my (%batscores, %batstart, %bat_hash, %battrack);

open (OUT, ">$path2output/chr$chr"."_island_average.txt" ) or die "Can't open $path2output for writing";


open (BAT, "$path2bat" ) or die "Can't open $path2bat for reading";
while (my $batline = <BAT>)
{
	chomp $batline;
	my @elems = split/\t/, $batline;
	$bat_hash{$elems[3]} = $elems[5];

}
close BAT;

open (IN, "$path2data" ) or die "Can't open $path2data for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	my $start = $elems[3];
	my $stop = $elems[4];
	my $island_length = $stop - $start;
	$batstart{$start} = $island_length;
	$batscores{$start} = "$start - $stop";
	$battrack{$start} = "$start - $stop";
		
}

foreach my $pos (keys %batstart)
{
	my $increment = $batstart{$pos}/10;
	for (my $i = 0;$i<=10;$i++)
	{
		
		my $new_start = $pos + ($increment*$i);
		my $window_start = nearest(100, $new_start) + 1;
		if (exists $bat_hash{$window_start})
		{
			$batscores{$pos} = "$batscores{$pos}\t$bat_hash{$window_start}";
			$battrack{$pos} = "$battrack{$pos}\t$new_start($window_start)";
		}
		else
		{
			$batscores{$pos} = "$batscores{$pos}\t";
			$battrack{$pos} = "$battrack{$pos}\t";
		}
	}
	print OUT "$batscores{$pos}\n";
}
close OUT;
