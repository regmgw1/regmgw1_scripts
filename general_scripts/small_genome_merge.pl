#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Go through file structure downloaded from ncbi and merge files to make single meta-genome file
=head2 Usage

Usage: ./small_genome_merge.pl path2fileroot path2output

=cut

#################################################################
# small_genome_merge.pl 
# Go through file structure downloaded from ncbi and merge files to make single meta-genome file
#################################################################

use strict;
use File::Basename;
use File::Cat;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./small_genome_merge.pl path2speciesList path2output\nPlease try again.\n\n\n";}
        
my $path2speciesList = shift;
my $path2output = shift;        

my $path2dir = dirname($path2speciesList);
my $count = 0;
my $fileC = 1;
print STDERR "$path2dir\n";
open (OUT, ">$path2output"."_$fileC") or die "Can't open $path2output"."_$fileC for writing";
open (IN, "$path2speciesList" ) or die "Can't open $path2speciesList for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @genomes = <$path2dir/$line/*.fna>;
	foreach my $genome (@genomes)
	{
		my $ncF = basename($genome);
		my @tmp = split/\./,$ncF;
		my $nc = $tmp[0];
		print "$line\t$nc\n";
		cat ($genome, \*OUT);
		$count++;
	}
	if ($count > 1000)
	{
		close OUT;
		$fileC++;
		$count = 0;
		open (OUT, ">$path2output"."_$fileC") or die "Can't open $path2output"."_$fileC for writing";
	}
		
}
close IN;
close OUT;
