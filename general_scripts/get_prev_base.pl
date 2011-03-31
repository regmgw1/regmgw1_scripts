#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Utilises bedTools to find overlaps between feature types and hscpgs at incrementally increasing cluster counts. Takes into account extra info about base preceeding hsCpG.
=head2 Usage

Usage: /get_prev_base.pl path2hscpgs path2genome

=cut

#################################################################
# get_prev_base.pl
#################################################################
use strict;
use Bio::SeqIO;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./get_prev_base.pl path2hscpgs path2genome\nPlease try again.\n\n\n";}

my $path2hscpgs = shift;
my $path2genome = shift;

my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,'X','Y');
#my @chroms = (22);
foreach my $chrom (@chroms)
{
	print STDERR "$chrom\n";
	my $seq_in = Bio::SeqIO->new(-format=>'fasta', -file=>"$path2genome/hs_ref_GRCh37_chr$chrom".".fa");
	my $seq_ob = $seq_in->next_seq();
	my $seq = $seq_ob->seq();
	my @seq = split '',$seq;
	open (CPGS, "$path2hscpgs" ) or die "Can't open $path2hscpgs for reading";
	while (my $cpg = <CPGS>)
	{
		my @elems = split/\t/,$cpg;
		if ($elems[0] eq $chrom)
		{
			my $prev = $elems[1] - 2;
			print "$elems[0]\t$elems[1]\t$elems[2]\t.\t$elems[4]\t$seq[$prev]\n";
		}
	}
	close CPGS;
}
