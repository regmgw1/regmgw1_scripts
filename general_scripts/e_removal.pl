#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Goes through gff file replaces e+? with the correct number of 0's. Also checks to make sure score doesn't equal 0. Unfinished?
=head2 Usage

Usage: ./e_removal.pl path2gff path2output

=cut

#################################################################
# e_removal.pl 
# Goes through gff file replaces e+? with the correct number of 0's. Also checks to make sure score doesn't equal 0.
# UNFINISHED
#################################################################

use strict;
use File::Basename;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./e_removal.pl path2gff path2output\nPlease try again.\n\n\n";}

my $path2gff = shift;
my $path2output = shift;

my @gff_files = <$path2gff/*gff>;
foreach my $gff_file (@gff_files)
{
	print "file = $gff_file\n";
	my $base_gff = basename($gff_file);
	open (OUT, ">$path2output/e_rem_$base_gff") or die "Can't open $path2output/e_rem_$base_gff for writing";
	open (IN, "$gff_file" ) or die "Can't open $path2gff/$gff_file for reading";
	while (my $line = <IN>)
	{
		if ($line =~m/^\#/)
		{
			print "$line\n";
			next;
		}
		my @elems = split/\t/, $line;
		my $start = $elems[3];
		my $stop = $elems[4];
		my $score = $elems[5];
		if ($start =~m/(\d+\.*\d*)e\+(\d+)/)
		{
			my $num = $1;
			my $mult = $2;
			$start = $num * (10**$mult);
		}
		if ($stop =~m/(\d+\.*\d*)e\+(\d+)/)
		{
			my $num = $1;
			my $mult = $2;
			$stop = $num * (10**$mult);
		}
		if ($score == 0)
		{
			$score = "0.000000001";
		}
		print OUT "$elems[0]\t$elems[1]\t$elems[2]\t$start\t$stop\t$score\t$elems[6]\t$elems[7]\t$elems[8]";
	}
	close IN;
	close OUT;
}
