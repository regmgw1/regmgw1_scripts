#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
corrects .pad files for cnv prebatman
=head2 Usage

Usage: ./cnv_corrector.pl path2cnv path2output chrom

=cut

#################################################################
# cnv_corrector.pl
#################################################################

use strict;
use DBI;
use Math::Round qw(:all);

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./cnv_corrector.pl path2cnv path2output chrom\nPlease try again.\n\n\n";}

my $path2cnv = shift;
my $path2output = shift;
my $chrom = shift;

my $chr = "chr".$chrom;

my $dbh = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";

open (OUT, ">$path2output/cnv_adjusted_reads_chr$chrom".".txt") or die "Can't open $path2output/cnv_adjusted_reads_chr$chrom".".txt for writing";                                       
open (IN, "$path2cnv" ) or die "Can't open $path2cnv for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split /\t/, $line;
	if ($elems[0] eq $chr)
	{
		my $start = $elems[1];
		my $stop = $elems[2];
		my $factor = $elems[6];
		my $round_start = nearest(50,$start) + 1;
		my $round_stop = nearest(50, $stop) + 1;
		while ($round_start < $round_stop)
		{
			my $temp_stop = $round_start + 49;
			my $sth1 = $dbh->prepare("SELECT probe_name,log_ratio FROM medip_probe,medip_data where chr=\"$chrom\" and min_pos = $round_start and medip_probe.id=medip_data.probe")
       				        or die "Couldn't prepare statement: " . $dbh->errstr;
       			        
			$sth1->execute()             # Execute the query
    				or die "Couldn't execute statement: " . $sth1->errstr;
    			while (my @data = $sth1->fetchrow_array())
			{
			      my $new_read = $data[1] * $factor;
			      $new_read = round($new_read);
			      print OUT "$chrom	ReadsToPseudoArray	probe	$round_start	$round_start	$new_read".".0	.	0	probe.id \"$data[0]\"\n";

			}
     			
     			$round_start = $round_start + 50;
     		}

	}
}
close OUT;
$dbh->disconnect;
