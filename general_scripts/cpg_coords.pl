#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Parse fasta file to find all regions matching the pattern
=head2 Usage

Usage: ./cpg_coords.pl path2seq path2output pattern(CG|GC)
 
=cut


#################################################################
# cpg_coords.pl
#################################################################

use strict;
use File::Basename;
use Bio::SeqIO;

unless (@ARGV ==3 ) {
        die "\n\nUsage:\n ./cpg_coords.pl path2seq path2output pattern(CG|GC)\nPlease try again.\n\n\n";}

my $path2seq = shift;
my $path2output = shift;
my $pattern = shift;

my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,'X','Y');
#my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,'X','Y');

foreach my $chrom (@chroms)
{
	print "Chrom$chrom\n";
	open (OUT, ">$path2output/chr$chrom"."_$pattern"."s.gff" ) or die "Can't open $path2output/chr$chrom"."_cpgs.gff for writing";
	#my $seq_in = Bio::SeqIO->new(-format=>'fasta', -file=>"$path2seq/mm_ref_chr$chrom".".fa");
	my $seq_in = Bio::SeqIO->new(-format=>'fasta', -file=>"$path2seq/hs_ref_GRCh37_chr$chrom".".fa");
	my $seq_ob = $seq_in->next_seq();
	my $seq = $seq_ob->seq();
	$pattern = uc($pattern);
	while ($seq =~/$pattern/g)
	{
		my $cg_start = $-[0] + 1;
		my $cg_stop = $+[0];
		print OUT "$chrom\t$pattern\tchr$chrom".":$cg_start-$cg_stop\t$cg_start\t$cg_stop\t.\t+\t.\thuman_GRCh37; cpg_coords.pl\n";
	}
	
	close OUT;
}
	
