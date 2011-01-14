#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
find nearest gene using dmrs from dmr files
=head2 Usage

Usage: ./dmrs_nearest_gene.pl path2can path2norm threshold hyper (0 or 1) path2output

=cut

#################################################################
# get_dmrs_nearest_gene.pl
#################################################################

use strict;
use DBI;

unless (@ARGV ==5) {
        die "\n\nUsage:\n ./get_dmrs_nearest_gene.pl path2can path2norm threshold hyper (0 or 1) path2output\nPlease try again.\n\n\n";}

my $path2can = shift;
my $path2norm = shift;
my $threshold = shift;
my $hyper = shift;
my $path2output = shift;

my (@dmrs, %can_hash);

my $dbh = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";

open (OUT, ">$path2output") or die "Can't open $path2output for writing";

open (IN, "$path2can" ) or die "Can't open $path2can for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	my $coords = $elems[0]."_".$elems[1];
	$can_hash{$coords} = $elems[3];
}
close IN;

open (IN, "$path2norm" ) or die "Can't open $path2norm for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	my $coords = $elems[0]."_".$elems[1];
	if (exists $can_hash{$coords})
	{
		if ($hyper == 1)
		{
			if ($can_hash{$coords} - $elems[3] >= $threshold)
			{ 
				my $diff = $can_hash{$coords} - $elems[3];
				push @dmrs, $coords;
				print OUT "$elems[0]\tDMR\tchr$elems[0]".":$elems[1]"."-$elems[2]\t$elems[1]\t$elems[2]\t$diff\t.\t.\tDMR_cancer_normal_threshold$threshold"."_hyper\n";
			}
		}
		elsif ($hyper == 0)
		{
			if ($elems[3] - $can_hash{$coords} >= $threshold)
			{
				my $diff = $elems[3] - $can_hash{$coords};
				push @dmrs, $coords;
				print OUT "$elems[0]\tDMR\tchr$elems[0]".":$elems[1]"."-$elems[2]\t$elems[1]\t$elems[2]\t$diff\t.\t.\tDMR_cancer_normal_threshold$threshold"."_hypo\n";
			}
		}
		else
		{
			die "Set hyper as 1 for hyper cancer dmrs, 0 for hypo cancer dmrs";
		}
	}
	else
	{
		print "MISSING: $line\n";
	}
}
close IN;


close OUT;  			
$dbh->disconnect;
