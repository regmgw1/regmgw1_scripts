#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Create CpG matrix, each row is a CpG, each column is a repeat type.
=head2 Usage

Usage: ./cpg_repeat_family_matrix_v2.pl path2repeats path2repeat_types_file path2cpgs path2output
 
=cut

#################################################################
# cpg_repeat_family_matrix.pl 
#################################################################
use strict;

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./cpg_repeat_family_matrix_v2.pl path2repeats path2repeat_types_file path2cpgs path2output\nPlease try again.\n\n\n";}

my $path2repeats = shift;
my $repeat_info_file = shift;
my $cpgs = shift;
my $path2output = shift;

my @repeats;
open (FEAT, "$repeat_info_file" ) or die "Can't open $repeat_info_file for reading";
while (my $line = <FEAT>)
{
	chomp $line;
	push @repeats, $line;
}
close FEAT;

my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,"X","Y");
foreach my $chrom (@chroms)
{
	print "chrom $chrom\n";
	open (OUT, ">$path2output/chr$chrom"."_cpg_repeat_family_matrix.txt") or die "Can't open $path2output/chr$chrom"."_cpg_repeat_family_matrix.txt for writing";
	print OUT "Chrom\tCpG_start\tCpG_stop";
	my %cpg;
	foreach my $rep_type (@repeats)
	{
		print OUT "\t$rep_type";
		open (CPG, "$cpgs/chr$chrom"."_cpgs.gff" ) or die "Can't open $cpgs/chr$chrom"."_cpgs.gff for reading";
		while (my $line = <CPG>)
		{
			chomp $line;
			my @elems = split /\t/,$line;
			my $begin = $elems[3];
			my $end = $elems[4];
			$cpg{$begin}{$rep_type} = 0;
		}
		close CPG;
	}	
	open (IN, "$path2repeats/chr$chrom"."_repeat.gff" ) or die "Can't open $path2repeats/chr$chrom"."_repeat.gff for reading";
	while (my $line = <IN>)
	{
		chomp $line;
		my @elems = split/\t/, $line;
		my $temp_fam = $elems[1];
		$temp_fam =~s/Repeat_//;
		my $family;
		if ($temp_fam =~m/(.*)\//)
		{
			$family = $1;
		}
		else
		{
			$family = $temp_fam;
		}
		my $state = 0;
		foreach my $fam (@repeats)
		{
			if ($fam eq $family)
			{
				$state = 1;
			}
		}
		if ($state == 0)
		{
			$family = "other";
		}
		my $begin = $elems[3];
		my $end = $elems[4];
		while ($begin <= $end)
		{
			if (exists $cpg{$begin})
			{
				$cpg{$begin}{$family}++;
			}
			$begin++;
		}
	}
	close IN;
	print OUT "\n";
	for my $cpgout (sort { $a <=> $b }(keys %cpg))
	{
		my $cpg_end = $cpgout + 1;
		print OUT "$chrom\t$cpgout\t$cpg_end";
		foreach my $repout (@repeats)
		{
			print OUT "\t$cpg{$cpgout}{$repout}";
		}
		print OUT "\n";
	}
	close OUT;
}
