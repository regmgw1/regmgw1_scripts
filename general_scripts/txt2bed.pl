#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
PArses through CpG txt file containing just chrom and start, adds stop and empty fields to create rudimentary bed file
=head2 Usage

Usage: ./txt2bed.pl path2input path2output

=cut

#################################################################
# txt2bed.pl
#################################################################

use strict;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./txt2bed.pl path2input path2output\nPlease try again.\n\n\n";}

my $path2input = shift;
my $path2output = shift;

open (OUT, ">$path2output" ) or die "Can't open $path2output for writing";
open (IN, "$path2input" ) or die "Can't open $path2input for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	my $stop = $elems[1] + 1;
	#print OUT "$line\t$stop\t.\t.\t.\n";
	print OUT "$elems[0]\t$elems[1]\t$stop\t.\t.\t.\n";
}
close IN;
close OUT;
	
