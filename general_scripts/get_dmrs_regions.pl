#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
determines the 10bat window dmrs based on a pre-calculated threshold, restricted to regions provided in seperate file. 
Currently needs to be run twice for each combination of samples - once to find hyper, then to find hypo. This should be changed in future.
=head2 Usage

Usage: ./get_dmrs_regions.pl path2regions path2can sample1 path2norm sample2 threshold hyper (0 or 1) path2output

=cut

#################################################################
# get_dmrs.pl
#################################################################

use strict;
use DBI;

unless (@ARGV ==8) {
        die "\n\nUsage:\n ./get_dmrs_regions.pl path2regions path2can sample1 path2norm sample2 threshold hyper (0 or 1) path2output\nPlease try again.\n\n\n";}

my $path2regions = shift;
my $path2can = shift;
my $sample1 = shift;
my $path2norm = shift;
my $sample2 = shift;
my $threshold = shift;
my $hyper = shift;
my $path2output = shift;

my (@dmrs, %can_hash);

open (OUT, ">$path2output") or die "Can't open $path2output for writing";

open (REG, "$path2regions" ) or die "Can't open $path2regions for reading";
while (my $line = <REG>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	open (IN, "$path2can/sample$sample1"."_$elems[0]"."_$elems[1]"."_$elems[2]"."_quant_dmr_1000.txt" ) or die "Can't open $path2can/sample$sample1"."_$elems[0]"."_$elems[1]"."_$elems[2]"."_quant_dmr_1000.txt for reading";
	while (my $line = <IN>)
	{
		chomp $line;
		my @elems = split/\t/, $line;
		my $coords = $elems[0]."_".$elems[1];
		$can_hash{$coords} = $elems[3];
	}
	close IN;

	open (IN, "$path2norm/sample$sample2"."_$elems[0]"."_$elems[1]"."_$elems[2]"."_quant_dmr_1000.txt" ) or die "Can't open $path2norm/sample$sample2"."_$elems[0]"."_$elems[1]"."_$elems[2]"."_quant_dmr_1000.txt for reading";
	while (my $line = <IN>)
	{
		chomp $line;
		my @elems = split/\t/, $line;
		my $coords = $elems[0]."_".$elems[1];
		if (exists $can_hash{$coords})
		{
			if ($hyper == 1)
			{
				if ($can_hash{$coords} - $elems[3] >= $threshold)
				{ 
					my $diff = $can_hash{$coords} - $elems[3];
					$coords = $coords."_".$diff;
					push @dmrs, $coords;
					print OUT "$elems[0]\tDMR\tchr$elems[0]".":$elems[1]"."-$elems[2]\t$elems[1]\t$elems[2]\t$diff\t.\t.\tDMR_cancer_normal_threshold$threshold"."_hyper\n";
				}
			}
			elsif ($hyper == 0)
			{
				if ($elems[3] - $can_hash{$coords} >= $threshold)
				{
					my $diff = $elems[3] - $can_hash{$coords};
					$coords = $coords."_".$diff;
					push @dmrs, $coords;
					print OUT "$elems[0]\tDMR\tchr$elems[0]".":$elems[1]"."-$elems[2]\t$elems[1]\t$elems[2]\t$diff\t.\t.\tDMR_cancer_normal_threshold$threshold"."_hypo\n";
				}
			}
			else
			{
				die "Set hyper as 1 for hyper cancer dmrs, 0 for hypo cancer dmrs";
			}
		}
		else
		{
			print "MISSING: $line\n";
		}
	}
	close IN;
}
close REG;	

  	
close OUT;  			
