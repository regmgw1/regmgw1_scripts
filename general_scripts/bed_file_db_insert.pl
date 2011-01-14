#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Read bed file into db table
=head2 Usage

Usage: ./bed_file_db_insert.pl path2data

=cut

#################################################################
# bed_file_db_insert.pl 
#################################################################
use strict;
use DBI;

unless (@ARGV ==1) {
        die "\n\nUsage:\n ./bed_file_db_insert.pl path2data\nPlease try again.\n\n\n";}

my $path2data = shift;
my $count = 0;
my $dbh = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";

open (IN, "$path2data" ) or die "Can't open $path2data for reading";
while (my $line = <IN>)
{
	chomp $line;
	if ($count > 0)
	{
		my @elems = split/\t/, $line;
		my $chr = $elems[0];
		$chr =~s/chr//;
		my $insert_handle = $dbh->prepare_cached('INSERT INTO feature_table VALUES (id,?,?,?)'); 
		die "Couldn't prepare queries; aborting" unless defined $insert_handle;
	
		my $success = 1;
		$success &&= $insert_handle->execute($chr, $elems[1], $elems[2]);
		my $result = ($success ? $dbh->commit : $dbh->rollback);
		unless ($result)
		{ 
			die "Couldn't finish transaction: " . $dbh->errstr 
		}
	}
	$count++;
}
close IN;
$dbh->disconnect;
