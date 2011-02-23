#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Utilises bedTools to find overlaps between feature types and hscpgs at incrementally increasing cluster counts
=head2 Usage

Usage: /hscpg_in_features_bedtools.pl path2hscpgs path2featureList path2features max_cluster_number path2output

=cut

#################################################################
# hscpg_in_features_bedtools.pl
#################################################################

use strict;

unless (@ARGV ==5) {
        die "\n\nUsage:\n ./hscpg_in_features_bedtools.pl path2hscpgs path2featureList path2features max_peak_size path2output\nPlease try again.\n\n\n";}

my $path2hscpgs = shift;
my $path2list = shift;
my $path2feature = shift;
my $maxPeak = shift;
my $path2output = shift;

my (%hash);

open (OUT, ">$path2output") or die "Can't open $path2output for writing";
print OUT "Feature";
my $time = time();
for (my $i = 1;$i<=$maxPeak;$i++)
{
	print STDERR "$i\n";
	my $hscpg_in = "$path2output"."_tmp$time.tmp";
	open (TMP, ">$hscpg_in") or die "Can't open $hscpg_in for writing";
	open (DMR, $path2hscpgs ) or die "Can't open $path2hscpgs for reading";
	while (my $dmr = <DMR>)
	{
		$dmr =~s/chr//;
		my @elems = split/\t/, $dmr;
		if ($elems[4] eq ".")
		{
			print TMP "$dmr";
		}
		else
		{
			if ($elems[4] >= $i)
			{
				print TMP "$dmr";
			}
		}
	}
	close DMR;
	close TMP;
	open (IN, "$path2list" ) or die "Can't open $path2list for reading";
	while (my $line = <IN>)
	{
		print STDERR $line;
		chomp $line;
		#my $featureGff = "$path2feature/$line/$line".".gff";
		my $featureGff = "$path2feature/HARs/$line".".txt";
		my @count = `intersectBed -a $hscpg_in -b $featureGff -u`;
		#my @count = `intersectBed -a $hscpg_in -b $path2feature/cpg_island_subsets/$line"."gff -u`;
		my $out = $#count + 1;
		$hash{$line}{$i} = $out;
		undef(@count);
	}
	close IN;
	print OUT "\t$i";
	unlink ("$hscpg_in");
}
print OUT "\n";
foreach my $feat (sort(keys %hash))
{
	print OUT "$feat";
	foreach my $num (sort {$a<=>$b} (keys %{$hash{$feat}}))
	{
		print OUT "\t$hash{$feat}{$num}"
	}
	print OUT "\n";
}
close OUT; 


