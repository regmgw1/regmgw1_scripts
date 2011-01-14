#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Find batscore for each cpg
=head2 Usage

Usage: ./cpg_batscore.pl path2cpgdata database path2output

=cut

#################################################################
# cpg_batscore.pl 
#################################################################
use strict;
use DBI;
use Math::Round qw(:all);

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./cpg_batscore.pl path2cpgdata database path2output\nPlease try again.\n\n\n";}

my $path2files = shift;
my $database = shift;
my $path2output = shift;


my $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";

for (my $i=1; $i<=24; $i++) {

    my $infile  = "";
    my $outfile = "";
    my $chr     = "";
    my $start_count = 0;

    if ($i <= 22) {
	$infile  = "$path2files/chr".$i."_cpgs.gff";
	$outfile = "$path2output/chr".$i."_cpg_batscore.gff";
	$chr = $i;
    }
    elsif ($i == 23) {
	$infile  = "$path2files/chrX_cpgs.gff";
	$outfile = "$path2output/chrX_cpg_batscore.gff";
	$chr = "X";
    }
    elsif ($i == 24) {
	$infile  = "$path2files/chrY_cpgs.gff";
	$outfile = "$path2output/chrY_cpg_batscore.gff";
	$chr = "Y";
    }
                                       
	open (IN, "$infile" ) or die "Can't open $infile for reading";
	open (OUT, ">$outfile") or die "Can't open $outfile for writing";
	print "chr = $chr\n";
	while (my $line = <IN>)
	{
		chomp $line;
		my @elems = split/\t/, $line;
		my $chrom = $elems[0];
		my $start = $elems[3];
		my $window_start = nlowmult(100, $start) + 1;
		my $stop = $elems[4];
		my $bat_match = 0;
		my $sth1 = $dbh->prepare("SELECT score from batman_output where chr = \"$chrom\" and start = $window_start")
        		        or die "Couldn't prepare statement: " . $dbh->errstr;
	
		$sth1->execute()             # Execute the query
    	  		or die "Couldn't execute statement: " . $sth1->errstr;
        	  	
		while (my @data = $sth1->fetchrow_array())
        	{
        		print OUT "$chrom\tCpG_Batscore\tchr$chr".":$start"."-$stop\t$start\t$stop\t$data[0]\t+\t.\tNCBI36; cpg_batscore.pl\n";
        		$bat_match = 1;
        	}
        	if ($bat_match == 0)
        	{
        		print OUT "$chrom\tCpG_Batscore\tchr$chr".":$start"."-$stop\t$start\t$stop\t0\t+\t.\tNCBI36; cpg_batscore.pl; missing bat data\n";     
        	}	                               
	}
}
$dbh->disconnect;
