#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Removes random lines from pippy files
=head2 Usage

Usage: ./primate_maf_parser_cpg_count_legion.pl path2maf chrom pattern (e.g. cg) maf_file_count primary_primate path2output

=cut

#################################################################
# primate_maf_parser_cpg_count_legion.pl
#################################################################

use lib '/path/to/modules//';
use Bio::AlignIO;
use strict;

unless (@ARGV ==6) {
        die "\n\nUsage:\n ./primate_maf_parser_cpg_count_legion.pl path2maf chrom pattern (e.g. cg) maf_file_count primary_primate path2output\nPlease try again.\n\n\n";}

my $path2input = shift;
my $chrom = shift;
my $pattern = shift;
my $maf_file_count = shift; # number of maf files to process NOTE different to other versions of script
my $primate = shift;
my $path2output = shift;

# open all output files for writing
open (MISS, ">$path2output/$primate"."_primates_$pattern"."_miss_nogaps_chr$chrom"."_maf_$maf_file_count".".txt" ) or die "Can't open $path2output/human_primates_cpg_miss_chr$chrom".".txt for writing";

my $i = $maf_file_count;

my $total = 0;
my $total_gaps = 0;
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
	my $primateC = 0;
	my $random = 0;
	my %species;
	my ($start,$strand, $out_chrom, $human_seq, $primate_seq);
	my $old_cpg = 1;
	my $old_gaps = 0;
	# determine what species are represented in block and store each sequence in a hash with species name as key
	foreach my $seq ($aln->each_seq)
	{
		my ($species,$t_chrom) = split/\./,$seq->display_id;
		if ($species =~m/Homo_sapiens/)
		{
			$human++;
			if ($human == 1)
			{
				$species{"human"} = $seq->seq();
				# record the start and strand of the sequence in the block
				$human_seq = $seq;
			}
		}
		elsif ($species =~m/Pan_troglodytes/)
		{
			$chimp++;
			if ($primate eq "chimp")
			{
				$primateC++;
			}
			if ($chimp == 1)
			{
				$species{"chimp"} = $seq->seq();
				if ($primate eq "chimp")
				{
					$strand = $seq->strand;
					if ($strand eq "-")
					{
						$start = ($seq->desc + 1)- $seq->start ;
					}
					else
					{
						$start = $seq->start - 1;
					}
					$out_chrom = $t_chrom;
					$primate_seq = $seq;
					if ($out_chrom =~m/random|Un/)
					{
						$random = 1;
					}
				}
				else
				{
					$other++;
				}
			}
		}
		elsif ($species =~m/Gorilla_gorilla/)
		{
			$gorilla++;
			if ($primate eq "gorilla")
			{
				$primateC++;
			}
			if ($gorilla == 1)
			{
				$species{"gorilla"} = $seq->seq();
				if ($primate eq "gorilla")
				{
					$strand = $seq->strand;
					if ($strand eq "-")
					{
						$start = ($seq->desc + 1)- $seq->start ;
					}
					else
					{
						$start = $seq->start - 1;
					}
					$out_chrom = $t_chrom;
					$primate_seq = $seq;
					if ($out_chrom =~m/random|Un/)
					{
						$random = 1;
					}
				}
				else
				{
					$other++;
				}
			}
		}
		elsif ($species =~m/Pongo_pygmaeus/)
		{
			$orang++;
			if ($primate eq "orang")
			{
				$primateC++;
			}
			if ($orang == 1)
			{
				$species{"orang"} = $seq->seq();
				if ($primate eq "orang")
				{
					$strand = $seq->strand;
					if ($strand eq "-")
					{
						$start = ($seq->desc + 1)- $seq->start ;
					}
					else
					{
						$start = $seq->start - 1;
					}
					$out_chrom = $t_chrom;
					$primate_seq = $seq;
					if ($out_chrom =~m/random|Un/)
					{
						$random = 1;
					}
				}
				else
				{
					$other++;
				}
			}
		}
		elsif ($species =~m/Macaca_mulatta/)
		{
			$macaca++;
			if ($primate eq "macaca")
			{
				$primateC++;
			}
			if ($macaca == 1)
			{
				$species{"macaca"} = $seq->seq();
				if ($primate eq "macaca")
				{
					$strand = $seq->strand;
					if ($strand eq "-")
					{
						$start = ($seq->desc + 1)- $seq->start ;
					}
					else
					{
						$start = $seq->start - 1;
					}
					$out_chrom = $t_chrom;
					$primate_seq = $seq;
					if ($out_chrom =~m/random|Un/)
					{
						$random = 1;
					}
				}
				else
				{
					$other++;
				}
			}
		}
		elsif ($species =~m/Callithrix_jacchus/)
		{
			$marmo++;
			if ($primate eq "marmo")
			{
				$primateC++;
			}
			if ($marmo == 1)
			{
				$species{"marmo"} = $seq->seq();
				if ($primate eq "marmo")
				{
					$strand = $seq->strand;
					if ($strand eq "-")
					{
						$start = ($seq->desc + 1)- $seq->start ;
					}
					else
					{
						$start = $seq->start - 1;
					}
					$out_chrom = $t_chrom;
					$primate_seq = $seq;
					if ($out_chrom =~m/random|Un/)
					{
						$random = 1;
					}
				}
				else
				{
					$other++;
				}
			}
		}
	}
	# determine if block contains the necessary species i.e. single human, single chimp and at least one other furry primate
	if ($human == 1 && $primateC == 1 && $other >0 && $random == 0)
	{
		my $pseq = lc($species{$primate});
		my @cpg_pos;
		# determine position of every cpg site in the human seq and store in array @cpg_pos
		push @cpg_pos,length($`) while ($pseq =~/$pattern/g);
		#`
		my @tmp = ($pseq =~/-/g);
		my $gaps_in_seq = $#tmp;
		$total_gaps += $gaps_in_seq;
		my $hseq = lc($species{"human"});
		# create an array for each species represented. Each element contains single base.
		my @humanseq = split//,$hseq;
		my @primateseq = split//,$pseq;
		my (@chimpseq,@marmoseq,@macaseq,@orangseq,@gorilseq, $oseq);
		if ($marmo == 1 && $primate ne "marmo")
		{
			$oseq = lc($species{"marmo"});
			@marmoseq = split//,$oseq; #/
		}
		if ($macaca == 1 && $primate ne "macaca")
		{
			$oseq = lc($species{"macaca"});
			@macaseq = split//,$oseq;   #/
		}
		if ($orang == 1 && $primate ne "orang")
		{
			$oseq = lc($species{"orang"});
			@orangseq = split//,$oseq;   #/
		}
		if ($gorilla == 1 && $primate ne "gorilla")
		{
			$oseq = lc($species{"gorilla"});
			@gorilseq = split//,$oseq;   #/
		}
		if ($chimp == 1 && $primate ne "chimp")
		{
			$oseq = lc($species{"chimp"});
			@chimpseq = split//,$oseq;   #/
		}
		print "human = $#humanseq\tprimate = $#primateseq\n";
		my ($osite,$theother);
		# check each cpg site for corresponding bases in other species
		foreach my $cpg (@cpg_pos)
		{
			my $all_ok = 1;
			my $pos = $cpg+1;
			my $hsite = "$humanseq[$cpg]"."$humanseq[$pos]";
			my $doublecheck = 0;
			my $match = 1;
			# if human doesn't match cg and doesn't contain n or -, continue on to other species. Each species is checked to make sure it doesn't match cg.
			if ($hsite ne $pattern && $hsite !~m/n|-/)
			{
				if ($marmo == 1 && $primate ne "marmo")
				{
					$osite = "$marmoseq[$cpg]"."$marmoseq[$pos]";
					if ($osite eq $pattern)
					{
						$all_ok = 0;
					}
					$theother = "marmo";
					$doublecheck = 1;
				}
				if ($macaca == 1 && $primate ne "macaca")
				{
					$osite = "$macaseq[$cpg]"."$macaseq[$pos]";
					if ($osite eq $pattern)
					{
						$all_ok = 0;
					}
					$theother = "macaca";
					$doublecheck = 1;
				}
				if ($orang == 1 && $primate ne "orang")
				{
					$osite = "$orangseq[$cpg]"."$orangseq[$pos]";
					if ($osite eq $pattern)
					{
						$all_ok = 0;
					}
					$theother = "orang";
					$doublecheck = 1;
				}
				if ($gorilla == 1 && $primate ne "gorilla")
				{
					$osite = "$gorilseq[$cpg]"."$gorilseq[$pos]";
					if ($osite eq $pattern)
					{
						$all_ok = 0;
					}
					$theother = "gorilla";
					$doublecheck = 1;
				}
				if ($chimp == 1 && $primate ne "chimp")
				{
					$osite = "$chimpseq[$cpg]"."$chimpseq[$pos]";
					if ($osite eq $pattern)
					{
						$all_ok = 0;
					}
					$theother = "chimp";
					$doublecheck = 1;
				}
				if ($doublecheck == 0)
				{
					print STDERR "error = $start\n";	
					next;
				}
				
				# if none of the species matches cg and human doesn't match n or -, record the site as one of interest!
				if ($all_ok == 1 && $osite !~m/n|-/)
				{
					# gen_pos needs to take account of number of gaps between block start and cpg.
					my $subseq = $primate_seq->subseq($old_cpg, $pos);
					my @gaps = ($subseq =~/-/g);
					my $gap_count = @gaps + $old_gaps;
					my $gen_pos;
					if ($strand eq "-")
					{
						$gen_pos = $start-$pos+$gap_count;
					}
					else
					{
						$gen_pos = $start+$pos-$gap_count;
					}
					print MISS "$out_chrom\t$gen_pos\t$start\t$strand\t$hsite\t$osite\t$theother\n";
					$old_cpg = $pos;
					$old_gaps = $gap_count;
					$match = 0;
				}
			}
			if ($match == 1)
			{
				# gen_pos needs to take account of number of gaps between block start and cpg.
				my $subseq = $primate_seq->subseq($old_cpg, $pos);
				my @gaps = ($subseq =~/-/g);
				my $gap_count = @gaps + $old_gaps;
				my $gen_pos = $start+$pos-$gap_count;
				$old_cpg = $pos;
				$old_gaps = $gap_count;
			}
		}
		$total = $total + $#primateseq;
	}
}
print "Total bases = $total\n";
print "Total gaps = $total_gaps\n";
my $proper = $total - $total_gaps;
print "Actual bases = $proper\n";

