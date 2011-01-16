#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Generate repeat junction sequences i.e merge end of repeat seq with start of repeat seq
=head2 Usage

Usage: ./junction_seq_grabber.pl path2genomefile path2output junct_threshold

=cut

#################################################################
# junction_seq_grabber.pl
#################################################################

use strict;
use Bio::SeqIO;
use Bio::EnsEMBL::Registry;

unless (@ARGV ==3 ) {
        die "\n\nUsage:\n ./junction_seq_grabber.pl path2genomefile path2output junct_threshold\nPlease try again.\n\n\n";}

my $path2genome = shift;
my $path2output = shift;
my $threshold = shift;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous',
    -db_version=> 52
);
die ("Can't initialise registry") if (!$registry);

my (%rep_hash,%type_hash,%dmr_type_hash);
my $h_count = 1;
my $seq_in = Bio::SeqIO->new(-format=>'fasta', -file=>"$path2genome");

my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22);
open (OUT, ">$path2output") or die "Can't open $path2output for writing";
foreach my $chrom (@chroms)
{
	my $seq = $seq_in->next_seq();
	my $slice_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Slice' );
	print "$chrom\n";
	my $slice = $slice_adaptor->fetch_by_region( 'chromosome', $chrom );

	my @repeats = @{ $slice->get_all_RepeatFeatures() };
	foreach my $repeat (@repeats)
	{
		my $start = $repeat->start();
		my $stop = $repeat->end();
		my $class = $repeat->repeat_consensus->repeat_class;
		my $type = $repeat->repeat_consensus->name;
		if ($class =~m/Satellite/ && $type =~m/ALR\/Alpha/)
		{
			if ($stop-$start >= $threshold * 2)
			{
				my $subseq2 = $seq->subseq($stop-$threshold,$stop);
				my $subseq1 = $seq->subseq($start,$start+$threshold);
				my $header = "$type"."_$chrom"."_$start"."_$stop";
				print OUT ">$h_count $header\n";
				print OUT "$subseq2$subseq1\n";
			}
			else
			{
				print "Too small!!!\n";
			}
			$h_count++;
		}
	}
}

close OUT;
