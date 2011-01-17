#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
parse multiple gff files into single matrix
=head2 Usage

Usage: ./singlearrays2matrix.pl path2expts path2files path2output

=cut

#################################################################
# singlearrays2matrix.pl
#################################################################

use strict;
use File::Basename;

unless (@ARGV ==3 ) {
        die "\n\nUsage:\n ./singlearrays2matrix.pl path2expts path2files path2output\nPlease try again.\n\n\n";}

my $path2expts = shift;
my $path2files = shift;
my $path2output = shift;

my (%grand_hash, @start, @grand_array);

my $count = 1;



open (IN, "$path2expts" ) or die "Can't open $path2expts for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @bits = split/\t/, $line;
	my $expt = $bits[0];
	open (EXP, "$path2files/$expt"."_miss_rem.gff" ) or die "Can't open $path2files/$expt"."_miss_rem.gff for reading";
	push @grand_array, "$bits[2]"."_$bits[0]";
	while (my $data = <EXP>)
	{
		if ($data =~m/\#/)
		{
			next;
		}
		else
		{
			chomp $data;
			my @elems = split/\t/, $data;
			my $coord = $elems[0]."_".$elems[3]."_".$elems[4];
			$grand_hash{$coord}{$line} = $elems[5];
			if ($count == 1)
			{
				push @start, $elems[3];
			}
			
		}
	}
	close EXP;
	$count++;
}
close IN;


open (OUT, ">$path2output") or die "Can't open $path2output for writing";
print OUT "Coords";
foreach my $head (sort @grand_array)
{
	print OUT "\t$head";
}
print OUT "\n";	

for my $top (sort(keys %grand_hash))
{
	print OUT "$top";
	for my $col_file(sort(keys %{$grand_hash{$top}}))
	{
		print OUT "\t$grand_hash{$top}{$col_file}";
		
	}
	print OUT "\n";
}
close OUT;		