close MISS;

# subroutine to generate a single hash containing all the cpg feature data. This hash can then be referenced by cpg position so as to print only cpgs of interest.
sub feature_matrices
{
	my $path2matrix = shift;
	my $chrom = shift;
	my $feature_type = shift;
	my $cpg_mat_scal = shift;
	my $head_count = shift;
	my %cpg_mat = %$cpg_mat_scal;
	my $line_count = 0;
	open (MAT, "$path2matrix/chr$chrom"."_cpg_"."$feature_type"."_matrix.txt" ) or die "Can't open $path2matrix/chr$chrom"."_cpg_"."$feature_type"."_matrix.txt for reading";
	while (my $line = <MAT>)
	{
		chomp $line;
		if ($line_count == 0)
		{
			if ($head_count == 0)
			{
				print MISS_FEAT "$line";
				print MATCH_FEAT "$line";
			}
			else
			{
				my @elems = split/\t/, $line;
				for (my $i =3;$i <=$#elems;$i++)
				{
					print MISS_FEAT "\t$elems[$i]";
					print MATCH_FEAT "\t$elems[$i]";
				}
			}
		}
		else
		{
			my @elems = split/\t/, $line;
			if (exists $cpg_mat{$elems[1]})
			{
				for (my $i =3;$i <=$#elems;$i++)
				{
					$cpg_mat{$elems[1]} .= "\t$elems[$i]";
				}
			}
			else
			{
				$cpg_mat{$elems[1]} = $line;
			}
		}
		$line_count++;
	}
	close MAT;
	return \%cpg_mat;	
}
