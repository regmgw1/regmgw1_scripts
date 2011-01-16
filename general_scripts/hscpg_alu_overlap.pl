#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Utilises bedTools to find overlaps between feature types
=head2 Usage

Usage: ./hscpg_alu_overlap.pl path2hscpg path2featureList path2features path2output

=cut

#################################################################
# hscpg_alu_overlap.pl
#################################################################

use strict;

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./hscpg_alu_overlap.pl path2hscpg path2featureList path2features path2output\nPlease try again.\n\n\n";}

my $path2hscpg = shift;
my $path2list = shift;
my $path2feature = shift;
my $path2output = shift;

open (IN, "$path2list" ) or die "Can't open $path2list for reading";
while (my $line = <IN>)
{
	chomp $line;
	$line =~s/\(/\\(/;
	$line =~s/\)/\\)/;
	system "grep '$line\t' $path2feature >$path2output/tmp";
	my @count = `intersectBed -a $path2hscpg -b $path2output/tmp -wa -wb`;
	my $out = $#count + 1;
	print "$line\t$out\n";
}
close IN;


