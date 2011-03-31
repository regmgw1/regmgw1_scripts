#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Count preceeding base for different peak heights
=head2 Usage

Usage: ./hscpg_prev_base.pl path2hscpgs max_cluster_number path2output

=cut

#################################################################
# hscpg_prev_base.pl
#################################################################

use strict;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./hscpg_prev_base.pl path2hscpgs max_peak_size path2output\nPlease try again.\n\n\n";}

my $path2hscpgs = shift;
my $maxPeak = shift;
my $path2output = shift;

open (OUT, ">$path2output") or die "Can't open $path2output for writing";
print OUT "Feature";
my %hash;
for (my $i = 1;$i<=$maxPeak;$i++)
{
	print STDERR "$i\n";
	open (DMR, $path2hscpgs ) or die "Can't open $path2hscpgs for reading";
	while (my $dmr = <DMR>)
	{
		chomp $dmr;
		my @elems = split/\t/, $dmr;
		if ($elems[4] eq ".")
		{
			if (exists $hash{$elems[5]}{$i})
			{
				$hash{$elems[5]}{$i}++;
			}
			else
			{
				$hash{$elems[5]}{$i} = 1;
			}
		}
		else
		{
			if ($elems[4] >= $i)
			{
				$hash{$elems[5]}{$i}++;				
			}
		}
	}
	close DMR;
	print OUT "\t$i";
}
print OUT "\n";
foreach my $base (sort(keys %hash))
{
	print OUT "$base";
	foreach my $num (sort {$a<=>$b} (keys %{$hash{$base}}))
	{
		print OUT "\t$hash{$base}{$num}"
	}
	print OUT "\n";
}
close OUT; 

