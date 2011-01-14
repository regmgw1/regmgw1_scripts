#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Create CpG matrix, each row is a CpG, each column is a feature type.
=head2 Usage

Usage: ./cpg_feature_matrix_v2.pl path2featuresdir path2featureinfofile path2cpgs path2output
 
=cut

#################################################################
# cpg_feature_matrix_v2.pl 
#################################################################
use strict;

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./cpg_feature_matrix_v2.pl path2featuresdir path2featureinfofile path2cpgs path2output\nPlease try again.\n\n\n";}

my $path2features = shift;
my $feature_info_file = shift;
my $cpgs = shift;
my $path2output = shift;

my @features;
open (FEAT, "$feature_info_file" ) or die "Can't open $feature_info_file for reading";
while (my $line = <FEAT>)
{
	chomp $line;
	push @features, $line;
}
close FEAT;
my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,"X","Y");
foreach my $chrom (@chroms)
{
	print "chrom $chrom\n";
	open (OUT, ">$path2output/chr$chrom"."_cpg_renlab_matrix.txt") or die "Can't open $path2output/chr$chrom"."_cpg_feature_matrix.txt for writing";
	print OUT "Chrom\tCpG_start\tCpG_stop";
	my %cpg;
	foreach my $feature (@features)
	{
		print OUT "\t$feature";
		open (CPG, "$cpgs/chr$chrom"."_cpgs.gff" ) or die "Can't open $cpgs/chr$chrom"."_cpgs.gff for reading";
		while (my $line = <CPG>)
		{
			chomp $line;
			my @elems = split /\t/,$line;
			my $begin = $elems[3];
			my $end = $elems[4];
			$cpg{$begin}{$feature} = 0;
		}
		close CPG;
		open (IN, "$path2features/$feature/chr$chrom"."_$feature".".gff" ) or die "Can't open $path2features/$feature/chr$chrom"."_$feature".".gff for reading";
		while (my $line = <IN>)
		{
			chomp $line;
			my @elems = split /\t/,$line;
			my $begin = $elems[3];
			my $end = $elems[4];
			while ($begin <= $end)
			{
				if (exists $cpg{$begin})
				{
					$cpg{$begin}{$feature}++;
				}
				$begin++;
			}
		
		}
		close IN;
	}
	print OUT "\n";
	for my $cpgout (sort { $a <=> $b }(keys %cpg))
	{
		my $cpg_end = $cpgout + 1;
		print OUT "$chrom\t$cpgout\t$cpg_end";
		foreach my $featout (@features)
		{
			print OUT "\t$cpg{$cpgout}{$featout}";
		}
		print OUT "\n";
	}
	close OUT;
}

