#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Counts DMRs in different satellite types
=head2 Usage

Usage: ./dmrs_in_sats.pl sat_types_file path2sats path2dmrs

=cut

#################################################################
# dmrs_in_sats.pl
#################################################################

use strict;

unless (@ARGV ==3 ) {
        die "\n\nUsage:\n ./dmrs_in_sats.pl sat_types_file path2sats path2dmrs\nPlease try again.\n\n\n";}

my $sat_types = shift;
my $path2sats = shift;
my $path2file = shift;

my (%dmr, %sat);

open (IN, "$sat_types" ) or die "Can't open $sat_types for reading";
while (my $line = <IN>)
{
	chomp $line;
	$sat{$line} = 0;
}

open (IN, "$path2file" ) or die "Can't open $path2file for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	my $chr = $elems[0];
	my $start = $elems[1];
	my $stop = $elems[2];
	my $coords=$chr."_".$start."_".$stop;
	if (exists $dmr{$coords})
	{
		$dmr{$coords}++;
	}
	else
	{
		$dmr{$coords} = 1;
	}
}
close IN;
my $total = 0;
open (IN, "$path2sats" ) or die "Can't open $path2sats for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	my $coords = $elems[0]."_".$elems[3]."_".$elems[4];
	if (exists $dmr{$coords})
	{
		$sat{$elems[1]} += $dmr{$coords};
		$total += $dmr{$coords};
	}
}

foreach my $key (sort (keys(%sat)))
{
	print "$key\t$sat{$key}\n";
}

