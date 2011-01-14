#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Obtain coordinates from gff file and print in bed format: chr	start	stop
This file can then be run through liftover. The output of liftover then needs to be converted back into the original gff format.

=head2 Usage

Usage: ./gff_to_bed_for_liftover.pl path2input path2output

=cut

#################################################################
# gff_to_bed_for_liftover.pl 
# Obtain coordinates from gff file and print in bed format:
# chr	start	stop
# This file can then be run through liftover. The output of liftover then needs to be converted back into the original gff format.
# 
# UNFINISHED
#################################################################
use strict;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./gff_to_bed_for_liftover.pl path2input path2output\nPlease try again.\n\n\n";}

my $path2input = shift;
my $path2output = shift;

my $count = 0;

open (OUT, ">$path2output") or die "Can't write out: $!";

open (IN, "$path2input" ) or die "Can't open $path2input for reading";
while (my $line = <IN>)
{
	if ($count == 0)
	{
		$count++;
		next;
	}
	$count++;
	my @elems = split/\t/, $line;
	my $chr = "chr".$elems[0];
	#my $start = $elems[3];
	#my $stop = $elems[4];
	my $start = $elems[1];
	my $stop = $elems[1] + 1;
	print OUT "$chr\t$start\t$stop\t$count\n";
}
close IN;
close OUT;
