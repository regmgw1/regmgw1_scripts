#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
This script obtains repeat annotation from ensembl for genomic regions listed in input file.
=head2 Usage

Usage: ./repeat_type_ensembl.pl path2dmrs path2list path2output

=cut

#################################################################
# repeat_type_ensembl.pl
#################################################################

use strict;

use Bio::EnsEMBL::Registry;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./repeat_type_ensembl.pl path2dmrs path2list path2output\nPlease try again.\n\n\n";}

my $path2dmrs = shift;
my $path2list = shift;
my $path2output = shift;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous',
    -db_version=> 52
);
die ("Can't initialise registry") if (!$registry);

my (%rep_hash,%type_hash,%dmr_type_hash);

my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22);

open (OUT, ">$path2output" ) or die "Can't open $path2output for writing";
open (LIST, ">$path2list" ) or die "Can't open $path2list for writing";

foreach my $chrom (@chroms)
{

open (IN, "$path2dmrs" ) or die "Can't open $path2dmrs for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	if ($elems[0] == $chrom)
	{
		$rep_hash{$elems[1]} = $elems[2];
	}
}
close IN;

print STDERR "Chrom = $chrom\n";

	
my $slice_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Slice' );

# Obtain a slice covering the entire chromosome $chrom
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
		if (exists $type_hash{$type})
		{
			$type_hash{$type} = $type_hash{$type} + 1;
		}
		else
		{
			$type_hash{$type} = 1;
			$dmr_type_hash{$type} = 0;
		}
		if (exists $rep_hash{$start} && $stop == $rep_hash{$start})
		{
			$dmr_type_hash{$type} = $dmr_type_hash{$type} + 1;
			print LIST "$class\t$type\t$chrom\t$start\t$stop\n";
		}
	}
}
}
foreach my $sat (keys %type_hash)
{
	print OUT "$sat\t$type_hash{$sat}\t$dmr_type_hash{$sat}\n";
}
close OUT;
close LIST;
