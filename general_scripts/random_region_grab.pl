#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
takes output of genome_dmr.pl for two samples. Randomly selects x 1000bp regions and determines difference in batman score.
=head2 Usage

Usage: ./random_region_grab.pl length_of_random_region path2cancer path2norm path2output

=cut

#################################################################
# random_region_grab.pl - takes output of genome_dmr.pl for two samples. Randomly selects x 1000bp regions and determines difference in batman score.
#################################################################

use strict;

use Bio::EnsEMBL::Registry;
use lib 'elia_scripts/';
use Bio_MCE_Utils;
use Bio_MCE_Pipeline_Coding;
use Bio_MCE_ENSEMBL_Utils;
use Math::Round qw(:all);

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./random_region_grab.pl length_of_random_region path2cancer path2norm path2output\nPlease try again.\n\n\n";}

my $length = shift;
my $path2cancer = shift;
my $path2norm = shift;
my $path2output = shift;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
);
die ("Can't initialise registry") if (!$registry);
#$registry->set_disconnect_when_inactive();

my $specie = "Human";
my (%can_hash,%norm_hash,%win_hash);

# open the genome dmr files  for two samples. go through and store values in hash.

#sample1
open (IN, "$path2cancer" ) or die "Can't open $path2cancer for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	my $round_start = nlowmult(1000, $elems[1]) + 1;
	my $id = $elems[0]."_".$round_start;
	$can_hash{$id} = $elems[3];
}
close IN;
#sample2
open (IN, "$path2norm" ) or die "Can't open $path2norm for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	my $round_start = nlowmult(1000, $elems[1]) + 1;
	my $id = $elems[0]."_".$round_start;
	$norm_hash{$id} = $elems[3];
}
close IN;
open (OUT, ">$path2output") or die "Can't open $path2output for writing";

# use the get_random_noncoding_norepeat_noN method to grab regions from the genome. match thesse in the hashes and determine the difference in batscore.
my $j = 0;
while ($j <10)
{ 
	my $i = 0;
	while ($i <100)
	{
		my($slice,$chr,$start,$end) = Bio_MCE_Ensembl_Utils->get_random_noncoding_norepeat_noN($specie,$length);
		if ($chr eq "X" || $chr eq "Y")
		{
			next;
		}
		else
		{
			$start = nlowmult(1000, $start) + 1;
			my $id = $chr."_".$start;
			#print "$id\n";
			if (exists $can_hash{$id})
			{
				print "$id\n";
				my $diff = abs($can_hash{$id}-$norm_hash{$id});
				print OUT "$chr\t$start\t$can_hash{$id}\t$norm_hash{$id}\t$diff\n";
				$i++;
			}
		}
	}
	print "$j\n";
	$j++;
}
close OUT;
