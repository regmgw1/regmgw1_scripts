#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Randomly selects regions and prints to gff.
=head2 Usage

Usage: ./random_window_grab.pl length_of_random_region number_of_regions

=cut

#################################################################
# random_window_grab.pl - Randomly selects regions and prints to gff.
#################################################################

use strict;

use Bio::EnsEMBL::Registry;
use lib 'elia_scripts/';
use Bio_MCE_Utils;
use Bio_MCE_Pipeline_Coding;
use Bio_MCE_ENSEMBL_Utils;
use Math::Round qw(:all);

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./random_window_grab.pl length_of_random_region number_of_regions\nPlease try again.\n\n\n";}

my $length = shift;
my $num = shift;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
);
die ("Can't initialise registry") if (!$registry);
#$registry->set_disconnect_when_inactive();

my $specie = "Mouse";
my $i = 0;
while ($i < $num)
{
	my($slice,$chr,$start,$end) = Bio_MCE_Ensembl_Utils->get_random_slice($specie,$length);
	print "$chr\tRandomPeak\tchr$chr".":$start"."-$end\t$start\t$end\t.\t+\t.\trandom_$length"."_bp_region\n";
	$i++;
}


