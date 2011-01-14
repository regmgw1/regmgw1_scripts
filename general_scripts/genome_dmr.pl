#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
connects to the relevant batman databases, selects all the batman scores for given chrom and averages over 10 bat windows.
=head2 Usage

Usage: ./genome_dmr.pl chrom path2output

=cut

#################################################################
# genome_dmr.pl - connects to the relevant batman databases, selects all the batman scores for given chrom and averages over 10 bat windows.
#################################################################
use strict;
use DBI;
use Math::Round qw(:all);

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./genome_dmr.pl chrom path2output\nPlease try again.\n\n\n";}

my $chrom = shift;
my $path2output = shift;


# in future, replace the repeated code with a loop - reading through file of db and sample names
my $dbh = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";

bat_query($dbh, $chrom, "cancer_291009", $path2output);

$dbh->disconnect();

$dbh = DBI->connect("DBI:mysql:database=db2;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";

bat_query($dbh, $chrom, "benign_291009", $path2output);

$dbh->disconnect();

$dbh = DBI->connect("DBI:mysql:database=db3;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";

bat_query($dbh, $chrom, "normal_291009", $path2output);

$dbh->disconnect();


sub bat_query
{
	my ($dbh, $chrom, $sample) = @_;
	my $count = 0;
	my $bat = 0;
	my $start;
	open (OUT, ">$path2output/$sample"."_dmr_10bat_chr$chrom".".txt") or die "Can't open $path2output for writing";
	print "chrom = $chrom\n";
	my $sth1 = $dbh->prepare("SELECT score,start,stop from batman_output where chr = \"$chrom\" order by start")
       				        or die "Couldn't prepare statement: " . $dbh->errstr;
	$sth1->execute()             # Execute the query
    		or die "Couldn't execute statement: " . $sth1->errstr;
    	while (my @data = $sth1->fetchrow_array())
	{
		$bat = $bat + $data[0];
		if ($count == 0)
		{
			$start = $data[1];
		}
		$count++;
		if ($count == 10)
		{
			my $avg = $bat/10;
			my $length = $data[2] - $start;
			print OUT "$chrom\t$start\t$data[2]\t$avg\t$length\n";
			$bat = 0;
			$count = 0;
		}
		
    	}
     	close OUT;
}
