#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
determine number of cpgs in repeat regions - see if get similar result to literature (51%, 25%alu)
=head2 Usage

Usage: ./cpg_sanity_check.pl path2matrixfiles
 
=cut

#################################################################
# cpg_sanity_check.pl 
# determine number of cpgs in repeat regions - see if get similar result to literature (51%, 25%alu)
#################################################################
use strict;

unless (@ARGV ==1) {
        die "\n\nUsage:\n ./cpg_coverage.pl path2matrixfiles\nPlease try again.\n\n\n";}

my $path2mat = shift;

my ($cpg, $alu, $repeat);

for (my $i=1;$i<=24;$i++)
{
	my $chr;
	if ($i == 23)
	{
		$chr = "X";
	}
	elsif ($i == 24)
	{
		$chr = "Y";
	}
	else
	{
		$chr = $i;
	}
	open (IN, "$path2mat/cpg_repeat_matrix_chr$chr".".txt" ) or die "Can't open $path2mat/cpg_repeat_matrix_chr$i".".txt for reading";
	while (my $line = <IN>)
	{
		chomp $line;
		my @elems = split/\t/, $line;
		if ($elems[3] > 0)
		{
			$alu++;
			$repeat++;
			$cpg++;
		}
		elsif ($elems[4] > 0 || $elems[5] > 0 ||$elems[6] > 0 ||$elems[7] > 0 ||$elems[8] > 0)
		{
			$repeat++;
			$cpg++;
		}
		else
		{
			$cpg++;
		}
	}
	close IN;
	print "Chr$chr\nTotal CpG's = $cpg\nTotal in Repeats = $repeat\nTotal in Alus = $alu\n";
}
print "Total CpG's = $cpg\nTotal in Repeats = $repeat\nTotal in Alus = $alu\n";
