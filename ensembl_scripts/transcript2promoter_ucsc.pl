#!/usr/bin/perl -w

#################################################################
# transcript2promoter_ucsc.pl 
#################################################################

use strict;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./transcript2promoter.pl path2transcript path2output versionID\nPlease try again.\n\n\n";}

my $path2data = shift; #~/ucsc_transcriptID.txt
my $path2output = shift;
my $version_id = shift;

open (OUT, ">$path2output/trans_proms_ucsc.gff" ) or die "Can't open $path2output for writing";

my $count = 0;

open (IN, "$path2data" ) or die "Can't open $path2data for reading";
while (my $line = <IN>)
{
	if ($count > 0)
	{
		chomp $line;
		my ($p_start, $p_stop);
		my @elems = split/\t/,$line;
		my $start = $elems[3];
		my $stop = $elems[4];
		my $strand = $elems[2];
		my $id = $elems[0];
		my $chr = $elems[1];
		if ($strand eq "+")
		{
			$p_start = $start - 1000;
			$p_stop = $start + 500;
		}
		elsif ($strand eq "-")
		{
			$p_stop = $stop + 1000;
			$p_start = $stop - 500;
		}
		else
		{
			print "ERROR! World will end!!!!\n";
		}
		print OUT "$chr\t$id\t$chr".":$p_start"."-$p_stop\t$p_start\t$p_stop\t.\t$strand\t.\t$version_id;transcript2promoter_ucsc.pl\n";
	}
	$count++;
}
close IN;
close OUT;
