#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Count number of blocks, bases, and patterns in maf files
=head2 Usage

Usage: ./maf_parser_summary_counts.pl path2maf chrom pattern (e.g. cg) path2output

=cut

#################################################################
# maf_parser_summary_counts.pl 
#################################################################

use lib '/home/rmgzgwi/perl_modules/lib/perl5/site_perl/5.8.5/';
use Bio::AlignIO;
use strict;

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./maf_parser_summary_counts.pl path2maf chrom pattern (e.g. cg) path2output\nPlease try again.\n\n\n";}

my $path2input = shift;
my $chrom = shift;
my $pattern = shift;
my $path2output = shift;

my $total = 0;
my $total_gaps = 0;
my $block = 0;
my $block1 = 0;
my $block2 = 0;
my $block3 = 0;
my $fullset = 0;
my $sub1 = 0;
my $sub2 = 0;
my $sub3 = 0;
my $cpg_count = 0;
my $cpg1 = 0;
my $cpg2 = 0;
my $cpg3 = 0;

my %chrom_maf = (1=>8,2=>7,3=>6,4=>6,5=>6,6=>5,7=>7,8=>4,9=>5,10=>5,11=>5,12=>6,13=>3,14=>3,15=>4,16=>4,17=>4,18=>3,19=>4,20=>2,21=>2,22=>3,"X"=>7,"Y"=>1);

open (BASE, ">$path2output/epo_maf_basecount_chr".$chrom."_151210.txt" ) or die "Can't open $path2output/epo_maf_cpg_chr".$chrom.".txt for writing";
open (BLOCK, ">$path2output/epo_maf_blockcount_chr".$chrom.".txt" ) or die "Can't open $path2output/epo_maf_cpg_chr".$chrom.".txt for writing";
open (CPG, ">$path2output/epo_maf_cpgcount_chr".$chrom.".txt" ) or die "Can't open $path2output/epo_maf_cpg_chr".$chrom.".txt for writing";
open (OUT, ">$path2output/epo_maf_cpg_chr".$chrom.".txt" ) or die "Can't open $path2output/epo_maf_cpg_chr".$chrom.".txt for writing";

my $i = 1;
while ($i <= $chrom_maf{$chrom})
{
print "Compara.6_primates_EPO.chr$chrom"."_$i".".maf\n";
# Create new alignio object and move through object one alignment block at a time
my $in  = Bio::AlignIO->new(-file => "$path2input/Compara.6_primates_EPO.chr$chrom"."_$i".".maf", '-format' => 'maf');
while(my $aln = $in->next_aln())
{
	my $human = 0;
	my $chimp = 0;
	my $other = 0;
	my $gorilla = 0;
	my $orang = 0;
	my $macaca = 0;
	my $marmo = 0;
	my %species;
	my $old_cpg = 1;
	my $old_gaps = 0;
	my ($start,$strand, $human_seq);
	# determine what species are represented in block and store each sequence in a hash with species name as key
	foreach my $seq ($aln->each_seq)
	{
		my $species = $seq->display_id;
		if ($species =~m/Homo_sapiens/)
		{
			$human++;
			if ($human == 1)
			{
				$species{"human"} = $seq->seq();
				# record the start and strand of the sequence in the block
				$start = $seq->start - 1;
				$strand = $seq->strand;
				$human_seq = $seq;
			}
		}
		elsif ($species =~m/Pan_troglodytes/)
		{
			$chimp++;
			if ($chimp == 1)
			{
				$species{"chimp"} = $seq->seq();
			}
		}
		elsif ($species =~m/Gorilla_gorilla/)
		{
			$other++;
			$gorilla++;
			$species{"gorilla"} = $seq->seq();
		}
		elsif ($species =~m/Pongo_pygmaeus/)
		{
			$other++;
			$orang++;
			$species{"orang"} = $seq->seq();
		}
		elsif ($species =~m/Macaca_mulatta/)
		{
			$other++;
			$macaca++;
			$species{"macaca"} = $seq->seq();
		}
		elsif ($species =~m/Callithrix_jacchus/)
		{
			$other++;
			$marmo++;
			$species{"marmo"} = $seq->seq();
		}
	}
	my $hseq = lc($species{"human"});
	my @cpg_pos;
	# determine position of every cpg site in the human seq and store in array @cpg_pos
	push @cpg_pos,length($`) while ($hseq =~/$pattern/g);
	my @tmp = ($hseq =~/-/g);
	my $gaps_in_seq = $#tmp;
	my @humanseq = split//,$hseq;
	#/
	my $bases = $#humanseq- $gaps_in_seq;
	$fullset += $bases;
	$block++;
	$cpg_count += $#cpg_pos + 1;
	# determine if block contains the necessary species i.e. single human, single chimp and at least one other furry primate
	if ($human == 1)
	{
		$sub1 += $bases; 
		$block1++;
		$cpg1 += $#cpg_pos + 1;
		if ($chimp == 1)
		{
			$sub2 += $bases;
			$block2++;
			$cpg2 += $#cpg_pos + 1;	
			if ($other >0)
			{
				$sub3 += $bases;
				$block3++;
				$cpg3 += $#cpg_pos + 1;
				foreach my $cpg (@cpg_pos)
				{
					my $pos = $cpg+1;
			
					my $subseq = $human_seq->subseq($old_cpg, $pos);
					my @gaps = ($subseq =~/-/g);
					my $gap_count = @gaps + $old_gaps;
					my $gen_pos = $start+$pos-$gap_count;
					print OUT "$chrom\t$gen_pos\n";
					$old_cpg = $pos;
					$old_gaps = $gap_count;
				}
			}
		}
	}
	
}
$i++;
}
print BASE "$fullset\t$sub1\t$sub2\t$sub3\n";
print BLOCK "$block\t$block1\t$block2\t$block3\n";
print CPG "$cpg_count\t$cpg1\t$cpg2\t$cpg3\n";
close BASE;
close BLOCK;
close CPG;
close OUT;
