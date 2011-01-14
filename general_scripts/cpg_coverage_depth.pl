#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Find depth of coverage at each CpG site.
=head2 Usage

Usage: ./cpg_coverage_depth.pl path2sgr path2cpgs path2output sample strand
 
=cut

#################################################################
# cpg_coverage_depth.pl
#################################################################

use strict;

unless (@ARGV ==5) {
        die "\n\nUsage:\n ./cpg_coverage_depth.pl path2sgr path2cpgs path2output sample strand\nPlease try again.\n\n\n";}

my $sgr = shift;
my $cpgs = shift;
my $path2output = shift;
my $sample = shift;
my $strand = shift;

open (OUT, ">>$path2output/$sample"."_cpg_depth_$strand".".txt") or die "Can't open $path2output for writing";

my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19);
my %read;
foreach my $chrom (@chroms)
{
	my $count = 0;
	my %cpg;
	open (CPG, "$cpgs/chr$chrom"."_cpgs.gff" ) or die "Can't open $cpgs/chr$chrom"."_cpgs.gff for reading";
	while (my $line = <CPG>)
	{
		chomp $line;
		my @elems = split /\t/,$line;
		my $begin = $elems[3];
		my $end = $elems[4];
		$cpg{$begin} = $end;
	}
	close CPG;
	open (IN, "$sgr/$sample"."_chr$chrom"."_sgr_$strand".".wig" ) or die "Can't open $sgr/$sample"."_chr$chrom"."_sgr.gff for reading";
	while (my $line = <IN>)
	{
		chomp $line;
		if ($count > 0)
		{
			my @elems = split /\t/,$line;
			my $begin = $elems[1];
			my $end = $elems[2];
			my $depth = $elems[3];
			if ($count == 1)
			{
				my $start = 0;
				while ($start < $begin)
				{
					if (exists $cpg{$start})
					{
						print OUT "$chrom\t$start\t$cpg{$start}\t0\n";
					}
					$start++;
				}	
			}	
			while ($begin <= $end)
			{
				if (exists $cpg{$begin})
				{
					print OUT "$chrom\t$begin\t$cpg{$begin}\t$depth\n";
				}
				$begin++;
			}
		}
		$count++;
	}
	close IN;
}
close OUT;
