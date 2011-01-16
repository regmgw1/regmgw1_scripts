#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
calculate average for each probe from matrix of microarray log values
=head2 Usage

Usage: ./mean_single_arrays.pl path2matrix type path2output

=cut

#################################################################
# mean_single_arrays.pl
#################################################################

use strict;
use File::Basename;

unless (@ARGV ==3 ) {
        die "\n\nUsage:\n ./mean_single_arrays.pl path2matrix type path2output\nPlease try again.\n\n\n";}

my $path2matrix = shift;
my $type = shift;
my $path2output = shift;

my (@columns);
my $count = 0;

open (OUT, ">$path2output") or die "Can't open $path2output for writing";
open (MAT, "$path2matrix" ) or die "Can't open $path2matrix for reading";
while (my $line = <MAT>)
{
	if ($count == 0)
	{
		my @elems = split/\t/, $line;
		my $type_count = 0;
		foreach my $elem (@elems)
		{
			if ($elem =~m/$type/)
			{
				push @columns, $type_count;
			}
			$type_count++;
		}
	}
	else
	{
		my @elems = split/\t/, $line;
		my $total = 0;
		foreach my $col (@columns)
		{
			$total = $total + $elems[$col];
		}
		my $type_number = @columns;
		my $mean = $total/$type_number;
		$mean = sprintf("%.2f", $mean);
		my @bits = split/_/,$elems[1];
		my ($chr, $start, $stop);
		if ($bits[0] =~m/^0(\d+)/)
		{
			$chr = $1;
		}
		else
		{
			$chr = $bits[0];
		}
		if ($bits[1] =~m/^0+(\d+)/)
		{
			$start = $1;
		}
		else
		{
			$start = $bits[1];
		}
		if ($bits[2] =~m/^0+(\d+)/)
		{
			$stop = $1;
		}
		else
		{
			$stop = $bits[2];
		}
		print OUT "$chr\tbatman\tmeth\t$start\t$stop\t$mean\t.\t.\ttype $type ; Desc mean_from_single_arrays\n";
	}
	$count++;
}
close MAT;
close OUT;
