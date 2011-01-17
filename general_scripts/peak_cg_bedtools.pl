#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Use bedTools 'fastaFromBed' to obtain metadata for the useq peaks
=head2 Usage

Usage: ./peaks_cg_bedtools.pl path2genome path2peakroot path2peaklist path2output

=cut

#################################################################
# peaks_explorer.pl
#################################################################

use strict;

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./peaks_cg_bedtools.pl path2genome path2peakroot path2peaklist path2output\nPlease try again.\n\n\n";}

my $path2genome = shift;
my $path2peakroot = shift;
my $path2peaklist = shift;
my $path2output = shift;

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
	open (OUT, ">$path2output/$peaksub"."_peak_cg.txt") or die "Can't open $path2output/$peaksub"."_peak_cg.txt for writing";
	my $peakfile = $peaksub;
	my (%peak, %peak_pos, %peak_neg);
	$peakfile =~s/.*Binary/binary/;
	open (TMP, ">tmp.gff") or die "Can't open tmp.gff for writing";
	open (IN, "$path2peakroot/$peaksub/$peakfile".".gff" ) or die "Can't open $path2peakroot/$peaksub/$peakfile".".gff for reading";
	while (my $line = <IN>)
	{
		$line =~s/^chr//;
		print TMP "$line";
	}
	close IN;
	close TMP;
	my @seq = `fastaFromBed -fi path/to/genome/mouse_genome_37.fa -bed  tmp.gff -fo tmp.fasta -tab`;
	open (IN, "tmp.fasta" ) or die "Can't open tmp.fasta for reading";
	while (my $line = <IN>)
	{
		chomp $line;
		my @elems = split/\t/,$line;
		my $seq = $elems[1];
		my @tmp = ($seq =~/CG/g);
		my $cgs = $#tmp + 1;
		my $seq_length = length($seq);
		my $density = ($cgs/$seq_length * 2) * 100;
		print OUT "$elems[0]\t$cgs\t$seq_length\t$density\n";
	}
	close IN;
	close OUT;
}

