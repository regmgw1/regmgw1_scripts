#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
find contigous dmrs from file
=head2 Usage

Usage: ./contiguous_dmrs.pl dmr_file output

=cut

#################################################################
# contiguous_dmrs.pl
#################################################################

use strict;

unless (@ARGV ==2 ) {
        die "\n\nUsage:\n ./contiguous_dmrs.pl dmr_file output\nPlease try again.\n\n\n";}

my $path2dmrs = shift;
my $path2output = shift;

my $contig = 1;
my $old_stop = -10;
my $old_start = 0;
my %contig;

open (OUT, ">$path2output") or die "Can't open $path2output";  
open (IN, "$path2dmrs" ) or die "Can't open $path2dmrs for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	my $chr= $elems[0];
	my $start = $elems[3];
	my $stop = $elems[4];
	if ($start == $old_stop + 1)
	{
		$contig++;
		
	}
	else
	{
		print OUT "$chr\t$old_start\t$old_stop\t$contig\n";
				
		if (exists $contig{$contig})
		{
			$contig{$contig} = $contig{$contig} + 1;
		}
		else
		{
			$contig{$contig} = 1;
		}
		$contig = 1;
		$old_start = $start;
	}
	$old_stop = $stop;
}
foreach my $key (sort {$a<=>$b}(keys(%contig)))
{
	print "$key\t$contig{$key}\n";
}
close OUT;
