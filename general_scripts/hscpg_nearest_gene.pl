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

unless (@ARGV ==6) {
        die "\n\nUsage:\n ./hscpg_nearest_gene.pl path2hscpg path2genes path2output upstream_threshold downstream_threshold peak_threshold\nPlease try again.\n\n\n";}

my $path2hscpg = shift;
my $path2genes = shift;
my $path2output = shift;
my $up = shift;
my $down = shift;
my $peak_threshold = shift;

my %hash;
my %inter;
my %inter_dup;

# use peak threshold to create tmp file of relevant hsCpGs
my $time = time();
my $hscpg_in = "$path2output"."tmp_hsCpG$time.tmp";
open (TMP, ">$hscpg_in") or die "Can't open $hscpg_in for writing";
open (DMR, $path2hscpg) or die "Can't open $path2hscpg for reading";
while (my $dmr = <DMR>)
{
	chomp $dmr;
	my @elems = split/\t/, $dmr;
	if ($elems[4] >= $peak_threshold)
	{
		print TMP "$dmr\n";
	}
}
close TMP; 

my @intersect = `intersectBed -a $path2genes -b $hscpg_in -wa -wb`;
my @windows = `windowBed -a $path2genes -b $hscpg_in -l $up -r $down -sw`;

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
open (OUT, ">$path2output/filtered_hsCpG$peak_threshold"."_nearest_protein_$up"."_$down".".txt" ) or die "Can't open $path2output/filtered_hsCpG$peak_threshold"."_nearest_protein_$up"."_$down".".txt for writing";
open (OUTV, ">$path2output/filtered_hsCpG$peak_threshold"."_nearest_protein_$up"."_$down"."_verbose.txt" ) or die "Can't open $path2output/filtered_hsCpG$peak_threshold"."_nearest_protein_$up"."_$down"."_verbose.txt for writing";
my %outHash;
open (TMP, "hscpgTmp" ) or die "Can't open hscpgTmp for reading";
while (my $line = <TMP>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	my $tmp_gene = $elems[1];
	if ($tmp_gene =~m/(ENSG\d+)/)
	{
		my $id = $1;
		print OUTV "$elems[9]\t$elems[10]\t$elems[11]\t$elems[13]\t$id\n";
		if (exists $outHash{$id})
		{
			next;
		}
		else
		{
			print OUT "$id\n";
			$outHash{$id} = 0;
		}
	}
	
}
close TMP; 
close OUT;
close OUTV;
#system "cut -f 2,7 hscpgTmp|sort -u >uniqueHscpgTmp";
#system "cut -d _ -f 3 uniqueHscpgTmp |cut -f 1 >$path2output";
#system "cut -f 10,11,12,14,2 hscpgTmp|cut -d _ -f 3,4,5,6,7 >$path2output";
unlink ("hscpgTmp","uniqueHscpgTmp", "$hscpg_in");
