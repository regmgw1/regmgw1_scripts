#!/usr/bin/perl -w

use strict;
use warnings;
use Bio::EnsEMBL::Registry;
use IO::File;

unless (@ARGV ==4 ) {
        die "\n\nUsage:\n ./ensembl_features.pl versionID species path2output chrom\nPlease try again.\n\n\n";}

my $version_id = shift;
my $species = shift;
my $path2output = shift;
my $chrom = shift;

$species = lc($species);
if ($species ne "human")
{
	die "Segmentation data only available for Human! ...Please try again...\n";
}

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
    #The Registry automatically picks port 5306 for ensembl db
    #-verbose => 1, #specificy verbose to see exactly what it loaded
);
$registry->set_disconnect_when_inactive();

print STDERR "Chrom = $chrom\n";
#open (OUT, ">$path2output/chr$chrom"."_segmentation.gff" ) or die "Can't open $path2output/chr$chrom"."_segmentation.gff for writing";
	

#my $regfeat_adaptor = $registry->get_adaptor($species, 'funcgen', 'regulatoryfeature');
my $slice_adaptor = $registry->get_adaptor( $species, 'Core', 'Slice' );
# Obtain a slice covering the entire chromosome 22
my $slice = $slice_adaptor->fetch_by_region( 'chromosome', $chrom );

my $seg_adaptor = $registry->get_adaptor('Human', 'funcgen', 'segmentationfeature');
my @seg_feats = @{$seg_adaptor->fetch_all_by_Slice($slice)};
my %typeH;
foreach my $multi_seg (@seg_feats)
{
	my $info_ref = get_feature($multi_seg);
	my @info = @$info_ref;
	#print OUT "$info[0]_$info[1]_$info[2]_$info[3]\n";
	my ($cell, $state);
	if ($info[0] =~m/(\S+) - (\S+)/)
	{
		$cell = $2;
		$state = $1;
		if (exists $typeH{$cell})
		{
			my $fh = $typeH{$cell};
			print $fh "$info[1]\t$info[2]\t$info[3]\t$info[0]\n";
		}
		else
		{
			my $fh = new IO::File(">$path2output/$cell"."_chr$chrom"."_segmentation.bed") or die "can't write to file";
			$typeH{$cell} = $fh;
		}
	}
	else
	{
		print "$info[0] does not match!!!\n";
	}
}	

# close all output files
foreach my $fh (values (%typeH))
{
	close $fh;
}

#close OUT;

#Prints absolute coordinates and not relative to the slice
sub get_feature {
	my $feature = shift;
	my @info = ($feature->display_label,$feature->seq_region_name,$feature->seq_region_start,$feature->seq_region_end);
	return \@info;
}


