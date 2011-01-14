#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
read ancestral file "dbSNP_chr16.txt", split line and enter pos and allele into ancestral hashes ancestral file has format: rssnp;chrPos;refAllele;ancAllele;validation;loci remove if col 5 not = 1 (not validated)
=cut

use strict;
use Bio::SeqIO;

# anc_snp-selection_gw.pl

# read ancestral file "dbSNP_chr16.txt", split line and enter pos and allele into ancestral hashes
# ancestral file has format: rssnp;chrPos;refAllele;ancAllele;validation;loci
# remove if col 5 not = 1 (not validated)

my (%anc_alle, %chr_pos);
my $valid = 0;
my $invalid = 0;
open (IN, "dbSNP_chr16.txt" ) or die "Can't open dbSNP_chr16.txt for reading";
while (my $entry = <IN>)
{
        chomp($entry);
        my @elems = split/;/,$entry;
        if ($elems[4] == 1)
        {
                $anc_alle{$elems[0]} = uc($elems[3]);
        	$chr_pos{$elems[0]} = $elems[1];
        	$valid++;
        }
        else
        {
        	$invalid++;
        }
        
}
print "Validated = $valid\nNot validated = $invalid\n";
close IN;


# use bio::seqio to parse through fasta file
# only include class = 1 remove else 
#
open (OUT, ">methylated_snps" ) or die "Can't open methylated_snps for writing";
open (ANC, ">anc_non-methylated_snps" ) or die "Can't open anc_non-methylated_snps for writing";

my $file = Bio::SeqIO->new(-file => "rs_ch16.fas", -format => "FASTA");
while (my $seq = $file->next_seq())
{
	my $head = $seq->desc();
	$head =~m/rs=(\d*)\|pos=(\d*)\|.*class=(\d*)/;
	my $id = "rs".$1;
	my $pos = $2;
	my $class = $3;	
	if ($class == 1)
	{
		my $sequence_string = $seq->seq();
		my $snpseq = $seq->subseq($pos-1, $pos+1);
		$snpseq = uc($snpseq);
		if ($snpseq eq "CSG")
		{
			next;
		}
		# if snp is an S, Y or M and followed by G, print info out to methylated snp file
		if ($snpseq =~m/[S|Y|M]G/)
		{
			print OUT "$id;class=1;pos=$pos;$snpseq;$chr_pos{$id};$anc_alle{$id}\n";
			#check to make sure id exists in ancestral file
			if (exists $anc_alle{$id})
			{
				# if ancestral is A, T or G, print out to ancestral non-methylated file
				if ($anc_alle{$id} =~m/[A|T|G]/)
				{
					print ANC "$id;class=1;pos=$pos;$snpseq;$chr_pos{$id};$anc_alle{$id}\n";
				}
			}
			else
			{
				print STDERR "MISSING $id\n";
			}
		}
		elsif ($snpseq =~m/C[S|K|R]/)
		{
			# if snp is an S, K or R and preceeded by a C, print info out to methylated snp file
			print OUT "$id;class=1;pos=$pos;$snpseq;$chr_pos{$id};$anc_alle{$id}\n";
			if (exists $anc_alle{$id})
			{
				# if ancestral is A, T or C, print out to ancestral non-methylated file
				if ($anc_alle{$id} =~m/[A|T|C]/)
				{
					print ANC "$id;class=1;pos=$pos;$snpseq;$chr_pos{$id};$anc_alle{$id}\n";
				}
			}
			else
			{
				print STDERR "MISSING $id\n";
			}
		}
	}
}
close OUT;
close ANC;


