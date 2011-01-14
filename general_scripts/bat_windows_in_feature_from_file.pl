#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
obtain batscores across features. Would use bedTools now.
=head2 Usage

Usage: ./bat_windows_in_feature_from_file.pl feature_type path2data

=cut



#################################################################
# dmr_in_feature.pl
#################################################################

use strict;
use DBI;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./bat_windows_in_feature_from_file.pl feature_type path2data\nPlease try again.\n\n\n";}

my $path2repeat = shift;
my $path2data = shift;

my @chroms = (22,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21);
my @types;
open (IN, "$path2repeat" ) or die "Can't open $path2repeat for reading";
while (my $line = <IN>)
{
	chomp $line;
	push @types, $line;
}
close IN;

my $dbh2 = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";


foreach my $repeat (@types)
{
	my $count = 0;
	my %unique;
	open (IN, "$path2data" ) or die "Can't open $path2data for reading";
	while (my $line = <IN>)
	{
		my @data = split /\t/,$line;
		my $chr = $data[1];
		my $start = $data[2];
		my $stop = $data[3];
		my $feature_length = $stop - $start;
		my $coords = $chr."_".$start;
		if (exists $unique{$coords})
		{
			next;
		}
		else
		{
			$unique{$coords} = "";
		}
		my $ok = 0;
		my $region_count = 0;
		my $sth_er = $dbh2->prepare("SELECT id,chr,start,stop FROM chrom_$chr where start < $stop and stop > $start and chr = '$chr'")
	       	        or die "Couldn't prepare statement: " . $dbh2->errstr;
		$sth_er->execute()             # Execute the query
			or die "Couldn't execute statement: " . $sth_er->errstr;
		while (my @hyper = $sth_er->fetchrow_array())
		{
			# only count if >50% DMR found within region
			my $dmr_length = $hyper[3] - $hyper[2];
			if ($hyper[2] > $start && $hyper[3] > $stop)
			{
				my $overlap = $stop - $hyper[2];
				if ($overlap/$dmr_length > 0.5)
				{
					$ok = 1;
				}
				elsif ($feature_length < 500 && $overlap/$feature_length > 0.5)
				{
					$ok = 1;
				}
			}
			elsif ($hyper[2] < $start && $hyper[3] < $stop)
			{
				my $overlap = $hyper[3] - $stop;
				if ($overlap/$dmr_length > 0.5)
				{
					$ok = 1;
				}
				elsif ($feature_length < 500 && $overlap/$feature_length > 0.5)
				{
					$ok = 1;
				}
			}
			else
			{
				$ok = 1;
			}
			if ($ok == 1)
			{
				$count++;
			}
		}
	}
	print "$repeat\t$count\n";
	close IN;
}

$dbh2->disconnect;
		
