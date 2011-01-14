#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Determine number of uncovered cpgs at given coverage threshold. Defunct. Use MEDIPs
=head2 Usage

Usage: ./cpg_coverage.pl path2sgr path2output coverage_threshold(i.e. this value or more = covered) sample
 
=cut

#################################################################
# cpg_coverage.pl 
#################################################################
use strict;
use DBI;

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./cpg_coverage.pl path2sgr path2output coverage_threshold(i.e. this value or more = covered) sample\nPlease try again.\n\n\n";}

my $path2data = shift;
my $path2output = shift;
my $threshold = shift;
my $sample = shift;


my $dbh = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";

open (OUT, ">>$path2output/cpg_coverage.txt") or die "Can't open $path2output for writing";
my $count = 0;
my (%coords, $table, $chr);
#my @files = <$path2data/*gff>;
#foreach my $file (@files)
#{
	#open (IN, "$file" ) or die "Can't open $file for reading";
	open (IN, "$path2data" ) or die "Can't open $path2data for reading";
	
	my $line_count = 0;
	while (my $line = <IN>)
	{
		if ($line_count > 0)
		{
		chomp $line;
		my @elems = split/\t/, $line;
		my $cover = $elems[3];
		my $start = $elems[1];
		my $stop = $elems[2];
		$chr = $elems[0];
		$chr =~m/chr(.*)/;
		$table = "chrom_".$1;
		if ($cover < $threshold)
		{
			$coords{$start} = $stop;
		}
		}
		$line_count++;
		
	}
	close IN;
	open (CHR, ">$path2output/$sample"."_$chr"."_cpg_uncovered.txt" ) or die "Can't open $path2output/chr$chr"."_cpg_uncovered.txt for writing";
	foreach my $key (keys(%coords))
	{
		
		my $sth1 = $dbh->prepare("SELECT chr,start,stop from $table where start >= $key and stop <= $coords{$key}")
        	        or die "Couldn't prepare statement: " . $dbh->errstr;
		$sth1->execute()             # Execute the query
    			or die "Couldn't execute statement: " . $sth1->errstr;
        	  	
		while (my @head = $sth1->fetchrow_array())
		{
		      $count++;
		      print CHR "$head[0]\t$head[1]\t$head[2]\n";
     		}
     	}
#}
print OUT "Number uncovered CpG in $sample chr $chr = $count\n";
close OUT;
close CHR;
$dbh->disconnect;

