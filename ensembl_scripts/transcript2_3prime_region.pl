#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
This script generates putative 3' regulatory region annotation files from transcript gff files
=head2 Usage

Usage: ./transcript2promoter.pl path2transcript path2output versionID chr

=cut

#################################################################
# transcript2_3prime_region.pl 
#################################################################

use strict;

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./transcript2_3prime_region.pl path2transcript path2output versionID chr\nPlease try again.\n\n\n";}

my $path2data = shift;
my $path2output = shift;
my $version_id = shift;
my $chr = shift;

open (OUT, ">$path2output/chr$chr"."_3_prime_reg.gff" ) or die "Can't open $path2output for writing";

open (IN, "$path2data" ) or die "Can't open $path2data for reading";
while (my $line = <IN>)
{
	chomp $line;
	my ($p_start, $p_stop);
	my @elems = split/\t/,$line;
	my $start = $elems[3];
	my $stop = $elems[4];
	my $strand = $elems[6];
	my $id = $elems[1];
	$id =~s/Transcript/Promoter/;
	if ($strand eq "+")
	{
		$p_start = $stop - 300;
		$p_stop = $stop + 1000;
	}
	elsif ($strand eq "-")
	{
		$p_start = $start - 1000;
		$p_stop = $start + 300;
	}
	else
	{
		print "ERROR! World will end!!!!\n";
	}
	print OUT "$chr\t$id\tchr$chr".":$p_start"."-$p_stop\t$p_start\t$p_stop\t.\t$strand\t.\t$version_id;transcript2_3prime_region.pl\n";
}
close IN;
close OUT;
