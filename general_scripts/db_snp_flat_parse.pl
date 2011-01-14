#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Part of the dbSNP passing script set - see anc_snp-selection_gw.pl
=head2 Usage

Usage: ./db_snp_flat_parse.pl path2flatfiles

=cut

#################################################################
# db_snp_flat_parse.pl
#################################################################

use strict;

unless (@ARGV ==1) {
        die "\n\nUsage:\n ./db_snp_flat_parse.pl path2flatfiles\nPlease try again.\n\n\n";}

my $path2files = shift;

my @chroms= (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,"X","Y");

foreach my $chrom (@chroms)
{
	my ($rs,$pos,$chr);
	my $ok = 0;
	open (IN, "$path2files/ds_flat_ch$chrom".".flat" ) or die "Can't open $path2files/ds_flat_ch$chrom".".flat for reading";
	while (my $line = <IN>)
	{
		if ($line =~m/^(rs\d+)/)
		{
			if ($ok != 0)
			{
				die "ERROR $rs\n";
			}
			else
			{
				$rs = $1;
				$ok = 1;
			}
		}
		elsif ($line =~m/^VAL/ && $ok == 1)
		{
			if ($line =~m/validated=YES/)
			{
				$ok = 2;
			}
			else
			{
				$ok = 0;
			}
		}
		elsif ($line =~m/^CTG/ && $ok == 2)
		{
			if ($line =~m/GRCh37/)
			{
				if ($line =~m/chr=(X|Y|\d{1,2})/)
				{
					$chr = $1;
					if ($line =~m/chr-pos=(\d+)/)
					{
						$pos = $1;
						$ok = 3;
					}
				}
			}
		}
		if ($ok == 3)
		{
			print "$rs\t$chr\t$pos\n";
			$ok = 0;
			$rs = "";
			$chr= "";
			$pos = "";
		}
	}
}
