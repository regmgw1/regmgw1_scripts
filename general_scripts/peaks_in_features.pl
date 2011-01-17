#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Find overlaps between useq dmr files and feature files
=head2 Usage

Usage: ./peaks_in_feature.pl feature_type path2features path2peakroot path2peaklist

=cut

#################################################################
# peaks_in_features.pl
#################################################################

use strict;

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./peaks_in_feature.pl feature_type path2features path2peakroot path2peaklist\nPlease try again.\n\n\n";}

my $path2featlist = shift;
my $path2features = shift;
my $path2peakroot = shift;
my $path2peaklist = shift;

my (@types, @peak_subs);
open (IN, "$path2featlist" ) or die "Can't open $path2featlist for reading";
while (my $line = <IN>)
{
	chomp $line;
	push @types, $line;
}
close IN;

open (IN, "$path2peaklist" ) or die "Can't open $path2peaklist for reading";
while (my $line = <IN>)
{
	chomp $line;
	push @peak_subs, $line;
}
close IN;

foreach my $peaksub (@peak_subs)
{
my %peak;
my $peakfile = $peaksub;
$peakfile =~s/.*Binary/binary/;
my $count = 0;
print "$peaksub\n";
open (PEAK, "$path2peakroot/$peaksub/$peakfile".".gff" ) or die "Can't open $path2peakroot/$peaksub/$peakfile".".gff for reading";
while (my $line = <PEAK>)
{
	if ($count > 0 && $line !~m/^\#/)
	{
		chomp $line;
		my @elems = split /\t/,$line;
		my $begin = $elems[3];
		my $end = $elems[4];
		my $chr = $elems[0];
		$chr =~s/chr//;
		while ($begin <= $end)
		{
			$peak{$chr}{$begin} = $end;
			$begin++;
		}
	}
	$count++;
}
close PEAK;

my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19);
foreach my $feature (@types)
{
	my $total_overlap = 0;
	my $total_bases = 0;	
	foreach my $chrom (@chroms)
	{
		my $overlap = 0;
		open (FEAT, "$path2features/$feature/chr$chrom"."_"."$feature".".gff" ) or die "Can't open $path2features/$feature/chr$chrom"."_"."$feature".".gff for reading";
		while (my $line = <FEAT>)
		{
			chomp $line;
			my @elems = split /\t/,$line;
			my $begin = $elems[3];
			my $end = $elems[4];
			$total_bases += ($end-$begin) + 1;
			while ($begin <= $end)
			{
				if (exists $peak{$chrom}{$begin})
				{
					$overlap++;
				}
				$begin++;
			}
		}
		close FEAT;
		$total_overlap += $overlap;
	}
	my $percent = ($total_overlap/$total_bases) * 100;
	print "$feature\t$total_overlap\t$total_bases\t$percent\n";
}
}			
			

