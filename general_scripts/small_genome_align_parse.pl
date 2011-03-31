#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Go through alignment file and count number of different ref ids mapped
=head2 Usage

Usage: ./small_genome_align_parse.pl path2alignment path2species_nc_index pattern_match (e.g. NC_00)

=cut

#################################################################
# small_genome_align_parse.pl 
# Go through alignment file and count number of different ref ids mapped
#################################################################

use strict;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./small_genome_merge.pl path2alignment path2species_nc_index pattern_match (e.g. NC_0\\d{5})\nPlease try again.\n\n\n";}
        
my $path2align = shift;
my $path2ncSpecies = shift; #viral_nc_index.list
my $pattern = shift;

my (%hash,%index);

print STDERR "Pattern = $pattern\n";

open (IND, "$path2ncSpecies" ) or die "Can't open $path2ncSpecies for reading";
while (my $index = <IND>)
{
	chomp $index;
	my @elems = split/\t/,$index;
	$index{$elems[1]} = $elems[0];
}
close IND;
open (IN, "$path2align" ) or die "Can't open $path2align for reading";
while (my $line = <IN>)
{
	my @ncs = $line =~m/$pattern/g;
	my %tmp;
	foreach my $nc (@ncs)
	{
		if (exists $tmp{$nc})
		{
			next;
		}
		else
		{
			if (exists $hash{$nc})
			{
				$hash{$nc}++;
			}
			else
			{
				$hash{$nc} = 1;
			}
			$tmp{$nc} = 1;
		}
	}
}
close IN;
foreach my $key (sort hashValueDescendingNum (keys %hash))
{
	print "$index{$key}\t$key\t$hash{$key}\n";
}

sub hashValueDescendingNum {
   $hash{$b} <=> $hash{$a};
}

