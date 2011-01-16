#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Obtain .emf file, convert to .maf. Parse .maf file (obtained from epo 6 primate alignment) using bioperl alignio. 
Process alignment block if it contains single human, single chimp and one other species. 
When processing find CpG sites in human not present in chimp or other. Record the coordinate.
Also produce cpg feature files specific for the cpg sites of interest.
=head2 Usage

Usage: ./maf_parser_cpg_count.pl path2maf path2featurematrix chrom pattern (e.g. cg) maf_file_count path2output

=cut

#################################################################
# maf_parser_cpg_count.pl - Obtain .emf file, convert to .maf. Parse .maf file (obtained from epo 6 primate alignment) using bioperl alignio. 
# Process alignment block if it contains single human, single chimp and one other species. 
# When processing find CpG sites in human not present in chimp or other. Record the coordinate.
# Also produce cpg feature files specific for the cpg sites of interest.
#################################################################

use Bio::AlignIO;
use strict;

unless (@ARGV ==6) {
        die "\n\nUsage:\n ./maf_parser_cpg_count.pl path2maf path2featurematrix chrom pattern (e.g. cg) maf_file_count path2output\nPlease try again.\n\n\n";}

my $path2input = shift;
my $path2matrix = shift; # /data/genomic_features/human_GRCh37/cpg_matrices
my $chrom = shift;
my $pattern = shift;
my $maf_file_count = shift; # number of maf files comprising full chromosome
my $path2output = shift;

# open all output files for writing
open (MISS, ">$path2output/human_primates_$pattern"."_miss_nogaps_chr$chrom".".txt" ) or die "Can't open $path2output/human_primates_cpg_miss_chr$chrom".".txt for writing";
open (MATCH, ">$path2output/human_primates_$pattern"."_match_nogaps_chr$chrom".".txt" ) or die "Can't open $path2output/human_primates_cpg_match_chr$chrom".".txt for writing";
open (MISS_FEAT, ">$path2output/human_primates_features_cpg_miss_nogaps_chr$chrom".".txt" ) or die "Can't open $path2output/human_primates_cpg_miss_chr$chrom".".txt for writing";
open (MATCH_FEAT, ">$path2output/human_primates_features_cpg_match_nogaps_chr$chrom".".txt" ) or die "Can't open $path2output/human_primates_cpg_match_chr$chrom".".txt for writing";

# prepare the cpg matrix hash by running the feature_matrices subroutine for each matrix type
my (%cpg_mat_scal,%cpg_mat);
my $cpg_mat_scal = \%cpg_mat_scal;
$cpg_mat_scal = feature_matrices($path2matrix,$chrom,"feature",$cpg_mat_scal,0);
$cpg_mat_scal = feature_matrices($path2matrix,$chrom,"renlab",$cpg_mat_scal,1);
$cpg_mat_scal = feature_matrices($path2matrix,$chrom,"repeat_family",$cpg_mat_scal,1);
%cpg_mat = %$cpg_mat_scal;
print MISS_FEAT "\n";
print MATCH_FEAT "\n";

