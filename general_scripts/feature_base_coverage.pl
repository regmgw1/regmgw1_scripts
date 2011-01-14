#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
looks at sequence coveraqge across different feature types
=head2 Usage

Usage: ./feature_base_coverage.pl sgrDB feature_table_name path2output sample

=cut

#################################################################
# feature_base_coverage.pl
#################################################################

use strict;
use DBI;

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./full_base_coverage.pl sgrDB feature_table_name path2output sample\nPlease try again.\n\n\n";}

my $sgr_db = shift;
my $feature = shift;
my $path2output = shift;
my $sample = shift;

my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19);
my %read;
open (OUT, ">$path2output/$sample"."_$feature"."_coverage_count.txt") or die "Can't open $path2output for writing";
open (CUM, ">$path2output/$sample"."_$feature"."_coverage_cumul.txt") or die "Can't open $path2output for writing";
print OUT "Coverage\tBaseCount\n";
print CUM "Coverage\tCumulativeCount\n";
foreach my $chr (@chroms)
{
	my $count = 0;
	my $total_bases = 0;
	my (%is_starts,%is_stops);
	my $dbh = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";
	my $sth1 = $dbh->prepare("SELECT start,stop,id FROM $feature where chr = '$chr'")
       	       	 or die "Couldn't prepare statement: " . $dbh->errstr;
	$sth1->execute()             # Execute the query
	 	or die "Couldn't execute statement: " . $sth1->errstr;

	while (my @data = $sth1->fetchrow_array())
	{
		my $is_start = $data[0];
		my $is_stop = $data[1];
		my $f_id = $data[2];
		$is_starts{$f_id} = $is_start;
		$is_stops{$f_id} = $is_stop;
		my $ibases = $data[1] - $data[0];
		$total_bases +=$ibases;
	}
	
	$dbh->disconnect;
	my $dbhs = DBI->connect("DBI:mysql:database=$sgr_db;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";
	foreach my $id (keys %is_starts)
	{	
		my $sths = $dbhs->prepare("SELECT start,stop,depth FROM chrom_$chr where start <= $is_stops{$id} and stop >= $is_starts{$id}")
       	        		or die "Couldn't prepare statement: " . $dbhs->errstr;
		$sths->execute()             # Execute the query
			or die "Couldn't execute statement: " . $sths->errstr;
		while (my @sgr = $sths->fetchrow_array())
		{
			my $bases = $sgr[1] - $sgr[0];
			my $remove = 0;
			my $depth = $sgr[2];
			my $check = 0;
			if ($sgr[0] < $is_starts{$id})
			{
				$remove += $is_starts{$id} - $sgr[0];
			}
			if ($sgr[1] > $is_stops{$id})
			{
				$remove += $sgr[1] - $is_stops{$id};
			}
			my $actual_bases = $bases - $remove;
			if ($depth > 1000)
			{
				$depth = 1000;
			}
			if (exists $read{$depth})
			{
				$read{$depth} += $actual_bases + 1;
			}
			else
			{
				$read{$depth} = $actual_bases + 1;
			}
		}
	}
	$dbhs->disconnect;
	print "Total = $total_bases\n";
}	
	
foreach my $key (sort{$a<=>$b}(keys %read))
{
	print OUT "$key\t$read{$key}\n";
}
my $cumul = 0;
foreach my $key (sort{$b<=>$a}(keys %read))
{
	$cumul += $read{$key};
	print CUM "$key\t$cumul\n";
}

close OUT;
close CUM;

	
