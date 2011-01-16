#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Determine number of missing lines in one file compared with another, based on ids in given column
=head2 Usage

Usage: ./missing_lines.pl path2normal path2missing path2output id_tab

=cut

#################################################################
# missing_lines.pl
#################################################################

use strict;

unless (@ARGV ==4 ) {
        die "\n\nUsage:\n ./missing_lines.pl path2normal path2missing path2output id_tab\nPlease try again.\n\n\n";}

my $path2normal = shift;
my $path2missing = shift;
my $path2output = shift;
my $id_tab = shift;

my %little_hash;
my $righteous_count = 0;
my $missing_count = 0;

open (OUT, ">$path2output") or die "Can't open $path2output for writing";

open (MIS, "$path2missing" ) or die "Can't open $path2missing for reading";
while (my $line = <MIS>)
{
	my @elems = split/\t/,$line;
	$little_hash{$elems[$id_tab]} = 0;
	print "$elems[$id_tab]\n";
}
close MIS;

open (IN, "$path2normal" ) or die "Can't open $path2normal for reading";
while (my $line = <IN>)
{
	 my @elems = split/\t/,$line;
	 my $normal_id = $elems[$id_tab];
	 if (exists $little_hash{$normal_id})
	 {
	 	$righteous_count++;
	 }
	 else
	 {
	 	print OUT "$line";
	 	$missing_count++;
	 }
}
close IN;

print "righteous count = $righteous_count\nmissing_count = $missing_count\n";
close OUT;
