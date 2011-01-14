#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
related to anc_snp-selection.pl
=head2 Usage

Usage: ./cpg_snp_selection.pl path2fastadir path2snpfreqs path2validatedsnp path2output
 
=cut

use strict;
use Bio::SeqIO;

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./cpg_snp_selection.pl path2fastadir path2snpfreqs path2validatedsnp path2output\nPlease try again.\n\n\n";}

my $path2fastadir = shift;
my $path2snpfreqs = shift;
my $path2validatedsnp = shift;
my $path2output = shift;

my @chroms= (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,"X","Y");

my (%val,%freq);
open (IN, "$path2validatedsnp" ) or die "Can't open $path2validatedsnp for reading";
while (my $entry = <IN>)
{
        chomp($entry);
        my @elems = split/\t/,$entry;
        my $coords = $elems[1]."_".$elems[2];
        $val{$elems[0]} = $coords;
}
close IN;
open (IN, "$path2snpfreqs" ) or die "Can't open $path2snpfreqs for reading";
while (my $entry = <IN>)
{
        chomp($entry);
        my @elems = split/\t/,$entry;
        my $rs = "rs".$elems[0]; 
        if (exists $val{$rs})
        {
        	if ($elems[2] >= 100)
        	{
        		if ($elems[3] >= 0.05 && $elems[3] <=0.95)
        		{
        			my $info = $elems[2]."_".$elems[3];
        			$freq{$rs} = $info;
        		}
        	}
        }     
}
close IN;

# use bio::seqio to parse through fasta file
# only include class = 1 remove else 
#
foreach my $chrom (@chroms)
{
	open (OUT, ">$path2output/chr$chrom"."_val_cpg_snps.txt" ) or die "Can't open $path2output/$chrom"."_val_gpc_snps.txt for writing";
	my $file = Bio::SeqIO->new(-file => "$path2fastadir/rs_ch$chrom".".fas", -format => "FASTA");
	while (my $seq = $file->next_seq())
	{
		my $head = $seq->desc();
		$head =~m/rs=(\d*)\|pos=(\d*)\|.*class=(\d*)/;
		my $id = "rs".$1;
		my $pos = $2;
		my $class = $3;
		if (exists $freq{$id})
		{	
			if ($class == 1)
			{
				my $sequence_string = $seq->seq();
				my $snpseq = $seq->subseq($pos-1, $pos+1);
				$snpseq = uc($snpseq);
				# when looking for CpG
				if ($snpseq eq "CSG")
				# when looking for GpC
				#if ($snpseq eq "GSC")
				{
					next;
				}
				# if snp is an S, Y or M and followed by G, print info out to methylated snp file
				# when looking for CpG
				if ($snpseq =~m/[S|Y|M]G/ || $snpseq =~m/C[S|K|R]/)
				# when looking for GpC
				#if ($snpseq =~m/[S|K|R]C/ || $snpseq =~m/G[S|Y|M]/)
				{
					my @tmp = split/_/,$val{$id};
					my @tmpF = split/_/,$freq{$id};
					print OUT "$id\t$tmp[0]\t$tmp[1]\t$tmpF[0]\t$tmpF[1]\t$snpseq\n";
				}	
			}
		}
	}
	close OUT;
}



