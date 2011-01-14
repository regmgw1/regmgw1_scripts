#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Determines if specified features overlap each other. Defunct. Use bedTools.
=head2 Usage

Usage: ./associated_feature.pl feature overlappingfeature path2output

=cut

#################################################################
# associated_feature.pl
#################################################################

use strict;
use DBI;

unless (@ARGV ==3 ) {
        die "\n\nUsage:\n ./associated_feature.pl feature overlappingfeature path2output\nPlease try again.\n\n\n";}

my $prom = shift;
my $cpgi = shift;
my $path2output = shift;

open (OUT, ">$path2output") or die "Can't open $path2output";  

my $dbh = DBI->connect("DBI:mysql:database=genomic_features_GRCh37;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";
                                       
#my $sth1 = $dbh->prepare("SELECT ensembl_id,start,stop,chr,strand FROM $prom")
#       				        or die "Couldn't prepare statement: " . $dbh->errstr;

my $sth1 = $dbh->prepare("SELECT id,start,stop,chr,strand FROM $prom")
       				        or die "Couldn't prepare statement: " . $dbh->errstr;
       			        
$sth1->execute()
or die "Couldn't execute statement: " . $sth1->errstr;
while (my @data = $sth1->fetchrow_array())
{
	my $sth2 = $dbh->prepare("SELECT id from $cpgi where start < $data[2] and stop > $data[1] and chr='$data[3]'")
       				        or die "Couldn't prepare statement: " . $dbh->errstr;
       			        
	$sth2->execute() or die "Couldn't execute statement: " . $sth2->errstr;		
	if ($sth2->rows > 0)
	{
        	print OUT "Promoter_$data[0]"."_chr$data[3]".":$data[1]"."-$data[2]\t$data[0]\t$data[3]\t$data[1]\t$data[2]\t$data[4]\t$cpgi associated\n";
        	while (my @test = $sth2->fetchrow_array())
		{
			      print "$test[0]\n";
		}
        }
        else
        {
        	print OUT "Promoter_$data[0]"."_chr$data[3]".":$data[1]"."-$data[2]\t$data[0]\t$data[3]\t$data[1]\t$data[2]\t$data[4]\tNA\n";
        }
}
$dbh->disconnect;
close OUT;          
	                                          
