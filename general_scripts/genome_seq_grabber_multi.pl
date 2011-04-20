#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
obtains the specified region of the given genome, output as fasta

=head2 Usage

Usage: ./genome_seq_grabber.pl path2genomefile header start_coord stop_coord path2output

=cut

#################################################################
# genome_seq_grabber.pl
#################################################################

use strict;
use Bio::SeqIO;

unless (@ARGV ==3 ) {
        die "\n\nUsage:\n ./genome_seq_grabber.pl path2genomeDir path2dmrFile path2output\nPlease try again.\n\n\n";}

my $path2genome = shift;
my $regionFile = shift;
my $path2output = shift;

my $count = 0;
open (IN, "$regionFile" ) or die "Can't open $regionFile for reading";
while (my $line = <IN>)
{
	if ($count > 0)
	{
		my @elems = split/\t/,$line;
		my $dmr = $elems[0];
		print "$dmr\n";
		$dmr =~m/(\w+):(\d+)-(\d+)/;
		my $genomeFile = "mm_ref_chr".$1.".fa";
		my $start = $2 - 100;
		my $stop = $3 + 100;
		my $seq_in = Bio::SeqIO->new(-format=>'fasta', -file=>"$path2genome/$genomeFile");
		my $seq = $seq_in->next_seq();
		my $subseq = $seq->subseq($start, $stop);
		open (OUT, ">$path2output/NPC_TDG--Hyper_$dmr".".fasta") or die "Can't open $path2output/NPC_TDG--Hyper_$dmr".".fasta for writing";
		print OUT ">$dmr\n";
		print OUT "$subseq";
		close OUT;
	}
	$count++;
}
close IN;
