#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
reads in pippy format gff file, modifies so suitable for FindPeaks and uses SortFiles.jar to create the sorted zipped gff file for input to FP4. 
Also removes the intermediate gff file
=head2 Usage

Usage: ./gff4FindPeaks.pl path2file path2output

=cut

#################################################################
# gff4FindPeaks.pl - reads in pippy format gff file, modifies so suitable for FindPeaks and uses
# SortFiles.jar to create the sorted zipped gff file for input to FP4. Also removes the intermediate gff file
#################################################################

use strict;
use File::Basename;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./gff4FindPeaks.pl path2file path2output\nPlease try again.\n\n\n";}

my $path2file = shift;
my $path2output = shift;


my $base_gff = basename($path2file);
open (OUT, ">$path2output/$base_gff"."_m") or die "Can't open $path2output/$base_gff"."_m for writing";

open (IN, "$path2file" ) or die "Can't open $path2file for reading";
while (my $line = <IN>)
{
	chomp $line;
	my $chr_line = "chr".$line;
	print OUT "$chr_line\n";
}
close IN;
close OUT;

system "java -jar /path/to/SortFiles.jar gff $path2output $path2output/$base_gff"."_m";
unlink "$path2output/$base_gff"."_m";
