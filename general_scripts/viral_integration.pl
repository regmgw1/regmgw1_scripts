#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Parses viral alignment files (aligned in single end form) to determine which fragments only have one end mapped. These read ids are stored in hash to be compared with the reads in the 
human alignment. Any matches are printed out.
=head2 Usage

Usage: ./viral_integration.pl path2viral_alignment1 path2viral_alignment2 path2humanAlignment

=cut

#################################################################
# viral_integration.pl
#################################################################

#use strict;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./viral_integration.pl path2viral_alignment1 path2viral_alignment2 path2humanAlignment\nPlease try again.\n\n\n";}

my $path2viral1 = shift;
my $path2viral2 = shift;
my $path2human = shift;

my (@viral1, @viral2, %count, %diff);

open (IN, "$path2viral1" ) or die "Can't open $path2viral1 for reading";
while (my $line = <IN>)
{
	my @elems = split/\t/,$line;
	push @viral1, $elems[0];
}
close IN;
open (IN, "$path2viral2" ) or die "Can't open $path2viral2 for reading";
while (my $line = <IN>)
{
	my @elems = split/\t/,$line;
	push @viral2, $elems[0];
}
close IN;

foreach my $e (@viral1, @viral2)
{
	$count{$e}++;
}
foreach my $e (keys %count)
{
	if ($count{$e} < 2)
	{
		$diff{$e} = 0;
		#print "$e\n";
	}
}

open (IN, "$path2human" ) or die "Can't open $path2human for reading";
while (my $line = <IN>)
{
	my @elems = split/\t/,$line;
	if (exists $diff{$elems[0]})
	{
		print "$line";
	}
}

