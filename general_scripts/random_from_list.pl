#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
randomly selects from list
=head2 Usage

Usage: ./random_from_list.pl path2list number_required

=cut

#################################################################
# random_from_list.pl
#################################################################

use strict;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./random_from_list.pl path2list number_required\nPlease try again.\n\n\n";}

my $path2list = shift;
my $number = shift;

open (LIST, "$path2list" ) or die "Can't open $path2list for reading";
my @genes = <LIST>;
close LIST;

my $elements = $#genes;

for (my $i = 0;$i<$number;$i++)
{
	my $random = $genes[int(rand($elements))];
	chomp $random;
	print "$random\n";
}

