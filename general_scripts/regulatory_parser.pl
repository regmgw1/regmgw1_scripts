#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
parses output from ensembl regulatory build
=head2 Usage

Usage: ./regulatory_parser.pl path2regulatorydata path2output

=cut

#################################################################
# regulatory_parser.pl 
#################################################################
use strict;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./regulatory_parser.pl path2regulatorydata path2output\nPlease try again.\n\n\n";}

my $path2files = shift;
my $path2output = shift;

for (my $i=1; $i<=24; $i++)
{
    my $infile  = "";
    my $promfile = "";
    my $miscfile = "";
    my $chr     = "";
    my $start_count = 0;

    if ($i <= 22)
    {
	$infile  = "$path2files/chr".$i."_regulatory.gff";
	$promfile = "$path2output/chr".$i."_promoter.gff";
	$miscfile = "$path2output/chr".$i."_misc_reg.gff";
	$chr = $i;
    }
    elsif ($i == 23)
    {
	$infile  = "$path2files/chrX_regulatory.gff";
	$promfile = "$path2output/chrX_promoter.gff";
	$miscfile = "$path2output/chrX_misc_reg.gff";
	$chr = "X"
    }
    elsif ($i == 24)
    {
	$infile  = "$path2files/chrY_regulatory.gff";
	$promfile = "$path2output/chrY_promoter.gff";
	$miscfile = "$path2output/chrY_misc_reg.gff";
	$chr = "Y"
    }
                                       
	open (IN, "$infile" ) or die "Can't open $infile for reading";
	open (PRO, ">$promfile") or die "Can't open $promfile for writing";
	open (MISC, ">$miscfile") or die "Can't open $miscfile for writing";
	print "chr = $chr\n";
	while (my $line = <IN>)
	{
		my @elems = split/\t/, $line;
		my $type = $elems[1];
		if ($type =~m/Promoter/)
		{
			print PRO "$line";
		}
		else
		{
			print MISC "$line";
		}
	}
	close PRO;
	close MISC;
}
