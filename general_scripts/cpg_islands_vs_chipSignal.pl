#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Utilises bedTools to find overlaps between cpg islands and chip file from UCSC. Calculates chip signal area and peak chip signal overlapping CpG_island.
=head2 Usage

Usage: ./cpg_islands_vs_chipSignal.pl path2cpgislands path2chip path2output

=cut

#################################################################
# cpg_islands_vs_chipSignal.pl
#################################################################

use strict;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./cpg_islands_vs_chipSignal.pl path2cpgislands path2chip path2output\nPlease try again.\n\n\n";}

my $path2cpgislands = shift;
my $path2chip = shift;
my $path2output = shift;

my (%areaH,%peakH,%lengthH);

open (OUT, ">$path2output") or die "Can't open $path2output for writing";

# set up hash keys
open (IN, "$path2cpgislands" ) or die "Can't open $path2cpgislands for reading";
while (my $line = <IN>)
{
	my @elems = split/\t/,$line;
	$areaH{$elems[2]} = 0;
	$peakH{$elems[2]} = 0;
	$lengthH{$elems[2]} = ($elems[4] - $elems[3])+1;
}
close IN;

# run intersectBed
my @count = `intersectBed -a $path2cpgislands -b $path2chip -wa -wb`;
foreach my $inter (@count)
{
	chomp $inter;
	my @elems = split/\t/, $inter;
	my $island_coords = $elems[2];
	my $chip_start = $elems[10];
	my $chip_stop = $elems[11];
	my $chip_score = $elems[12];
	my $area_add = ($chip_stop - $chip_start) * $chip_score;
	$areaH{$island_coords} += $area_add;
	if ($chip_score > $peakH{$island_coords})
	{
		$peakH{$island_coords} = $chip_score;
	}
} 
print OUT "CpG_island\tAverageSig\tMaxSig\n";
foreach my $coords (sort(keys %areaH))
{
	my $area = $areaH{$coords}/$lengthH{$coords};
	print OUT "$coords\t$area\t$peakH{$coords}\n";
}
close OUT; 


