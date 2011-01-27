#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Wrapper script to run peaks_in_features_bedtools.pl as part of the useq pipeline
=head2 Usage

Usage: ./peak_nearest_gene_bedtools_wrap.pl path2peakroot path2peaklist path2featureList path2features intersect_thresh path2output

=cut

#################################################################
# peaks_nearest_gene_bedtools_wrap.pl
#################################################################

use strict;

unless (@ARGV ==6) {
        die "\n\nUsage:\n ./peaks_in_features_bedtools_wrap.pl path2peakroot path2peaklist path2genes path2output up_window down_window\nPlease try again.\n\n\n";}

#for pipeline use
my $path2peakroot = shift;
my $path2peaklist = shift;
# for peaks_in_features_bedtools use
my $path2genes = shift;
my $path2output = shift;
my $up = shift;
my $down = shift;

my (@samples, @peak_subs);

# open list of directory names containing peaks and store in array
open (IN, "$path2peaklist" ) or die "Can't open $path2peaklist for reading";
while (my $line = <IN>)
{
	chomp $line;
	push @peak_subs, $line;
}
close IN;

foreach my $peaksub (@peak_subs)
{
	my $peakfile = $peaksub;
	$peakfile =~s/.*Binary/binary/;
	my $outputPl = "$path2output/$peaksub"."_peak_nearest_gene.txt";
	my $inputPl = "$path2peakroot/$peaksub/$peakfile".".gff";
	my @counts = `perl peak_nearest_gene_bedtools.pl $inputPl $path2genes $outputPl $up $down`;
}
