#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
output metadata for each cpg-island
=head2 Usage

Usage: ./cpg_island_metadata.pl path2Islands path2cpgs chrom
 
=cut

#################################################################
# cpg_island_metadata.pl 
################################################################


use strict;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./cpg_island_metadata.pl path2Islands path2cpgs chrom\nPlease try again.\n\n\n";}

my $path2islands = shift;
my $path2cpgs= shift;
my $chrom = shift;

my %cpg;
open (IN, "$path2cpgs" ) or die "Can't open $path2cpgs for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	$cpg{$elems[3]} = $elems[4];
}
close IN;

print "chr\tstart\tstop\tlength\tcpg_count\tpercent_cpg\n";
open (IN, "$path2islands" ) or die "Can't open $path2islands for reading";
while (my $line = <IN>)
{
	chomp $line;
	my $cpg_count = 0;
	my @elems = split/\t/, $line;
	my $chr = $elems[1];
	# when dealing with ucsc file
	$chr =~s/chr//;
	if ($chr eq $chrom)
	{
	my $start = $elems[2];
	my $end = $elems[3];
	my $begin = $start;
	while ($begin <= $end)
	{
		if (exists $cpg{$begin})
		{
			$cpg_count++;
		}
		$begin++;
	}
	my $length = ($end - $start) + 1;
	my $perCpG = ($cpg_count * 2)/$length;
	print "$chr\t$start\t$end\t$length\t$cpg_count\t$perCpG\n";
	}
}
close IN;
