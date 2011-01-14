#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
take the 1.01 fake gap output and cluser to make discreet gaps, print coords to file
=head2 Usage

Usage: ./gap_cluster_v2.pl path2gaps path2output

=cut

#################################################################
# gap_cluster_v2.pl
# -take the 1.01 fake gap output and cluser to make discreet gaps, print coords to file
#################################################################

use strict;

unless (@ARGV ==2 ) {
        die "\n\nUsage:\n ./gap_cluster_v2.pl path2gaps path2output\nPlease try again.\n\n\n";}

my $path2gaps = shift;
my $path2output = shift;

my $count = 0;
my ($old_start,$gap_start, $old_stop, $old_chr, $old_file_code);

open (OUT, ">$path2output") or die "Can't open $path2output for writing";
open (IN, "$path2gaps" ) or die "Can't open $path2gaps for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	my $chr = $elems[0];
	my $start = $elems[1];
	my $stop = $start+99;
	my $file_code = $elems[2];
	if ($count > 0)
	{
		if ($start - 100 == $old_start)
		{
			$old_start = $start;
			$old_stop = $stop;
			next;
		}
		else
		{
			if ($old_stop - $gap_start > 100)
			{
				print OUT "$old_chr\t$gap_start\t$old_stop\t$old_file_code\n";
			}
			$gap_start = $start;
			$old_start = $start;
			$old_stop = $stop;
			$old_chr = $chr;
			$old_file_code = $file_code;
		}
	}
	else
	{
		$gap_start = $start;
		$old_start = $start;
		$old_stop = $stop;
		$old_chr = $chr;
		$old_file_code = $file_code;
	}
	$count++;
}
close IN;
close OUT;
