#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Parse through cpg bed file, for each cpg determine if density is >= to given threshold, if so start peak (-499). peak continues until find cpg with value < threshold at which point go back to previous cpg+500 to end peak.
=head2 Usage

Usage: ./hscpg_peak_former.pl path2hscpgs threshold

=cut

#################################################################
# hscpg_peak_former.pl
#################################################################

use strict;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./hscpg_peak_former.pl path2hscpgs threshold\nPlease try again.\n\n\n";}

my $path2hscpgs = shift;
my $threshold = shift;

my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,'X','Y');

foreach my $chrom (@chroms)
{
	print STDERR "chrom $chrom\n";
	my $state = 0;
	my $order_check = 0;
	my ($start,$prev,$max);
	open (IN, "$path2hscpgs" ) or die "Can't open $path2hscpgs for reading";
	while (my $line = <IN>)
	{
		chomp $line;
		my @elems = split/\t/,$line;
		if ($elems[0] eq $chrom)
		{
			if ($elems[1] < $order_check)
			{
				die "$order_check greater than $elems[1]\n";
			}
			$order_check = $elems[1];
			if ($state == 0)
			{
				if ($elems[4] >= $threshold)
				{
					$start = $elems[1] - 499;
					$prev = $elems[1] + 500;
					$max = $elems[4];
					$state = 1;
				}
			}
			if ($state == 1)
			{
				if ($elems[4] >= $threshold)
				{
					$prev = $elems[1] + 500;
					if ($elems[4] > $max)
					{
						$max = $elems[4];
					}
				}
				else
				{
					print "chr$chrom\t$start\t$prev\t.\t$max\t.\n";
					$state = 0;
				}
			}
		}
	}
	close IN;
}
