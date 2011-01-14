#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Add batscore to end of each line in CpG matrix
=head2 Usage

Usage: ./cpg_feature_matrix_bat_merge.pl path2features_mat path2batcpg path2output
 
=cut

#################################################################
# cpg_feature_matrix_bat_merge.pl
#################################################################

use strict;
use File::Basename;

unless (@ARGV ==3 ) {
        die "\n\nUsage:\n ./cpg_feature_matrix_bat_merge.pl path2features_mat path2batcpg path2output\nPlease try again.\n\n\n";}

my $path2file1 = shift;
my $path2file2 = shift;
my $path2output = shift;

my $count = 1;

my %file2_hash;

open (OUT, ">$path2output") or die "Can't open $path2output for writing";

open (IN, "$path2file2" ) or die "Can't open $path2file2 for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	$file2_hash{$elems[3]} = $elems[5];
}
close IN;

open (IN, "$path2file1" ) or die "Can't open $path2file1 for reading";
while (my $line = <IN>)
{
	chomp $line;
	my $match = 0;
	if ($count == 1)
	{
		print OUT "$line\tBatman\n";
		$match =1;
	}
	else
	{
		my @elems = split/\t/, $line;
		
		if (exists $file2_hash{$elems[1]})
		{
			print OUT "$line\t$file2_hash{$elems[1]}\n";
			$match = 1;
		}
		
	}
	$count++;
	if ($match == 0)
	{
		print "MISSING: $line\n";
	}
}
close IN;
close OUT;		
		
		
		
		
