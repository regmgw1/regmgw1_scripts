#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
obtain repeat type when repeat is satellite
=head2 Usage

Usage: ./sat_type_ensembl2gff.pl path2output

=cut

#################################################################
# sat_type_ensembl2gff.pl
#################################################################

use strict;

use Bio::EnsEMBL::Registry;

unless (@ARGV ==1) {
        die "\n\nUsage:\n ./sat_type_ensembl2gff.pl path2output\nPlease try again.\n\n\n";}

my $path2output = shift;


# Connect to ensembl registry
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous',
    -db_version=> 52
);
die ("Can't initialise registry") if (!$registry);

my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22);
open (OUT, ">$path2output" ) or die "Can't open $path2output for writing";

# take each chromsome and print out the repeat type when repeat class matches Satellite
foreach my $chrom (@chroms)
{
	print STDERR "Chrom = $chrom\n";
	my $slice_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Slice' );
	# Obtain a slice covering the entire chromosome
	print "$chrom\n";
	my $slice = $slice_adaptor->fetch_by_region( 'chromosome', $chrom );

	my @repeats = @{ $slice->get_all_RepeatFeatures() };
	foreach my $repeat (@repeats)
	{
		my $start = $repeat->start();
		my $stop = $repeat->end();
		my $class = $repeat->repeat_consensus->repeat_class;
		my $type = $repeat->repeat_consensus->name;
		if ($class =~m/Satellite/)
		{
			print OUT "$chrom\t$type\tchr$chrom".":$start"."-$stop\t$start\t$stop\t.\t.\t.\tNCBI36:52\n";
		}
	}
}
close OUT;
