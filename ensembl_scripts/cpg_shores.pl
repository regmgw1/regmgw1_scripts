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
        die "\n\nUsage:\n ./cpg_shores.pl species path2islands path2output threshold (in bases) versionID\nPlease try again.\n\n\n";}

my $species = shift;
my $path2islands = shift;
my $path2output = shift;
my $threshold = shift;
my $version_id = shift;


my (%end_chrom_hash, $chrom_number, @chroms);

if ($species eq "mouse")
{
	%end_chrom_hash = (
        1 => '197195432',
        2 => '181748087',
        3 => '159599783',
        4 => '155630120',
        5 => '152537259',
        6 => '149517037',
        7 => '152524553',
        8 => '131738871',
        9 => '124076172',
        10 => '129993255',
        11 => '121843856',
        12 => '121257530',
        13 => '120284312',
        14 => '125194864',
        15 => '103494974',
        16 => '98319150',
        17 => '95272651',
        18 => '90772031',
        19 => '61342430',
        X => '166650296',
        Y => '15902555',      
	);
	$chrom_number = 19;
	@chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,'X','Y');

}
elsif ($species eq "human36")
{
	%end_chrom_hash = (
        1 => '247249719',
        2 => '242951149',
        3 => '199501827',
        4 => '191273063',
        5 => '180857866',
        6 => '170899992',
        7 => '158821424',
        8 => '146274826',
        9 => '140273252',
        10 => '135374737',
        11 => '134452384',
        12 => '132349534',
        13 => '114142980',
        14 => '106368585',
        15 => '100338915',
        16 => '88827254',
        17 => '78774742',
        18 => '76117153',
        19 => '63811651',
        20 => '62435964',
        21 => '46944323',
        22 => '49691432',
        X => '154913754',
        Y => '57772954',        
	);
	$chrom_number = 22;
	@chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,'X','Y');

}
elsif ($species eq "human37")
{
	%end_chrom_hash = (
        1 => '249250621',
        2 => '243199373',
        3 => '198022430',
        4 => '191154276',
        5 => '180915260',
        6 => '171115067',
        7 => '159138663',
        8 => '146364022',
        9 => '141213431',
        10 => '135534747',
        11 => '135006516',
        12 => '133851895',
        13 => '115169878',
        14 => '107349540',
        15 => '102531392',
        16 => '90354753',
        17 => '81195210',
        18 => '78077248',
        19 => '59128983',
        20 => '63025520',
        21 => '48129895',
        22 => '51304566',
        X => '155270560',
        Y => '59373566',        
	);
	$chrom_number = 22;
	@chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,'X','Y');

}

foreach my $chrom (@chroms)
{
	print "Chrom = $chrom\n";
	my %hash = ();
	open (OUT, ">$path2output/chr$chrom"."_shores_$threshold".".gff" ) or die "Can't open $path2output/chr$chrom"."_shores_$threshold".".gff for writing";
	open (IN, "$path2islands/chr$chrom"."_cpg_islands".".gff" ) or die "Can't open $path2output/chr$chrom"."_cpg_islands".".gff for reading";
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
		my $us_shore_end = $elems[4] + $threshold;
		if ($us_shore_end > $end_chrom_hash{$chrom})
		{
			$us_shore_end = $end_chrom_hash{$chrom};
		}
		print OUT "$elems[0]\tCpG_shore_down_$threshold\tchr$elems[0]".":$ds_shore_start"."-$ds_shore_end\t$ds_shore_start\t$ds_shore_end\t.\t.\t.\t$version_id; cpg_shores.pl\n";
		print OUT "$elems[0]\tCpG_shore_up_$threshold\tchr$elems[0]".":$us_shore_start"."-$us_shore_end\t$us_shore_start\t$us_shore_end\t.\t.\t.\t$version_id; cpg_shores.pl\n";

		
	}
	close IN;
	close OUT;
}
