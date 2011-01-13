#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
This script creates a gff file containing intergenic regions, using genes gff file as input
=head2 Usage

Usage: ./get_intergenic.pl path2genes path2output

=cut


#################################################################
# get_intergenic.pl
#################################################################

use strict;

unless (@ARGV ==2 ) {
        die "\n\nUsage:\n ./get_intergenic.pl path2genes path2output\nPlease try again.\n\n\n";}

my $path2genes = shift;
my $path2output = shift;
my %coords;
my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,'X','Y');
foreach my $chrom (@chroms)
{
	print "Chrom = $chrom\n";
	open (IN, "$path2genes/chr$chrom"."_gene".".gff" ) or die "Can't open $path2output/chr$chrom"."_gene".".gff for reading";

	open (OUT, ">$path2output/chr$chrom"."_intergenic".".gff" ) or die "Can't open $path2output/chr$chrom"."_intergenic".".gff for writing";
	
	while (my $line = <IN>)
	{
		my @elems = split/\t/, $line;
		$coords{$elems[3]} = 0; #start
		$coords{$elems[4]} = 1; # stop
	}
	my $state = 0;	
	my ($inter_e, $inter_s);
	foreach my $key (sort {$a<=>$b}(keys %coords))
	{
	        print "$key\t$coords{$key}\t$state\n";
	        if ($coords{$key} == 1)
	        {
	        	$inter_s = $key + 1;
	        	$state = 2;
	        }
	        elsif ($coords{$key} == 0)
	        {
	        	if ($state == 2)
	        	{
	        		$inter_e = $key - 1;
	        		print OUT "$chrom\tIntergenic_region\tchr$chrom".":$inter_s"."-$inter_e\t$inter_s\t$inter_e\t.\t-\t.\tNCBI36; get_intergenic.pl\n";
	        	}
	        	$state = 1;
	        }	
	}
	close OUT;
}
