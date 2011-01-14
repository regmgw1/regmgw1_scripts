#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
converts gff (pippy format) to wig
=head2 Usage

Usage: ./gff2wig.pl path2gff path2wig pippy|bat (0|1)

=cut

#################################################################
# gff2wig.pl - converts gff (pippy format) to wig
#################################################################

use strict;
use File::Basename;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./gff2wig.pl path2gff path2wig pippy|bat (0|1)\nPlease try again.\n\n\n";}

my $path2gff = shift;
my $path2wig = shift;
my $prog = shift;

open (WIG, ">$path2wig") or die "Can't write out: $!";

my $starter = 1;
my $count = 0;
open (IN, "$path2gff" ) or die "Can't open $path2gff for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	if ($prog == 0)
	{
		print WIG "fixedStep chrom=chr$elems[0] start=$elems[3] step=1\n$elems[5]\n$elems[5]\n";
	}
	elsif ($prog == 1)
	{
		if ($count > 0)
		{
			if ($starter + 100 == $elems[3])
			{
				print WIG "$elems[5]\n";
			}
			else
			{
				print WIG "fixedStep chrom=chr$elems[0] start=$elems[3] step=100 span=100\n$elems[5]\n";
			}
			$starter = $elems[3];
		}
		$count++;
	}
	else
	{
		die "Need to select pippy (0) or batman (1)\n";
	}
}
close IN;
close WIG;
