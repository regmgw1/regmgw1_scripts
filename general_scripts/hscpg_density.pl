#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Parse through cpg bed file, for each cpg count the number of cpgs 500bp downstream and 499bp upstream. Plus determine if each cpg has a cpg 10bp up and downstream.
Output cpg\tdensity count\t10up\t10down\n
=head2 Usage

Usage: ./hscpg_density.pl path2hscpg

=cut

#################################################################
# hscpg_density.pl
#################################################################

use strict;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./hscpg_density.pl path2h1c1o1 path2hscpgs path2output\nPlease try again.\n\n\n";}

my $path2h1c1o1 = shift;
my $path2hscpgs = shift;
my $path2output = shift;

my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,'X','Y');
#my @chroms = (1);

open (OUT, ">$path2output/filtered_h1c1o1_density.txt") or die "Can't open $path2output/h1c1o1_density.txt for writing";
open (HS, ">$path2output/filtered_hsCpG_density.txt") or die "Can't open $path2output/hscpg_density.txt for writing";
print OUT "Chrom\tC_pos\tDensity\tUpstream_10\tUpstream_9\tUpstream_8\tDownstream_8\tDownstream_9\tDownstream_10\n";
print HS "Chrom\tC_pos\tDensity\tUpstream_10\tUpstream_9\tUpstream_8\tDownstream_8\tDownstream_9\tDownstream_10\n";

foreach my $chrom (@chroms)
{
	print STDERR "chrom $chrom\n";
	my %hscpg;
	my @start = ();
	open (IN, "$path2h1c1o1" ) or die "Can't open $path2h1c1o1 for reading";
	while (my $line = <IN>)
	{
		chomp $line;
		my @elems = split/\t/,$line;
		if ($elems[0] eq $chrom)
		{
			push @start, $elems[1];
		}
	}
	close IN;
	open (IN, "$path2hscpgs" ) or die "Can't open $path2hscpgs for reading";
	while (my $line = <IN>)
	{
		chomp $line;
		my @elems = split/\t/,$line;
		if ($elems[0] eq $chrom)
		{
			$hscpg{$elems[1]} = 0;
		}
	}
	close IN;
	my $count = 0;
	foreach my $cpg (@start)
	{
		my $down = 1;
		my $up = 1;
		my $density = 1;
		my $state = 1;
		my $up_10 = 0;
		my $up_9 = 0;
		my $up_8 = 0;
		my $down_10 = 0;
		my $down_9 = 0;
		my $down_8 = 0;
		while ($state == 1)
		{
			if ($count - $up >= 0)
			{
				my $dist = $cpg - $start[$count - $up];
				if ($dist <500)
				{
					if ($dist == 8)
					{
						$up_8 = 1;
					}
					if ($dist == 9)
					{
						$up_9 = 1;
					}
					if ($dist == 10)
					{
						$up_10 = 1;
					}
					$density++;
				}
				else
				{
					$state = 0;
				}
			}
			else
			{
				$state = 0;
			}
			$up++;
		}
		$state = 1;
		while ($state == 1)
		{
			if ($count + $down <= $#start)
			{
				my $dist = $start[$count + $down] - $cpg;
				if ($dist <=500)
				{
					if ($dist == 8)
					{
						$down_8 = 1;
					}
					if ($dist == 9)
					{
						$down_9 = 1;
					}
					if ($dist == 10)
					{
						$down_10 = 1;
					}
					$density++;
				}
				else
				{
					$state = 0;
				}
			}
			else
			{
				$state = 0;
			}
			$down++;
		}
		$count++;
		print OUT "$chrom\t$cpg\t$density\t$up_10\t$up_9\t$up_8\t$down_8\t$down_9\t$down_10\n";
		if (exists $hscpg{$cpg})
		{
			print HS "$chrom\t$cpg\t$density\t$up_10\t$up_9\t$up_8\t$down_8\t$down_9\t$down_10\n";
		}
	}
}
close HS;
close OUT;
