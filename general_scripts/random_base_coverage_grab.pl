#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
select random regions of genome and find coverage, based on sgr data, for that region

=head2 Usage

Usage: ./random_base_coverage_grab.pl length sgr_db path2output

=cut

#################################################################
# random_region_grab.pl
#################################################################

use strict;

use Bio::EnsEMBL::Registry;
use lib 'elia_scripts/';
use Bio_MCE_Utils;
use Bio_MCE_Pipeline_Coding;
use Bio_MCE_ENSEMBL_Utils;
use Math::Round qw(:all);

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./random_base_coverage_grab.pl length sgr_db path2output\nPlease try again.\n\n\n";}

my $length = shift;
my $sgr_db = shift;
my $path2output = shift;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
);
die ("Can't initialise registry") if (!$registry);
#$registry->set_disconnect_when_inactive();

my $specie = "Human";

my $dbh = DBI->connect("DBI:mysql:database=$sgr_db;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";

open (OUT, ">$path2output") or die "Can't open $path2output for writing";
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
			my $sth = $dbh->prepare("SELECT stop-start,depth FROM chrom_$chr where start <= $end and stop >= $start")
       	        		or die "Couldn't prepare statement: " . $dbh->errstr;
			$sth->execute()             # Execute the query
				or die "Couldn't execute statement: " . $sth->errstr;
			while (my @sgr = $sth->fetchrow_array())
			{
				my $length = $sgr[0];
				my $depth = $sgr[1];
				my $k = 0;
				print "$chr\t$start\t$end\t$length\t$depth\n";
				while ($k <= $length)
				{
					print OUT "$depth\n";
					$k++;
				}
			}
			$i++;
		}
	}
	print "J = $j\n";
	$j++;
}
close OUT;
$dbh->disconnect;
