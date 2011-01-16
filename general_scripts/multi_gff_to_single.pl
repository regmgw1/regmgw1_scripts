#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Obtain score values from multiple matrix files and print out in single matrix file
=head2 Usage

Usage: ./multi_giff_to_single.pl path2files path2output

=cut

#################################################################
# multi_gff_to_single.pl
#################################################################

use strict;
use File::Basename;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./multi_giff_to_single.pl path2files path2output\nPlease try again.\n\n\n";}

my $path2files = shift;
my $path2output = shift;

my @gff_files = <$path2files/*gff>;
my %king;
my @gffs;

foreach my $gff_file (@gff_files)
{
	print "file = $gff_file\n";
	my $base_gff = basename($gff_file);
	push @gffs, $base_gff;
	my $count = 0;
	open (IN, "$gff_file" ) or die "Can't open $path2files/$gff_file for reading";
	while (my $line = <IN>)
	{
		if ($count > 0)
		{
			my @elems = split/\t/,$line;
			my $string = "$elems[0]\t$elems[1]\t$elems[2]\t$elems[3]\t$elems[4]";
			$king{$string}{$base_gff} = $elems[5];
		}
		$count++;
	}
	close IN;
}

open (OUT, ">$path2output") or die "Can't open $path2output for writing";
print OUT "chr\t\t\tstart\tstop";
foreach my $title (@gffs)
{
	print OUT "\t$title";
}
print OUT "\n";       
for my $meta (sort(keys %king))
{
	print OUT "$meta";
	for my $col_file(sort(keys %{$king{$meta}}))
	{
		print OUT "\t$king{$meta}{$col_file}";
		
	}
	print OUT "\n";
}
close OUT;		
			
			
