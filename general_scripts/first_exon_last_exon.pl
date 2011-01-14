#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
read through exon gff file and output first, last and inter exons into seperate files.
=head2 Usage

Usage: ./first_exon_last_exon.pl path2exons path2output gene_select?(0|path2list)

=cut

#################################################################
# first_exon_last_exon.pl 
#################################################################

use strict;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./first_exon_last_exon.pl path2exons path2output gene_select?(0|path2list)\nPlease try again.\n\n\n";}

my $path2exons = shift;
my $path2output = shift;
my $gene_select = shift;

my $max_line = 0;
my $max_pos = 1;
my $old_id = 0;
my $first_line;
my $single_count = 0;
my @genes;

open (FIRST, ">$path2output/low_001_first_exons.gff" ) or die "Can't open $path2output for writing";
open (INTER, ">$path2output/low_001_inter_exons.gff" ) or die "Can't open $path2output for writing";
open (LAST, ">$path2output/low_001_last_exons.gff" ) or die "Can't open $path2output for writing";

if ($gene_select ne "0")
{
	open (LIST, "$gene_select" ) or die "Can't open $gene_select for reading";
	@genes = <LIST>;
	close LIST;
}


open (IN, "$path2exons" ) or die "Can't open $path2exons for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	my $trans_id = $elems[0];
	my $ex_pos = $elems[5];
	my $ok = 1;
	if ($gene_select ne "0")
	{
		my $ens_id = $elems[7];
		my $match = 0;
		foreach my $gene (@genes)
		{
			chomp $gene;
			if ($gene =~m/$ens_id/)
			{
				$match = 1;
			}
		}
		if ($match == 0)
		{
			$ok = 0;
		}
	}
	if ($ok == 1)
	{
		my $gff = "$elems[2]\t$elems[0]"."_$elems[1]\tchr$elems[2]".":$elems[3]"."-$elems[4]\t$elems[3]\t$elems[4]\t.\t.\t.\tBiomart52";
		
		if ($trans_id eq $old_id)
		{
			if ($ex_pos == 1)
			{
				$first_line = $gff;
			}
			elsif ($ex_pos > $max_pos)
			{
				$max_pos = $ex_pos;
				if ($max_line ne "0")
				{
					print INTER "$max_line\n";
				}
				$max_line = $gff;
			}
			else
			{
				print INTER "$gff\n";
			}
		
		}
		else
		{
			if ($max_line ne "0")
			{
				print FIRST "$first_line\n";
				print LAST "$max_line\n";
			}
			else
			{
				$single_count++;
			}
			$old_id = $trans_id;
			$max_pos = 1;
			$max_line = 0;
			if ($ex_pos == 1)
			{
				$first_line = $gff;
			}
			elsif ($ex_pos > $max_pos)
			{
				$max_pos = $ex_pos;
				if ($max_line ne "0")
				{
					print INTER "$max_line\n";
				}
				$max_line = $gff;
			}
		}
	}
}
close IN;
close FIRST;
close INTER;
close LAST;	
print "singleton = $single_count\n";
