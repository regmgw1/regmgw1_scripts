#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Create CpG matrix, each row is a CpG, each column is a feature type. Defunct use v2
=head2 Usage

Usage: ./cpg_feature_matrix.pl path2cpgdata tablelist path2output
 
=cut

#################################################################
# cpg_feature_matrix.pl 
#################################################################
use strict;
use DBI;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./cpg_feature_matrix.pl path2cpgdata tablelist path2output\nPlease try again.\n\n\n";}

my $path2data = shift;
my $tablelist = shift;
my $path2output = shift;


my $dbh = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";

open TAB, "$tablelist" or die "Can't open $tablelist for reading";
my @tables = <TAB>;
close TAB;

open (OUT, ">$path2output") or die "Can't open $path2output for writing";

print OUT "CpG_chrom\tCpG_start\tCpG_stop";
foreach my $table (@tables)
{
	chomp $table;
	print OUT "\t$table";
}
print OUT "\n";

open (IN, "$path2data" ) or die "Can't open $path2data for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	my $chrom = $elems[0];
	my $start = $elems[3];
	my $stop = $elems[4];
	print OUT "$chrom\t$start\t$stop";
	foreach my $table (@tables)
	{
		my $count = 0;
		my $sth1 = $dbh->prepare("SELECT id from $table where chr = \"$chrom\" and (start < $start and stop > $stop)")
       		        or die "Couldn't prepare statement: " . $dbh->errstr;

		$sth1->execute()             # Execute the query
   	  			or die "Couldn't execute statement: " . $sth1->errstr;
       	  	
		while (my @head = $sth1->fetchrow_array())
		{
		      $count++;
    
		}                                       
		print OUT "\t$count";
	}
	print OUT "\n";
}
close IN;

close OUT;
$dbh->disconnect;
