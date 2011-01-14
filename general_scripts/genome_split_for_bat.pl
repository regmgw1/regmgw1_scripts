#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
spits out windows tiling across the genome (only human 36 at moment) if specified window size

=head2 Usage

Usage: ./genome_split_for_bat.pl fragment_size

=cut

#################################################################
# genome_split_for_bat.pl
#################################################################

use strict;

unless (@ARGV ==1 ) {
        die "\n\nUsage:\n ./genome_split_for_bat.pl fragment_size\nPlease try again.\n\n\n";}

my $length = shift;

my %end_chrom_hash = (
	1 => '247249719',
        2 => '242951149',
        3 => '199501827',
        4 => '191273063',
        5 => '180857866',
        6 => '170899992',
        7 => '158821424',
        8 => '146274826',
        9 => '140273252',
        10 => '135374737',
        11 => '134452384',
        12 => '132349534',
        13 => '114142980',
        14 => '106368585',
        15 => '100338915',
        16 => '88827254',
        17 => '78774742',
        18 => '76117153',
        19 => '63811651',
        20 => '62435964',
        21 => '46944323',
        22 => '49691432',
        X => '154913754',
        Y => '57772954',        
);


foreach my $key (keys(%end_chrom_hash))
{
	
	my $start = 1;
	my $over = 0;
	while ($over == 0)
	{
		my $stop = $start + $length - 1;
		if ($stop < $end_chrom_hash{$key})
		{
			print "$key\t$start\t$stop\n";
		}
		else
		{
			$stop = $end_chrom_hash{$key};
			print "$key\t$start\t$stop\n";
			$over = 1;
		}
		$start += $length;
	}
}
	
	
	
