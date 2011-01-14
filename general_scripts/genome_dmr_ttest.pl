#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
connects to the relevant batman databases, selects all the batman scores for given chrom and performs ttest over 10 bat windows.
=head2 Usage

Usage: ./genome_dmr_ttest.pl chrom path2output

=cut

#################################################################
# genome_dmr_ttest.pl 
#################################################################
use strict;
use DBI;
use Math::Round qw(:all);
use Statistics::TTest;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./genome_dmr_ttest.pl chrom path2output\nPlease try again.\n\n\n";}

my $chrom = shift;
my $path2output = shift;

my $dbh1 = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";


my $dbh2 = DBI->connect("DBI:mysql:database=db2;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";


my $dbh3 = DBI->connect("DBI:mysql:database=db3;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";
my $count = 0;
my $bat = 0;
my $start;
my (%data1,%data2,%data3);
my $ttest = new Statistics::TTest;


open (OUT, ">$path2output") or die "Can't open $path2output for writing";
print OUT "chr\tstart\tstop\tp_can_norm\tp_can_ben\tp_ben_norm\n";
print "chrom = $chrom\n";
my $sth1 = $dbh1->prepare("SELECT score,start,stop from batman_output where chr = \"$chrom\" order by start")
      				        or die "Couldn't prepare statement: " . $dbh1->errstr;
$sth1->execute()             # Execute the query
   		or die "Couldn't execute statement: " . $sth1->errstr;
while (my @data = $sth1->fetchrow_array())
{
	$data1{$data[1]} = $data[0];
}

my $sth2 = $dbh2->prepare("SELECT score,start,stop from batman_output where chr = \"$chrom\" order by start")
      				        or die "Couldn't prepare statement: " . $dbh2->errstr;
$sth2->execute()             # Execute the query
   		or die "Couldn't execute statement: " . $sth1->errstr;
while (my @data = $sth2->fetchrow_array())
{
	$data2{$data[1]} = $data[0];
}
	
my $sth3 = $dbh3->prepare("SELECT score,start,stop from batman_output where chr = \"$chrom\" order by start")
      				        or die "Couldn't prepare statement: " . $dbh3->errstr;
$sth3->execute()             # Execute the query
   		or die "Couldn't execute statement: " . $sth3->errstr;
while (my @data = $sth3->fetchrow_array())
{
	$data3{$data[1]} = $data[0];
}	

my (@can,@ben,@norm);

foreach my $key (sort {$a<=>$b} keys %data1)	
{	
	push @can, $data1{$key};
	push @ben, $data2{$key};
	push @norm, $data3{$key};
	
	if ($count == 0)
	{
		$start = $key;
	}
	$count++;
	if ($count == 10)
	{
		$ttest->set_significance(95);
		$ttest->load_data(\@can,\@norm);
		my $pvalcn = $ttest->t_prob();
		$ttest->load_data(\@can,\@ben);
		my $pvalcb = $ttest->t_prob();
		$ttest->load_data(\@ben,\@norm);
		my $pvalbn = $ttest->t_prob();
		my $stop = $key + 99;
		print OUT "$chrom\t$start\t$stop\t$pvalcn\t$pvalcb\t$pvalbn\n";
		@can=(); 
		@norm=();
		@ben=();
		$count = 0;
	}
	
}
close OUT;

$dbh1->disconnect();
$dbh2->disconnect();
$dbh3->disconnect();
