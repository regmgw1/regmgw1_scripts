#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Counts matching ids between files
=head2 Usage

Usage: ./id_overlap.pl id_list1 id_list2

=cut

#################################################################
# id_overlap.pl
#################################################################

use strict;

unless (@ARGV ==2 ) {
        die "\n\nUsage:\n ./id_overlap.pl id_list1 id_list2\nPlease try again.\n\n\n";}

my $path2file1 = shift;
my $path2file2 = shift;

my %file2_hash;
my $match = 0;
my $count = 0;

open (IN, "$path2file2" ) or die "Can't open $path2file2 for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	$file2_hash{$elems[3]} = 0;

}
close IN;

open (IN, "$path2file1" ) or die "Can't open $path2file1 for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	if (exists $file2_hash{$elems[3]})
	{
		$match++;
	}
	$count++;	
	
}
close IN;
print "Count = $count\nOverlap = $match\n";		
		
		
		
