#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Find overlaps between different useq dmr files
=head2 Usage

Usage: ./peak_overlaps.pl path2file1 path2file2

=cut

#################################################################
# peak_overlaps.pl
#################################################################

use strict;

unless (@ARGV ==2 ) {
        die "\n\nUsage:\n ./peak_overlaps.pl path2file1 path2file2 \nPlease try again.\n\n\n";}

my $path2file1 = shift;
my $path2file2 = shift;

my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19);
print "chrom\tNPC_start\tNPC_stop\tMEF_start\tMEF_stop\tOverlap\n";

foreach my $chr (@chroms)
{
my (%file2_hash,%line2_hash,%line1_hash,%overlap,%rank_hash);
my $count = 0;
open (IN, "$path2file2" ) or die "Can't open $path2file2 for reading";
while (my $line = <IN>)
{
	
	if ($count > 0 && $line !~m/^\#/)
	{
		chomp $line;
		my @elems = split/\t/, $line;
		my $tchr = $elems[0];
		$tchr =~s/chr//;
		if ($tchr eq $chr)
		{
			my $inc = $elems[3];
			while ($inc <= $elems[4])
			{
				$file2_hash{$inc} = 0;
				$line2_hash{$inc} = "$elems[3]\t$elems[4]";;
				$inc++;
			}
		}
	}
	$count++
}
close IN;
$count = 0;
open (IN, "$path2file1" ) or die "Can't open $path2file1 for reading";
while (my $line = <IN>)
{
	if ($count > 0 && $line !~m/^\#/)
	{
		chomp $line;
		my @elems = split /\t/,$line;
		my $begin = $elems[3];
		my $end = $elems[4];
		my $chrom = $elems[0];
		$chrom =~s/chr//;
		my $overlaps = 0;
		my $track = 0;
		if ($chrom eq $chr)
		{
			my $inc = $begin;
			while ($inc <= $end)
			{
				if (exists $file2_hash{$inc})
				{
					if ($overlaps == 0)
					{
						$file2_hash{$inc} = 1;
						$line1_hash{$inc} = "$begin\t$end";
						$track = $inc;
						$rank_hash{$inc} = $count;
					}
					$overlaps++;
				}
				$inc++;
			}
		}
		if ($overlaps > 0)
		{
			$overlap{$track} = $overlaps;
		}
	}
	$count++;
}
close IN;

foreach my $key (sort numerically keys %file2_hash)
{	
	if ($file2_hash{$key} == 1)
	{
		print "$chr\t$line2_hash{$key}\t$line1_hash{$key}\t$overlap{$key}\t$rank_hash{$key}\n";
	}
}
}
sub numerically {$a<=>$b};			
