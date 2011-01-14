#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
combines output from feature_base_coverage output
=head2 Usage

Usage: ./feature_coverage_combine.pl path2files

=cut

#################################################################
# feature_coverage_combine.pl
# calculate values for whole genome from chrom files
#################################################################

use strict;

unless (@ARGV ==1 ) {
        die "\n\nUsage:\n ./feature_coverage_combine.pl path2files\nPlease try again.\n\n\n";}

my $path2files = shift;

my $total_feature_count = 15;

my @files = <$path2files/*feature_coverage*chr*txt>;
my $count = 1;

while ($count <= $total_feature_count)
{
	my $total_cpg = 0;
	my $total_uncovered = 0;
	my $feature;
	foreach my $file (@files)
	{
		my $line_count = 0;
		open (IN, "$file" ) or die "Can't open $file for reading";
		while (my $line = <IN>)
		{
			if ($line_count == $count)
			{
				my @elems = split/\t/, $line;
				$total_cpg += $elems[2];
				$total_uncovered += $elems[3];
				$feature = $elems[1];
			}
			$line_count++;
		}
		close IN;
	}
	my $covered = $total_cpg - $total_uncovered;
	my $percent = $covered/$total_cpg * 100;
	print "$feature\t$total_cpg\t$covered\t$total_uncovered\t$percent\n";
	$count++;
}
				
