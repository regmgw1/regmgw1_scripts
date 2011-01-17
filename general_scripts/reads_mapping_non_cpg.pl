#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
takes as input mapped reads (gff). Each read is checked to see if it maps to a region containing a CpG. If no cpg is found
the read is stored for further processing. This processing involves determining how many other non-CpG
reads overlap with this given read. A final distribution of counts is generated for each chromosome.

=head2 Usage

Usage: ./reads_mapping_non_cpg.pl path2reads path2cpgs sample strand species

=cut

#################################################################
# reads_mapping_non_cpg.pl - takes as input mapped reads (gff). Each read
# is checked to see if it maps to a region containing a CpG. If no cpg is found
# the read is stored for further processing. This processing involves determining how many other non-CpG
# reads overlap with this given read. A final distribution of counts is generated for each chromosome.
#################################################################

use strict;
use Bio::Range;

unless (@ARGV ==5) {
        die "\n\nUsage:\n ./reads_mapping_non_cpg.pl path2reads path2cpgs sample strand species\nPlease try again.\n\n\n";}

my $reads = shift;
my $cpgs = shift;
my $sample = shift;
my $strand = shift;
my $species = shift;

my @chroms;

if ($species eq "human")
{
	@chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22);
}
elsif ($species eq "mouse")
{
	@chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19);
}
else
{
	die "wrong species - human or mouse!";
}
my %overlaps;

print "chr";
for (my $j = 0;$j<=100;$j++)
{
	print "\t$j";
}
print "\n";

foreach my $chrom (@chroms)
{
	print STDERR "chrom $chrom\n";
	my %read = ();
	my %cpg = ();
	my %out = ();
	%overlaps = ();
	my %over_count = ();
	my @ranges;
	# open file containing list of cpgs and store info in hash
	open (CPG, "$cpgs/chr$chrom"."_cpgs.gff" ) or die "Can't open $cpgs/chr$chrom"."_cpgs.gff for reading";
	while (my $line = <CPG>)
	{
		chomp $line;
		my @elems = split /\t/,$line;
		my $begin = $elems[3];
		my $end = $elems[4];
		$cpg{$begin} = $end;
	}
	close CPG;
	
	# open reads file (pippy gff format). for each read check the strand info, if the strand matches the user defined strand, the 
	# read fragment is processed to determine whether it maps to a cpg containing region of the host genome. if it does, move on
	# to the next read. if no cpg is found, put the read info into hash (one hash for printing all non cpg reads to file, the 
	# other stores just the start of the fragment for sorting on in next step.
	open (IN, "$reads/$sample"."_chr$chrom".".gff" ) or die "Can't open $reads/$sample"."_chr$chrom"."_pippy_v2.gff for reading";
	while (my $line = <IN>)
	{
		chomp $line;
		my @elems = split /\t/,$line;
		my $begin = $elems[3];
		my $begin_cons = $begin;
		my $end = $elems[4];
		my $t_strand = $elems[6];
		if ($t_strand eq "+")
		{
			$t_strand = 1;
		}
		elsif ($t_strand eq "-")
		{
			$t_strand = 0;
		}
		if ($strand eq $t_strand || $strand == 2)
		{
			my $coords = $begin."_".$end;
			my $present = 0;
			while ($begin <= $end)
			{
				if (exists $cpg{$begin})
				{
					$present = 1;
					last;
				}
				$begin++;
				
			}
			if ($present == 0)
			{
				$out{$coords} = "$line\n";
				$overlaps{$coords} = $begin_cons;
			}
		}	
	}
	close IN;
	
	# sort overlaps hash on the value (start position of read). create a range object (from Bio::Range) and push
	# in array ordered according to genomic location.
	
	foreach my $key (sort hashValueAscendingNum(keys(%overlaps)))
	{
		my $coords = $key;
		my $begin = $overlaps{$key};
		my @elems = split /_/,$coords;
		my $end = $elems[1];
		my $overlap = 0;
		my $range = Bio::Range->new(-start=>$begin, -end=>$end);
		push @ranges, $range
	}
	
	# use the $i variable to navigate through the array of ranges objects. use the Bio::Range overlaps() function to look for 
	# overlaps in adjacent elements. if overlaps are found, the next adjacent element is also checked for overlap. 
	# The $foverlap and $roverlap variables allow for this navigation through the array. Once the number of overlaps for a 
	# given read is determined, the overlap value is added to a hash.
	
	my $i = 0;
	foreach my $entry (@ranges)
	{
		my ($foverlap,$roverlap);
		my $overlaps = 0;
		my $r = 1;
		my $f = 1;
		if ($i < $#ranges)
		{
			$foverlap = $i+1;
		}
		else
		{	
			$f = 0;
		}
		if ($i > 0)
		{
			$roverlap = $i - 1;
		}
		else
		{
			$r = 0;
		}
		if ($f == 1)
		{
			while ($entry->overlaps($ranges[$foverlap]) && $foverlap <$#ranges)
			{
				$overlaps++;
				$foverlap++;
			}
		}
		if ($r == 1)
		{
			while ($entry->overlaps($ranges[$roverlap]) && $roverlap >= 0)
			{
				$overlaps++;
				$roverlap--;
			}
		}
		my $start = $entry->start();
		my $end = $entry->end();
		if (exists $over_count{$overlaps})
		{
			$over_count{$overlaps}++;
		}
		else
		{
			$over_count{$overlaps} = 1;
		} 
		$i++;
	}
	
	# The overlap count distribution is printed out using the for loop.
	print "$chrom";
	for (my $j = 0;$j<=100;$j++)
	{
		if (exists $over_count{$j})
		{
			print "\t$over_count{$j}";
		}
		else
		{
			print "\t0";
		}
	}
	print "\n";
}
sub hashValueAscendingNum {
   $overlaps{$a} <=> $overlaps{$b};
}	



