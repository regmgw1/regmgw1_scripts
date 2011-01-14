#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
fills chr tables in db
=head2 Usage

Usage: ./chrom_table_inserts.pl table_prefix path2data feature_type(for correct file name)

=cut

#################################################################
# chrom_table_inserts.pl 
#################################################################
use strict;
use DBI;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./chrom_table_inserts.pl table_prefix path2data feature_type(for correct file name) \nPlease try again.\n\n\n";}

my $prefix = shift;
my $path2data = shift;
my $type = shift;

my $dbh = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";


for (my $i=1; $i<=22; $i++)
{
	my $infile  = "";
	my $chr = "";
	if ($i <= 22)
	{
		$infile  = "$path2data/combined_121109_dmr_10bat_chr".$i.".txt";
		$chr = $i;
	}
	elsif ($i == 23)
	{
		$infile  = "$path2data/chrX_$type".".gff";
		$chr = "X";
	}
	elsif ($i == 24)
	{
		$infile  = "$path2data/chrY_$type".".gff";
		$chr = "Y";
	}
	open (IN, "$infile" ) or die "Can't open $infile for reading";
	print "chr = $chr\n";
	while (my $line = <IN>)
	{
		chomp $line;
		my @elems = split/\t/, $line;		
		my $insert_handle = $dbh->prepare_cached("INSERT INTO $prefix"."_$chr VALUES (id,?,?,?,?,?,?)"); 
			die "Couldn't prepare queries; aborting" unless defined $insert_handle;

		my $success = 1;
		$success &&= $insert_handle->execute($elems[0], $elems[1], $elems[2], $elems[3], $elems[4], $elems[5]);
		my $result = ($success ? $dbh->commit : $dbh->rollback);
		unless ($result)
		{ 
			die "Couldn't finish transaction: " . $dbh->errstr 
		}
	}
	close IN;
}
$dbh->disconnect;
