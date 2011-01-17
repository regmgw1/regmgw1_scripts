#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
parses through unmapped data and outputs fasta file of unmapped sequences
=head2 Usage

Usage: ./unmapped_parser.pl path2unmapped path2output

=cut

#################################################################
# unmapped_parser.pl
#################################################################

use strict;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./unmapped_parser.pl path2unmapped path2output\nPlease try again.\n\n\n";}

my $path2data = shift;
my $path2output = shift;

open (OUT, ">$path2output") or die "Can't open $path2output for writing";
 
open (IN, "$path2data" ) or die "Can't open $path2data for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	print OUT ">$elems[0]\n$elems[2]\n";
}
close IN;
close OUT;
