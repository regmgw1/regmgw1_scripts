#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
check output from legion submission to ensure all files have been processed
=head2 Usage

Usage: ./maf_parser_legion_submit.pl path2maf path2chromFile path2patterns (e.g. cg) path2output legionSubmissionFile

=cut

#################################################################
# maf_parser_legion_check.pl
################################################################

use strict;

unless (@ARGV ==6) {
        die "\n\nUsage:\n ./maf_parser_legion_submit.pl path2maf path2chromFile path2patterns (e.g. cg) path2output legionSubmissionFile\nPlease try again.\n\n\n";}

my $chromFile = shift;
my $patternFile = shift;
my $path2output = shift;
my $path2sub = shift;
my $path2maf = shift;
my $resubmit = shift;

my (%chash,%fhash);

my @files1 = <$path2output/human_primates*.txt>;
foreach my $out (@files1)
{
	$fhash{$out} = 0;;
}

open (CHROM, "$chromFile" ) or die "Can't open $chromFile for reading";
while (my $line = <CHROM>)
{
	chomp $line;
	my ($chrom,$mafs) = split/\t/,$line;
	$chash{$chrom} = $mafs;
}
close CHROM;
open (PAT, "$patternFile" ) or die "Can't open $patternFile for reading";
while (my $line = <PAT>)
{
	chomp $line;
	foreach my $chr_out (sort keys %chash)
	{
		my $i = 1;
		while ($i <= $chash{$chr_out})
		{
			my $string = "$path2output/human_primates_$line"."_miss_nogaps_chr$chr_out"."_maf_$i".".txt";
			if (!exists $fhash{$string})
			{
				print "$string\n";
				if ($resubmit == 1)
				{
					system "qsub -v path2maf=$path2maf,chrom=$chr_out,pattern=$line,maf_count=$i,output=$path2output $path2sub";
				}
			}
			$i++;
		}
	}
}
close PAT;
