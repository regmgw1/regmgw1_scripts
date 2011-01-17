#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
processes random_region_grab.pl output to provide threshold info
=head2 Usage

Usage: ./random_dmra.pl path2random

=cut

#################################################################
# random_dmrs.pl - processes random_region_grab.pl output to provide threshold info
#################################################################

use strict;

unless (@ARGV ==1) {
        die "\n\nUsage:\n ./random_dmra.pl path2random\nPlease try again.\n\n\n";}

my $path2in = shift;

my @diff;

open (IN, "$path2in" ) or die "Can't open $path2in for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	push @diff, $elems[4];
}
for (my $i = 0;$i<101;$i++)
{
	my $count = 0;
	foreach my $diff (@diff)
	{
		if ($diff >= $i)
		{
			$count++;
		}
	}
	my $ratio = $count/@diff;
	print "$i\t$ratio\n";
}
