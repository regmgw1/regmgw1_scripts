#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Determines if dmrs are expanding between conditions
=head2 Usage

Usage: ./expanding_dmrs.pl from_dmr_file to_dmr_file output

=cut

#################################################################
# expanding_dmrs.pl
#################################################################

use strict;
use DBI;

unless (@ARGV ==3 ) {
        die "\n\nUsage:\n ./expanding_dmrs.pl from_dmr_file to_dmr_file output\nPlease try again.\n\n\n";}

my $fromdmrs = shift;
my $todmrs = shift;
my $path2output = shift;

my $dbh = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";


$dbh->do("CREATE TABLE from_this (id int(7) NOT NULL AUTO_INCREMENT,
				chr varchar(2) NOT NULL,
				start int(10) NOT NULL,
				stop int(10) NOT NULL,
				size int(3) NOT NULL,
				PRIMARY KEY (id),
				KEY chr_index (chr),
				KEY start_index (start),
				KEY stop_index (stop)
                                     )");

open (IN, "$fromdmrs" ) or die "Can't open $fromdmrs for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	my $insert_handle = $dbh->prepare_cached("INSERT INTO from_this VALUES (id,?,?,?,?)"); 
			die "Couldn't prepare queries; aborting" unless defined $insert_handle;

	my $success = 1;
	$success &&= $insert_handle->execute($elems[0], $elems[1], $elems[2], $elems[3]);
	my $result = ($success ? $dbh->commit : $dbh->rollback);
	unless ($result)
	{ 
		die "Couldn't finish transaction: " . $dbh->errstr 
	}
}
close IN;

my $count = 0;
my $total_diff = 0;
my $max_diff = 0;
my $max_coords;

open (IN, "$todmrs" ) or die "Can't open $todmrs for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	if ($elems[3] > 1)
	{
		my $sth1 = $dbh->prepare("SELECT chr,start,stop,size from from_this where chr = $elems[0] and start >= $elems[1] and stop <= $elems[2] and size < $elems[3]")
       		        or die "Couldn't prepare statement: " . $dbh->errstr;
	
		$sth1->execute()             # Execute the query
   	  		or die "Couldn't execute statement: " . $sth1->errstr;
        	  	
		while (my @data = $sth1->fetchrow_array())
       		{
       			print "$data[0]\t$data[1]\t$data[2]\t$data[3]\t->\t$elems[0]\t$elems[1]\t$elems[2]\t$elems[3]\n";
       			$count++;
       			my $diff = $elems[3] - $data[3];
       			if ($diff > $max_diff)
       			{
       				$max_diff = $diff;
       				$max_coords = "$data[0]\t$data[1]\t$data[2]\t$data[3]\t->\t$elems[0]\t$elems[1]\t$elems[2]\t$elems[3]\n";
       			}
       			$total_diff += $diff;
       		}
       	}
}
close IN;
my $av_inc;
if ($count > 0)
{
	$av_inc = $total_diff/$count;
}
else
{
	$av_inc = "N/A";
	$max_coords = "N/A";
}
print "Average Increase = $av_inc\nMax Increase = $max_diff\nMax Coords = $max_coords\n";
$dbh->do("DROP TABLE from_this");
                                      
$dbh->disconnect;
