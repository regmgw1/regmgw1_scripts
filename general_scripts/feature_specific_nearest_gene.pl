#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
find nearest gene using dmrs from feature-specific dmr file
=head2 Usage

Usage: ./feature_specific_nearest_gene.pl path2alldmrs path2dmrs distance_threshold path2output

=cut

#################################################################
# feature_specific_nearest_gene.pl
#################################################################

use strict;
use DBI;

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./feature_specific_nearest_gene.pl path2alldmrs path2dmrs distance_threshold path2output\nPlease try again.\n\n\n";}

my $path2alldmrs = shift;
my $path2dmrs = shift;
my $distance_thresh = shift;
my $path2output = shift;

my (@dmrs, %can_hash, %alldmrs);

my $dbh = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";

open (OUT, ">$path2output") or die "Can't open $path2output for writing";

open (IN, "$path2dmrs" ) or die "Can't open $path2dmrs for reading";
while (my $line = <IN>)
{
	chomp $line;
	push @dmrs, $line;
}
close IN;

open (IN, "$path2alldmrs" ) or die "Can't open $path2alldmrs for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	$alldmrs{$elems[3]} = $elems[5];
}
close IN;


my %entrez_hash;

foreach my $dmr (@dmrs)
{
	my @dmr_inf = split/\t/,$dmr;
	my $dmr_chr = $dmr_inf[3];
	my $dmr_start = $dmr_inf[4];
	my $dmr_stop = $dmr_inf[5];
	my $close_start = 9999999999999999;
	my $close_stop = 9999999999999999;
	my $entrez_start = 0;
	my $entrez_stop = 0;
	my $in = 0;
	my $score = $alldmrs{$dmr_start};
	my (@start_data,@stop_data, $start_string, $stop_string,@in_data);
	my $sth0 = $dbh->prepare("SELECT entrez_id, start,stop FROM entrez_genes where chr = '$dmr_chr' and $dmr_stop >= start and $dmr_start <= stop")
		        or die "Couldn't prepare statement: " . $dbh->errstr;
	$sth0->execute()             # Execute the query
  		or die "Couldn't execute statement: " . $sth0->errstr;
 
  	while (@in_data = $sth0->fetchrow_array())
	{
		if (exists $entrez_hash{$in_data[0]})
		{
			next;
		}
		else
		{
			$entrez_hash{$in_data[0]} = 0;
			print OUT "$dmr_chr\t$dmr_start\t$dmr_stop\t$in_data[0]\t$in_data[1]\t$in_data[2]\tIN\t.\t$score\n";
			$in = 1;
		}
	}
	if ($in == 0)
	{
	my $sth1 = $dbh->prepare("SELECT entrez_id, start,stop,start-$dmr_stop AS Difference FROM entrez_genes where chr = '$dmr_chr' and strand = '+' and start-$dmr_stop > 0 ORDER By Difference LIMIT 1")
	       	        or die "Couldn't prepare statement: " . $dbh->errstr;
	$sth1->execute()             # Execute the query
  		or die "Couldn't execute statement: " . $sth1->errstr;
 
  	while (@start_data = $sth1->fetchrow_array())
	{
	    $close_start = $start_data[3];
	    $start_string = "$start_data[0]\t$start_data[1]\t$start_data[2]\t$start_data[3]\t+\t$score";
	    $entrez_start = $start_data[0];
	}
	my $sth2 = $dbh->prepare("SELECT entrez_id, start,stop,$dmr_start - stop AS Difference FROM entrez_genes where chr = '$dmr_chr' and strand = '-' and $dmr_start - stop > 0 ORDER By Difference LIMIT 1")
	      	        or die "Couldn't prepare statement: " . $dbh->errstr;
	$sth2->execute()             # Execute the query
  		or die "Couldn't execute statement: " . $sth2->errstr;
  	while (@stop_data = $sth2->fetchrow_array())
	{
	    $close_stop = $stop_data[3];
	    $stop_string = "$stop_data[0]\t$stop_data[1]\t$stop_data[2]\t$stop_data[3]\t-\t$score";
	    $entrez_stop = $stop_data[0];
	}
	if ($close_start <$distance_thresh || $close_stop <$distance_thresh)
	{
		if ($close_start <= $close_stop)
		{
			
			if (exists $entrez_hash{$entrez_start})
			{
				next;
			}
			else
			{
				$entrez_hash{$entrez_start} = 0;
				print OUT "$dmr_chr\t$dmr_start\t$dmr_stop\t$start_string\n";
			}
		}
		else
		{
			if (exists $entrez_hash{$entrez_stop})
			{
				next;
			}
			else
			{
				$entrez_hash{$entrez_stop} = 0;
				print OUT "$dmr_chr\t$dmr_start\t$dmr_stop\t$stop_string\n";
			}
		}
		
		
	}
	}
}
  	
close OUT;  			
$dbh->disconnect;
