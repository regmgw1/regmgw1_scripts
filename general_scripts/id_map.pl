#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Looks for matching ids between files
=head2 Usage

Usage: ./id_map.pl id_list1 id_list2 path2output

=cut

#################################################################
# id_map.pl
#################################################################

use strict;

unless (@ARGV ==2 ) {
        die "\n\nUsage:\n ./id_map.pl id_list1 id_list2 path2output\nPlease try again.\n\n\n";}

my $path2file1 = shift;
my $path2file2 = shift;

my %file2_hash;

open (IN, "$path2file2" ) or die "Can't open $path2file2 for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	if ($#elems == 0)
	{
		$file2_hash{$elems[0]} = "NA";
	}
	else
	{
		$file2_hash{$elems[0]} = $elems[1];
	}
}
close IN;

open (IN, "$path2file1" ) or die "Can't open $path2file1 for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	if (exists $file2_hash{$elems[7]})
	{
		print "$line\t$file2_hash{$elems[7]}\n";
		
	}
	else
	{
		print "$line\tNA\n";
	}
}
close IN;
		
	
