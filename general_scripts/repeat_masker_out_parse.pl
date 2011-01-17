#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
parses output from repeatmasker
=head2 Usage

Usage: ./repeat_masker_out_parse.pl path2repeat path2output repeat_family

=cut

#################################################################
# repeat_masker_out_parse.pl
#################################################################

use strict;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./repeat_masker_out_parse.pl path2repeat path2output repeat_family\nPlease try again.\n\n\n";}

my $path2filedir = shift;
my $path2output = shift;
my $family = shift;

my %repeats;
my @files = <$path2filedir/*.fasta.out>;
my $total_bases = 0;
foreach my $file (@files)
{
print "$file\n";
my $count = 0;
open (IN, "$file" ) or die "Can't open $file for reading";
while (my $line = <IN>)
{
	if ($count > 3)
	{	
		chomp $line;
		my @elems = split/\s+/, $line;
		my $bases = ($elems[7] - $elems[6]) + 1;
		if ($elems[11] eq $family)
		{
			
			if (exists $repeats{$elems[10]})
			{
				$repeats{$elems[10]} += $bases;
			}
			else
			{
				$repeats{$elems[10]} = $bases;
			}
		}
		$total_bases += $bases;
	}
	$count++;
}
close IN;
}
foreach my $key (keys(%repeats))
{
	print "$key\t$repeats{$key}\n";
}
print "\nTotal Bases\t$total_bases\n";
