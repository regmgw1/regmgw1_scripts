#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Obtain batscore across feature type
=head2 Usage

Usage: ./bat_score_across_individual_features.pl feature_db feature limit path2output

=cut

#################################################################
# bat_score_across_individual_features.pl
#################################################################

use strict;
use DBI;
use Math::Round qw(:all);

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./bat_score_across_individual_features.pl feature_db feature limit path2output\nPlease try again.\n\n\n";}

my $feature_db = shift;
my $feature = shift;
my $limit = shift;
my $path2output = shift;

my $dbh_c = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";
                                       
my $dbh_n = DBI->connect("DBI:mysql:database=db2;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";

my $dbh_b = DBI->connect("DBI:mysql:database=db3;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";
                                       


my $dbh = DBI->connect("DBI:mysql:database=$feature_db;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";
                                       
my $sth = $dbh->prepare("SELECT chr,start, stop FROM `$feature` ORDER BY RAND() LIMIT $limit")
    		or die "Couldn't prepare statement: " . $dbh->errstr;
$sth->execute()             # Execute the query
	or die "Couldn't execute statement: " . $sth->errstr;
	
while (my @temp = $sth->fetchrow_array())
{
	my %hash;
	print "$temp[0]\t$temp[1]\t$temp[2]\n";
	open (OUT, ">$path2output/$feature"."_$temp[0]"."_$temp[1]".".txt") or die "Can't open $path2output for writing";
	my $start = $temp[1];
	my $stop = $temp[2];
	my $mod = 0;
	my $feature_length = $stop - $start;
	if ($feature_length < 2000)
	{
		$mod = (2000 - $feature_length)/2;
	}
	my $window_start = nlowmult(100, $start-$mod) + 1;
	my $window_stop = nhimult(100, $stop+$mod);	
	my $sth_c = $dbh_c->prepare("SELECT chr, start, stop,score FROM `batman_output` where start >=$window_start and stop <= $window_stop and chr = '$temp[0]'")
    		or die "Couldn't prepare statement: " . $dbh_c->errstr;
	$sth_c->execute()             # Execute the query
		or die "Couldn't execute statement: " . $sth_c->errstr;
	while (my @can = $sth_c->fetchrow_array())
	{
		my $coords = "$can[0]"."_$can[1]";
		$hash{$coords} = "$can[0]\t$can[1]\t$can[2]\t$can[3]";
	}
	
	my $sth_n = $dbh_n->prepare("SELECT chr, start, stop,score FROM `batman_output` where start >=$window_start and stop <= $window_stop and chr = '$temp[0]'")
    		or die "Couldn't prepare statement: " . $dbh_n->errstr;
	$sth_n->execute()             # Execute the query
		or die "Couldn't execute statement: " . $sth_n->errstr;
	while (my @norm = $sth_n->fetchrow_array())
	{
		my $coords = "$norm[0]"."_$norm[1]";
		$hash{$coords} .= "\t$norm[3]";
	}
	
	my $sth_b = $dbh_b->prepare("SELECT chr, start, stop,score FROM `batman_output` where start >=$window_start and stop <= $window_stop and chr = '$temp[0]'")
    		or die "Couldn't prepare statement: " . $dbh_b->errstr;
	$sth_b->execute()             # Execute the query
		or die "Couldn't execute statement: " . $sth_b->errstr;
	while (my @ben = $sth_b->fetchrow_array())
	{
		my $coords = "$ben[0]"."_$ben[1]";
		$hash{$coords} .= "\t$ben[3]";
	}
	foreach my $key (sort(keys(%hash)))
	{
		print OUT "$hash{$key}\n";
	}
	close OUT;
}


$dbh->disconnect;
$dbh_c->disconnect;
$dbh_b->disconnect;
$dbh_n->disconnect;
