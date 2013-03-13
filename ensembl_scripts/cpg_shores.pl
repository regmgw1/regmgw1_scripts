#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
This script generates cpg_shore annotation files from cpg_island gff files
=head2 Usage

Usage: ./cpg_shores.pl species path2islands path2output threshold (in bases) versionID

=cut

#################################################################
# cpg_shores.pl
#################################################################

use strict;

unless (@ARGV ==5) {
        die "\n\nUsage:\n ./cpg_shores.pl path2chromList path2islands path2output threshold (in bases) versionID\nPlease try again.\n\n\n";}

my $path2chrom = shift;
my $path2islands = shift;
my $path2output = shift;
my $threshold = shift;
my $version_id = shift;

print "path2islands = $path2islands\npath2output = $path2output\n";

my %end_chrom_hash;

open (IN, "$path2chrom" ) or die "Can't open $path2chrom for reading";
while (my $line = <IN>)
{
	chomp $line;	
	my @elems=split/\t/, $line;
	$end_chrom_hash{$elems[0]} = $elems[1];
}

foreach my $chrom (keys %end_chrom_hash)
{
	print "Chrom = $chrom\n";
	my %hash = ();
	open (OUT, ">$path2output/chr$chrom"."_cpg_shores_$threshold".".gff" ) or die "Can't open $path2output/chr$chrom"."_cpg_shores_$threshold".".gff for writing";
	open (IN, "$path2islands/chr$chrom"."_cpg_islands".".gff" ) or die "Can't open $path2output/chr$chrom"."_cpg_islands".".gff for reading";
	#open (IN, "$path2islands/chr$chrom"."_hsCpG-hsGpC_t5_GRCh37_58_cpg_island".".txt" ) or die "Can't open $path2islands/chr$chrom"."_hsCpG-hsGpC_t5_GRCh37_58_cpg_island".".gff for reading";
	while (my $line = <IN>)
	{
		my @elems=split/\t/, $line;
		my $ds_shore_start = $elems[3] - $threshold;
		my $ds_shore_end = $elems[3] - 1;
		if ($ds_shore_start < 0)
		{
			$ds_shore_start = 0;
		}
		my $us_shore_start = $elems[4] + 1;
		my $us_shore_end;
		# check for discrepancies between genome assemblies
		if ($us_shore_start >= $end_chrom_hash{$chrom})
		{
			next;
		}
		else
		{
			$us_shore_end = $elems[4] + $threshold;
			if ($us_shore_end > $end_chrom_hash{$chrom})
			{
				$us_shore_end = $end_chrom_hash{$chrom};
			}
		}
		print OUT "$elems[0]\tCpG_shore_down_$threshold\tchr$elems[0]".":$ds_shore_start"."-$ds_shore_end\t$ds_shore_start\t$ds_shore_end\t.\t.\t.\t$version_id; cpg_shores.pl\n";
		print OUT "$elems[0]\tCpG_shore_up_$threshold\tchr$elems[0]".":$us_shore_start"."-$us_shore_end\t$us_shore_start\t$us_shore_end\t.\t.\t.\t$version_id; cpg_shores.pl\n";

		
	}
	close IN;
	close OUT;
}
