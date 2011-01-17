#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
parses through useq matrix file (created by MRSS) and calculates some descriptive stats
=head2 Usage

Usage: ./useq_matrix_parse.pl path2matrix

=cut

#################################################################
# useq_matrix_parse.pl
#################################################################

use strict;
use List::Util qw(sum);
use Statistics::Descriptive;

unless (@ARGV ==1) {
        die "\n\nUsage:\n ./useq_matrix_parse.pl path2matrix\nPlease try again.\n\n\n";}

my $path2matrix = shift;

my @length;
my $total_length = 0;
my $old_chrom = "no";
my $old_stop = 0;
my $count = 0;
open (IN, "$path2matrix" ) or die "Can't open $path2matrix for reading";
while (my $line = <IN>)
{
	$count++;
	my @elems = split /\t/,$line;
	my $tmp = $elems[0];
	my @coords = split /:/, $tmp;
	my $length = ($coords[2] - $coords[1]) + 1;
	push @length, $length;
	my $winLength;
	if ($coords[0] eq $old_chrom)
	{
		if ($coords[1] < $old_stop)
		{
			if ($coords[2] < $old_stop)
			{
				die "Error - How can this possibly be!!!!\n";
			}
			$winLength = ($coords[2] - $old_stop) + 1;
		}
		else
		{
			$winLength = ($coords[2] - $coords[1]) + 1;
		}
	}
	else
	{
		$winLength = ($coords[2] - $coords[1]) + 1;
	}
	$total_length += $winLength;
	$old_chrom = $coords[0];
	$old_stop = $coords[2];
}
print "Covered = $total_length\n";

my $average = sum(@length)/@length;
print "$average\n";

my $stat = Statistics::Descriptive::Full->new();
$stat->add_data(@length); 

my $mean = $stat->mean();
my $var  = $stat->variance();
my $tm   = $stat->trimmed_mean(.25);
my $std  = $stat->standard_deviation();

print "$mean\t$var\t$tm\t$std\n";


