#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
read list of cpgs in significant regions for each sample. find those that are found in all members of cohort.
=head2 Usage

Usage: ./multiple_sample_pippy_dmr_check.pl path2samplesfile path2files track_name chrom path2outputwig

=cut

#################################################################
# multiple_sample_pippy_dmr_check.pl 
# read list of cpgs in significant regions for each sample. find those that are found in all members of cohort.
#################################################################

use strict;

unless (@ARGV ==5) {
        die "\n\nUsage:\n ./multiple_sample_pippy_dmr_check.pl path2samplesfile path2files track_name chrom path2outputwig\nPlease try again.\n\n\n";}

my $samples_file = shift;
my $path2files = shift;
my $name = shift;
my $chrom = shift;
my $path2output = shift;

my (@co1, @co2, %cpgs, %type, %pvals);

open (INFO, "$samples_file" ) or die "Can't open $samples_file for reading";
while (my $info = <INFO>)
{
	chomp $info;
	my @elems = split /\t/,$info;
	my $cohort = $elems[1];
	if ($cohort == 0)
	{
		push @co1, $elems[0];
	}
	elsif ($cohort == 1)
	{
		push @co2, $elems[0];
	}
}
close INFO;
my $count = 0;
foreach my $s1 (@co1)
{
	foreach my $s2 (@co2)
	{
		open  (DMRS, "$path2files/$s1"."_vs_$s2"."_dmr_test.txt" ) or die "Can't open $path2files/$s1"."_vs_$s2"."_dmr_test.txt for reading";
		while (my $line = <DMRS>)
		{
			chomp $line;
			my @elems = split /\t/,$line;
			my $id = $elems[0]."_".$elems[3];
			if (exists $cpgs{$id})
			{
				$cpgs{$id}++;
				$pvals{$id} += $elems[2];
			}
			else
			{
				$cpgs{$id} = 1;
				$pvals{$id} = $elems[2];
			}
		}
		$count++;
	}
}
my $total = 0;
foreach my $key (sort { $cpgs {$a} <=> $cpgs {$b}} keys %cpgs )
{
	if ($cpgs{$key} == $count)
	{
		my $av_p = $pvals{$key}/$count;
		print "$key\t$cpgs{$key}\t$av_p\n";
		$total++;
	}
}
open (WIG, ">$path2output") or die "Can't open $path2output for writing";
print WIG "track type=\"wiggle_0\" name=\"$name\" color=50,50,150 yLineMark=0.0 yLineOnOff=on visibility=2 priority=1 autoScale=off maxHeightPixels=40:40:2\n";
foreach my $key (sort (keys %cpgs))
{
	my @elems = split/_/,$key;
	my $result;
	if ($elems[1] == 0)
	{
		$result = $cpgs{$key} * -1;
	}
	else
	{
		$result = $cpgs{$key};
	}
	print WIG "fixedStep chrom=chr$chrom start=$elems[0] step=1\n$result\n$result\n";
}
print "max = $count\ntotal = $total\n";
close WIG;
