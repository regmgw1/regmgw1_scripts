#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
parse maf_parser_cpg_count_v3.pl into format for use in AnaDMR.R
=head2 Usage

Usage: ./snp_feature_enrich.pl path2cpgsnpfeatmat path2gpcsnpfeatmat path2featlist

=cut

#################################################################
# snp_feature_enrich.pl - parse maf_parser_cpg_count_v3.pl into format for use in AnaDMR.R
#################################################################

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./snp_feature_enrich.pl path2cpgsnpfeatmat path2gpcsnpfeatmat path2featlist\nPlease try again.\n\n\n";}

my $path2cpg_mat = shift;
my $path2gpc_mat = shift;
my $path2features = shift;

my $feat_count = 0;
open (FEAT, "$path2features" ) or die "Can't open $path2features for reading";
while (my $feature = <FEAT>)
{
	chomp $feature;
	my $cpg_count = 0;
	my $gpc_count = 0;
	
	my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,"X","Y");
	foreach my $chrom (@chroms)
	{
		my $line_count = 0;
		open (IN, "$path2cpg_mat/human_primates_repeat_family_cpg_miss_chr$chrom".".txt" ) or die "Can't open $path2cpg_mat/human_snp_features_cpg_match_chr$chrom".".txt for reading";
		
		while (my $line = <IN>)
		{
			if ($line_count > 0)
			{
				chomp $line;
				my @elems = split/\t/,$line;
				if ($elems[$feat_count+3] > 0)
				{
					$cpg_count++;
				}
			}
			$line_count++;
		}
		close IN;
		$line_count = 0;
		open (IN, "$path2gpc_mat/human_primates_repeat_family_gpc_miss_chr$chrom".".txt" ) or die "Can't open $path2gpc_mat/human_snp_features_gpc_match_chr$chrom".".txt for reading";
		while (my $line = <IN>)
		{
			if ($line_count > 0)
			{
				chomp $line;
				my @elems = split/\t/,$line;
				if ($elems[$feat_count+3] > 0)
				{
					$gpc_count++;
				}
			}
			$line_count++;
		}
		close IN;
	}
	$feat_count++;
	my $total = $cpg_count + $gpc_count;
	print "$feature\t$cpg_count\t$total\n";
}
close FEAT;
	
	
