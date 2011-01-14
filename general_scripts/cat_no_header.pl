#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
adds all lines, except the first, from one file to another
=head2 Usage

Usage: ./cat_no_header.pl path2new path2old

=cut

#################################################################
# cat_no_header.pl
#################################################################

use strict;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./cat_no_header.pl path2new path2old\nPlease try again.\n\n\n";}

my $path2new = shift;
my $path2old = shift;
my $count = 0;
open (OUT, ">>$path2old") or die "Can't open $path2old for writing";
open (NEW, "$path2new" ) or die "Can't open $path2new for reading";
while (my $line = <NEW>)
{
	if ($count > 0)
	{
		print OUT "$line";
	}
	$count++;
}
close OUT;
close NEW;
