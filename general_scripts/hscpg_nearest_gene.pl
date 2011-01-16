#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Utilises bedTools to find nearest gene to feature of interest - prioritises intersecting gene-feature over genes near feature
=head2 Usage

Usage: ./hscpg_nearest_gene.pl path2hscpg path2genes path2output upstream_threshold downstream_threshold

=cut

#################################################################
# hscpg_nearest_gene.pl
#################################################################

use strict;

unless (@ARGV ==5) {
        die "\n\nUsage:\n ./hscpg_nearest_gene.pl path2hscpg path2genes path2output upstream_threshold downstream_threshold\nPlease try again.\n\n\n";}

my $path2hscpg = shift;
my $path2genes = shift;
my $path2output = shift;
my $up = shift;
my $down = shift;

my %hash;
my %inter;
my %inter_dup;

my @intersect = `intersectBed -a $path2genes -b $path2hscpg -wa -wb`;
my @windows = `windowBed -a $path2genes -b $path2hscpg -l $up -r $down -sw`;

open (TMP, ">hscpgTmp" ) or die "Can't open hscpgTmp for writing";

foreach my $inter (@intersect)
{
	chomp $inter;
	my @elems = split /\t/,$inter;
	my $cpg = $elems[10];
	if (exists $inter{$cpg})
	{
		$inter_dup{$cpg} = $inter{$cpg};
	}
	$inter{$cpg} = $inter;
}


foreach my $win (@windows)
{
	chomp $win;
	my @elems = split /\t/,$win;
	my $cpg = $elems[10];
	my ($new_dist, $old_dist);
	if (exists $hash{$cpg})
	{
		if ($elems[6] eq "+")
		{
			$new_dist = abs($elems[3] - $cpg);
		}
		else
		{
			$new_dist = abs($elems[4] - $cpg);
		}
		my @old_elems = split/\t/,$hash{$cpg};
		if ($old_elems[6] eq "+")
		{
			$old_dist = abs($old_elems[3] - $cpg);
		}
		else
		{
			$old_dist = abs($old_elems[4] - $cpg);
		}
		if ($new_dist < $old_dist)
		{
			$hash{$cpg} = $win;
		}
	}
	else
	{
		$hash{$cpg} = $win;
	}
	if (exists $inter{$cpg})
	{
		$hash{$cpg} = $inter{$cpg};
	}
}
foreach my $outdup (keys %inter_dup)
{
	print TMP "$inter_dup{$outdup}\n";
}
foreach my $out (keys %hash)
{
	print TMP "$hash{$out}\n";
}
close TMP;
system "cut -f 2,7 hscpgTmp|sort -u >uniqueHscpgTmp";
system "cut -d _ -f 3 uniqueHscpgTmp |cut -f 1 >$path2output";
