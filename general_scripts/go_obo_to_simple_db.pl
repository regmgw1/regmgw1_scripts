#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Parses obo file into a simple mysql table

=head2 Usage

Usage: ./go_obo_to_simple_db.pl path2obo user password

=cut

#################################################################
# go_obo_to_simple_db.pl
#################################################################

use strict;
use DBI;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./go_obo_to_simple_db.pl path2obo user password\nPlease try again.\n\n\n";}

my $path2obo = shift;
my $username = shift;
my $pswd = shift;

open (IN, "$path2obo" ) or die "Can't open $path2obo for reading";
my ($id, $name, $ont, $def);
my $count = 0;

my $dbh = DBI->connect("DBI:mysql:database=simple_go;host=localhost", "$username", "$pswd",
                                 { RaiseError => 1,
                                   AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";
                                   
while (my $line = <IN>)
{
	if ($line =~m/^\[Typedef\]/)
	{
		last;
	}
	if ($line =~m/^\[Term\]/)
	{
		# if count is > 0, check content of variables, insert the variables into database, reset the variables.
		if ($count > 0)
		{
			my $insert_handle = $dbh->prepare_cached('INSERT INTO simple_annotation VALUES (?,?,?,?)'); 
			die "Couldn't prepare queries; aborting" unless defined $insert_handle;

			my $success = 1;
			$success &&= $insert_handle->execute($id, $name, $ont, $def);
			my $result = ($success ? $dbh->commit : $dbh->rollback);
			unless ($result)
			{ 
				die "Couldn't finish transaction: " . $dbh->errstr 
			}		
		}
		$id = "";
		$ont = "";
		$name = "";
		$def = "";
	}
	elsif ($line =~m/^id:/)
	{
		$line =~m/GO:(\d{7})/;
		$id = $1;
		$count++;
	}
	elsif ($line =~m/^name: (.*)/)
	{
		$name = $1;
	}
	elsif ($line =~m/^namespace: (.*)/)
	{
		$ont = $1;
	}
	elsif ($line =~m/^def: (.*)/)
	{
		$def = $1;
	}
	else
	{
		next;
	}
}
$dbh->disconnect;