my $i = 1;
while ($i <= $maf_file_count)
{
my $total = 0;
my $total_gaps = 0;
print "Compara.6_primates_EPO.chr$chrom"."_$i".".maf\n";

# System call to the ensembl script emf2maf.pl - converts emf file to maf file
system "/path/to/ensembl-compara/scripts/dumps/emf2maf.pl $path2input/Compara.6_primates_EPO.chr$chrom"."_$i".".emf";

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
	my ($start,$strand, $human_seq);
	my $old_cpg = 1;
	my $old_gaps = 0;
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
	# determine if block contains the necessary species i.e. single human, single chimp and at least one other furry primate
	if ($human == 1 && $chimp == 1 && $other >0)
	{
		my $hseq = lc($species{"human"});
		my @cpg_pos;
		# determine position of every cpg site in the human seq and store in array @cpg_pos
		push @cpg_pos,length($`) while ($hseq =~/$pattern/g);
		#`
		my @tmp = ($hseq =~/-/g);
		my $gaps_in_seq = $#tmp;
		$total_gaps += $gaps_in_seq;
		my $cseq = lc($species{"chimp"});
		# create an array for each species represented. Each element contains single base.
		my @chimpseq = split//,$cseq;
		my @humanseq = split//,$hseq;
		my (@marmoseq,@macaseq,@orangseq,@gorilseq, $oseq);
		if ($marmo == 1)
		{
			$oseq = lc($species{"marmo"});
			@marmoseq = split//,$oseq; #/
		}
		if ($macaca == 1)
		{
			$oseq = lc($species{"macaca"});
			@macaseq = split//,$oseq;   #/
		}
		if ($orang == 1)
		{
			$oseq = lc($species{"orang"});
			@orangseq = split//,$oseq;   #/
		}
		if ($gorilla == 1)
		{
			$oseq = lc($species{"gorilla"});
			@gorilseq = split//,$oseq;   #/
		}
		print "human = $#humanseq\tchimp = $#chimpseq\n";
		my ($osite,$theother);
		# check each cpg site for corresponding bases in other species
		foreach my $cpg (@cpg_pos)
		{
			my $all_ok = 1;
			my $pos = $cpg+1;
			my $csite = "$chimpseq[$cpg]"."$chimpseq[$pos]";
			#my ($osite,$theother);
			my $doublecheck = 0;
			my $match = 1;
			# if chimpy doesn't match cg and doesn't contain n or -, continue on to other species. Each species is checked to make sure it doesn't match cg.
			if ($csite ne $pattern && $csite !~m/n|-/)
			{
				if ($marmo == 1)
				{
					$osite = "$marmoseq[$cpg]"."$marmoseq[$pos]";
					if ($osite eq $pattern)
					{
						$all_ok = 0;
					}
					$theother = "marmo";
					$doublecheck = 1;
				}
				if ($macaca == 1)
				{
					$osite = "$macaseq[$cpg]"."$macaseq[$pos]";
					if ($osite eq $pattern)
					{
						$all_ok = 0;
					}
					$theother = "macaca";
					$doublecheck = 1;
				}
				if ($orang == 1)
				{
					$osite = "$orangseq[$cpg]"."$orangseq[$pos]";
					if ($osite eq $pattern)
					{
						$all_ok = 0;
					}
					$theother = "orang";
					$doublecheck = 1;
				}
				if ($gorilla == 1)
				{
					$osite = "$gorilseq[$cpg]"."$gorilseq[$pos]";
					if ($osite eq $pattern)
					{
						$all_ok = 0;
					}
					$theother = "gorilla";
					$doublecheck = 1;
				}
				
				if ($doublecheck == 0)
				{
					print STDERR "error = $start\n";	
					next;
				}
				
				# if none of the species matches cg and the closest 'other' primate doesn't match n or -, record the site as one of interest!
				if ($all_ok == 1 && $osite !~m/n|-/)
				{
					# gen_pos needs to take account of number of gaps between block start and cpg.
					my $subseq = $human_seq->subseq($old_cpg, $pos);
					my @gaps = ($subseq =~/-/g);
					my $gap_count = @gaps + $old_gaps;
					my $gen_pos = $start+$pos-$gap_count;
					print MISS "$chrom\t$gen_pos\t$start\t$strand\t$csite\t$osite\t$theother\n";
					print MISS_FEAT "$cpg_mat{$gen_pos}\n";
					$old_cpg = $pos;
					$old_gaps = $gap_count;
					$match = 0;
				}
			}
			if ($match == 1)
			{
				# gen_pos needs to take account of number of gaps between block start and cpg.
				my $subseq = $human_seq->subseq($old_cpg, $pos);
				my @gaps = ($subseq =~/-/g);
				my $gap_count = @gaps + $old_gaps;
				my $gen_pos = $start+$pos-$gap_count;
				print MATCH "$chrom\t$gen_pos\t$start\t$strand\t$csite\n";
				print MATCH_FEAT "$cpg_mat{$gen_pos}\n";
				$old_cpg = $pos;
				$old_gaps = $gap_count;
			}
		}
		$total = $total + $#humanseq;
	}
}
print "Total bases = $total\n";
print "Total gaps = $total_gaps\n";
my $proper = $total - $total_gaps;
print "Actual bases = $proper\n";
$i++;
}
close MISS;
close MISS_FEAT;
close MATCH_FEAT;
close MATCH;

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
