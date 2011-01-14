#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
creates db table for each chrom
=head2 Usage

Usage: ./chrom_table_create.pl prefix

=cut


#################################################################
# chrom_table_create.pl 
#################################################################
use strict;
use DBI;

unless (@ARGV ==1) {
        die "\n\nUsage:\n ./chrom_table_create.pl prefix\nPlease try again.\n\n\n";}

my $prefix = shift;

my $dbh = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";


for (my $i=1; $i<=22; $i++)
{

	my $chr = "";
	if ($i <= 22)
	{
		$chr = $i;
	}
	elsif ($i == 23)
	{
		$chr = "X";
	}
	elsif ($i == 24)
	{
		$chr = "Y";
	}

	$dbh->do("CREATE TABLE $prefix"."_$chr (id int(10) NOT NULL AUTO_INCREMENT,
					chr varchar(2) NOT NULL,
					start int(10) NOT NULL,
					stop int(10) NOT NULL,
					cancer float NOT NULL,
					benign float NOT NULL,
					normal float NOT NULL,
					PRIMARY KEY (id),
					KEY chr_index (chr),
					KEY start_index (start),
					KEY stop_index (stop)
                                      )");
}                                      

$dbh->disconnect;
