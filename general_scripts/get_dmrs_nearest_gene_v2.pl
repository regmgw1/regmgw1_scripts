#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
find nearest gene using dmrs from dmr files
=head2 Usage

Usage: ./dmrs_nearest_gene.pl path2can path2norm threshold hyper (0 or 1) path2output

=cut

#################################################################
# get_dmrs_nearest_gene.pl
#################################################################

use strict;
use DBI;

unless (@ARGV ==5) {
        die "\n\nUsage:\n ./get_dmrs_nearest_gene.pl path2can path2norm threshold hyper (0 or 1) path2output\nPlease try again.\n\n\n";}

my $path2can = shift;
my $path2norm = shift;
my $threshold = shift;
my $hyper = shift;
my $path2output = shift;

my (@dmrs, %can_hash);

my $dbh = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";

open (OUT, ">$path2output") or die "Can't open $path2output for writing";

open (IN, "$path2can" ) or die "Can't open $path2can for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	my $coords = $elems[0]."_".$elems[1];
	$can_hash{$coords} = $elems[3];
}
close IN;

open (IN, "$path2norm" ) or die "Can't open $path2norm for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	my $coords = $elems[0]."_".$elems[1];
	if (exists $can_hash{$coords})
	{
		if ($hyper == 1)
		{
			if ($can_hash{$coords} - $elems[3] >= 30)
			{ 
				my $diff = $can_hash{$coords} - $elems[3];
				$coords = $coords."_".$diff;
				push @dmrs, $coords;
			}
		}
		elsif ($hyper == 0)
		{
			if ($elems[3] - $can_hash{$coords} >= 30)
			{
				my $diff = $elems[3] - $can_hash{$coords};
				$coords = $coords."_".$diff;
				push @dmrs, $coords;
			}
		}
		else
		{
			die "Set hyper as 1 for hyper cancer dmrs, 0 for hypo cancer dmrs";
		}
	}
	else
	{
		print "MISSING: $line\n";
	}
}
close IN;

foreach my $dmr (@dmrs)
{
	my @dmr_inf = split/_/,$dmr;
	my $dmr_chr = $dmr_inf[0];
	my $dmr_start = $dmr_inf[1];
	my $dmr_diff = $dmr_inf[2];
	my $dmr_mid = $dmr_start + 500;
	my $close_start = 9999999999999999;
	my $close_stop = 9999999999999999;
	my (@start_data,@stop_data, $start_string, $stop_string);
	my $sth1 = $dbh->prepare("SELECT entrez_id, start,stop,start-$dmr_mid AS Difference FROM entrez_genes where chr = '$dmr_chr' and strand = '+' and start-$dmr_mid > 0 ORDER By Difference LIMIT 1")
       	        or die "Couldn't prepare statement: " . $dbh->errstr;
	$sth1->execute()             # Execute the query
  		or die "Couldn't execute statement: " . $sth1->errstr;
  	while (@start_data = $sth1->fetchrow_array())
	{
	    $close_start = $start_data[3];
	    $start_string = "$start_data[0]\t$start_data[1]\t$start_data[2]\t$start_data[3]\t+\t$dmr_diff";
	}
	my $sth2 = $dbh->prepare("SELECT entrez_id, start,stop,$dmr_mid - stop AS Difference FROM entrez_genes where chr = '$dmr_chr' and strand = '-' and $dmr_mid - stop > 0 ORDER By Difference LIMIT 1")
       	        or die "Couldn't prepare statement: " . $dbh->errstr;
	$sth2->execute()             # Execute the query
  		or die "Couldn't execute statement: " . $sth2->errstr;
  	while (@stop_data = $sth2->fetchrow_array())
	{
	    $close_stop = $stop_data[3];
	    $stop_string = "$stop_data[0]\t$stop_data[1]\t$stop_data[2]\t$stop_data[3]\t-\t$dmr_diff";
	}
	if ($close_start <3000 || $close_stop <3000)
	{
		if ($close_start <= $close_stop)
		{
			print OUT "$dmr_chr\t$dmr_start\t$start_string\n";
		}
		else
		{
			print OUT "$dmr_chr\t$dmr_start\t$stop_string\n";
		}
	}
	
}
  	
close OUT;  			
$dbh->disconnect;
