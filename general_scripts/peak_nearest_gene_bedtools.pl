#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Utilises bedTools to find nearest gene to feature of interest - prioritises intersecting gene-feature over genes near feature
=head2 Usage

Usage: ./peak_nearest_gene_bedtools.pl path2peaks path2genes path2output upstream_threshold downstream_threshold

=cut

#################################################################
# ./peak_nearest_gene_bedtools.pl
#################################################################

use strict;

unless (@ARGV ==5) {
        die "\n\nUsage:\n ./peak_nearest_gene_bedtools.pl path2peaks path2genes path2output upstream_threshold downstream_threshold\nPlease try again.\n\n\n";}

my $path2peaks = shift;
my $path2genes = shift;
my $path2output = shift;
my $up = shift;
my $down = shift;

my %hash;
my %inter;
my %inter_dup;

open (TMP, ">tmp.gff") or die "Can't open tmp.gff for writing";
open (DMR, $path2peaks ) or die "Can't open $path2peaks for reading";
while (my $dmr = <DMR>)
{
	if ($dmr =~m/chr/)
	{
		$dmr =~s/chr//;
	}
	print TMP "$dmr";
}
close TMP;
my @intersect = `intersectBed -a $path2genes -b tmp.gff -wa -wb`;
my @windows = `windowBed -a $path2genes -b tmp.gff -l $up -r $down -sw`;

foreach my $inter (@intersect)
{
	chomp $inter;
	my @elems = split /\t/,$inter;
	my $coords = "$elems[0]".":$elems[12]"."-$elems[13]";
	if (exists $inter{$coords})
	{
		$inter_dup{$coords} = $inter{$coords};
	}
	$inter{$coords} = $inter;
}


foreach my $win (@windows)
{
	chomp $win;
	my @elems = split /\t/,$win;
	my $coords = "$elems[0]".":$elems[12]"."-$elems[13]";
	my $start = $elems[12];
	my ($new_dist, $old_dist);
	if (exists $hash{$coords})
	{
		if ($elems[6] eq "+")
		{
			$new_dist = abs($elems[3] - $start);
		}
		else
		{
			$new_dist = abs($elems[4] - $start);
		}
		my @old_elems = split/\t/,$hash{$coords};
		if ($old_elems[6] eq "+")
		{
			$old_dist = abs($old_elems[3] - $start);
		}
		else
		{
			$old_dist = abs($old_elems[4] - $start);
		}
		if ($new_dist < $old_dist)
		{
			$hash{$coords} = $win;
		}
	}
	else
	{
		$hash{$coords} = $win;
	}
	if (exists $inter{$coords})
	{
		$hash{$coords} = $inter{$coords};
	}
}
open (OUT, ">$path2output" ) or die "Can't open $path2output for writing";
print OUT "DMR_coords\tGeneID\tGene_coords\tStrand\n";
foreach my $outdup (keys %inter_dup)
{
	my @elems = split/\t/,$inter_dup{$outdup};
	my $coords = "$elems[0]".":$elems[12]"."-$elems[13]";
	my ($waste,$id) = split/_/,$elems[1];
	print OUT "$coords\t$id\t$elems[2]\t$elems[6]\n";
}
foreach my $out (keys %hash)
{
	my @elems = split/\t/,$hash{$out};
	my $coords = "$elems[0]".":$elems[12]"."-$elems[13]";
	my ($waste,$id) = split/_/,$elems[1];
	print OUT "$coords\t$id\t$elems[2]\t$elems[6]\n";
}
close OUT;
#system "cut -f 2,7 hscpgTmp|sort -u >uniqueHscpgTmp";
#system "cut -d _ -f 3 uniqueHscpgTmp |cut -f 1 >$path2output";
