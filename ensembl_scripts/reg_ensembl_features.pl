#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
This script obtains data for regulatory regions from ensembl regulatory build.
=head2 Usage

Usage: ./reg_ensembl_features.pl feature_type versionID species path2output chrom

=cut

#################################################################
# reg_ensembl_features.pl
#################################################################

use strict;

use Bio::EnsEMBL::Registry;

unless (@ARGV ==2 ) {
        die "\n\nUsage:\n ./reg_ensembl_features.pl path2output chrom\nPlease try again.\n\n\n";}

my $path2output = shift;
my $chrom = shift;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
);

my @db_adaptors = @{ $registry->get_all_DBAdaptors() };


print STDERR "Chrom = $chrom\n";
open (OUT, ">$path2output/chr$chrom"."_regulatory.gff" ) or die "Can't open $path2output/chr$chrom"."_regulatory.gff for writing";
	
my $slice_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Slice' );

# Obtain a slice covering the entire chromosome $chrom
my $slice = $slice_adaptor->fetch_by_region( 'chromosome', $chrom );

my $efg_db = $registry->get_DBAdaptor('Human','funcgen');
my $reg_feature_adaptor = $efg_db->get_RegulatoryFeatureAdaptor();
my @reg_features = @{$reg_feature_adaptor->fetch_all_by_Slice($slice)};

#The filter features by feature type and list coords

foreach my $prom_feat(@reg_features)
{
	my $strand = $prom_feat->strand();
	if ($strand == 1)
	{
		$strand = "+";
	}
	else
	{
		$strand = "-";
	}
	#Print bound regions of underlying features and core/anchor region
	printf OUT ("%s\t%s\tchr%s:%d-%d\t%d\t%d\t.\t%s\t.\tNCBI36; ensembl regulatory build; ensembl_features.pl\n", $chrom,$prom_feat->feature_type->name, $chrom, $prom_feat->bound_start, $prom_feat->bound_end, $prom_feat->start, $prom_feat->end, $strand);
	
}
close OUT;
