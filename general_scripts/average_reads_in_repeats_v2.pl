#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Obtains average values found in repeat regions.
=head2 Usage

Usage: ./average_reads_in_repeats_v2.pl repeat_type path2output chr

=cut

#################################################################
# average_reads_in_repeats_v2.pl
#################################################################

use strict;
use DBI;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./average_reads_in_repeats_v2.pl repeat_type path2output chr\nPlease try again.\n\n\n";}

my $repeat = shift;
my $path2output = shift;
my $chr = shift;

my $dbh = DBI->connect("DBI:mysql:database=repeat_families_human_ncbi36;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";
                                       
my $dbh_c = DBI->connect("DBI:mysql:database=read_density_MNPST;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";
                                       
my $dbh_b = DBI->connect("DBI:mysql:database=read_density_PNST;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";

my $dbh_n = DBI->connect("DBI:mysql:database=read_density_Control;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";


my $total_cbases = 0;
my $total_creads = 0;
my $total_bbases = 0;
my $total_breads = 0;
my $total_nbases = 0;
my $total_nreads = 0;

my (@c_first, @c_second, @c_third, @c_fourth, @c_fifth);                                       
my $sth1 = $dbh->prepare("SELECT start,stop FROM chrom_$chr where family = '$repeat'")
       	        or die "Couldn't prepare statement: " . $dbh->errstr;
$sth1->execute()             # Execute the query
	or die "Couldn't execute statement: " . $sth1->errstr;

while (my @data = $sth1->fetchrow_array())
{
	my $start = $data[0];
	my $stop = $data[1];
	my $length = $stop - $start;
	if ($length > 2000)
	{
	print "start = $start stop $stop\n";
	my $increment = $length/5;
	my $first_inc = $start+$increment;
	my $region_bases = 0;
	my $region_reads = 0;
	my $bregion_bases = 0;
	my $bregion_reads = 0;
	my $nregion_bases = 0;
	my $nregion_reads = 0;
	my $inc_count = 0;
	my $inc_reads = 0;
	my $inc_inc = 0;
	print "Cancer\n";
	my $sth_c = $dbh_c->prepare("SELECT start, stop, score FROM `batman_output` where start >= $start and start < $stop and chr='$chr'")
       	        or die "Couldn't prepare statement: " . $dbh_c->errstr;
	$sth_c->execute()             # Execute the query
		or die "Couldn't execute statement: " . $sth_c->errstr;
	while (my @can = $sth_c->fetchrow_array())
	{
		my $r_start = $can[0];
		my $r_stop = $can[1];
		my $score = $can[2];
		my $region = $r_stop - $r_start;
		$region_bases += $region;
		$region_reads += $region * $score;
		$total_cbases += $region;
		$total_creads += $region * $score;
		print "$r_start\t$r_stop\t$score\t$first_inc\n";
		if ($r_stop < $first_inc)
		{
			$inc_count += $region;
			$inc_reads += $score;
		}
		else
		{
			$first_inc = $first_inc + $increment;
			my $av_inc = 0;
			if ($inc_count > 0)
			{
				$av_inc = $inc_reads/$inc_count;
			}
			$inc_inc++;
			if ($inc_inc == 1)
			{
				push @c_first, $av_inc;
			}
			elsif ($inc_inc == 2)
			{
				push @c_second,$av_inc;
			}
			elsif ($inc_inc == 3)
			{
				push @c_third, $av_inc;
			}
			elsif ($inc_inc == 4)
			{
				push @c_fourth, $av_inc;
			}
			elsif ($inc_inc == 5)
			{
				push @c_fifth, $av_inc;
			}
			$inc_count = 0;
			$inc_reads = 0;
			
		}
	}
	my $sth_b = $dbh_b->prepare("SELECT start, stop, score FROM `batman_output` where start >= $start and start < $stop and chr='$chr'")
       	        or die "Couldn't prepare statement: " . $dbh_b->errstr;
	$sth_b->execute()             # Execute the query
		or die "Couldn't execute statement: " . $sth_b->errstr;
	while (my @can = $sth_b->fetchrow_array())
	{
		my $r_start = $can[0];
		my $r_stop = $can[1];
		my $score = $can[2];
		my $region = $r_stop - $r_start;
		$bregion_bases += $region;
		$bregion_reads += $region * $score;
		$total_bbases += $region;
		$total_breads += $region * $score;
	}
	my $sth_n = $dbh_n->prepare("SELECT start, stop, score FROM `batman_output` where start >= $start and start < $stop and chr='$chr'")
       	        or die "Couldn't prepare statement: " . $dbh_n->errstr;
	$sth_n->execute()             # Execute the query
		or die "Couldn't execute statement: " . $sth_n->errstr;
	while (my @can = $sth_n->fetchrow_array())
	{
		my $r_start = $can[0];
		my $r_stop = $can[1];
		my $score = $can[2];
		my $region = $r_stop - $r_start;
		$nregion_bases += $region;
		$nregion_reads += $region * $score;
		$total_nbases += $region;
		$total_nreads += $region * $score;
	}
	if ($region_bases != 0 && $bregion_bases != 0 && $nregion_bases != 0)
	{
		print "$start\t$stop";
		my $region_av = $region_reads/$region_bases;
		my $bregion_av = $bregion_reads/$bregion_bases;
		my $nregion_av = $nregion_reads/$nregion_bases;
		print "\t$region_av\t$bregion_av\t$nregion_av\n";
	}
	else
	{
		#print "WHY!!!!!???\n";
	}
	
	}
}
my $c_average = $total_creads/$total_cbases;
my $b_average = $total_breads/$total_bbases;
my $n_average = $total_nreads/$total_nbases;

print "Cancer Average = $c_average\nBenign Average= $b_average\nNormal Average = $n_average\n";		
$dbh->disconnect;
$dbh_c->disconnect;
$dbh_b->disconnect;
$dbh_n->disconnect;

my $one = 0;
foreach my $value (@c_first)
{
	$one += $value;
}
my $one_av = $one/@c_first;
print "Average = $one_av\n";
$one = 0;
foreach my $value (@c_second)
{
	$one += $value;
}
$one_av = $one/@c_second;
print "Average = $one_av\n";
$one = 0;
foreach my $value (@c_third)
{
	$one += $value;
}
$one_av = $one/@c_third;
print "Average = $one_av\n";
$one = 0;
foreach my $value (@c_fourth)
{
	$one += $value;
}
$one_av = $one/@c_fourth;
print "Average = $one_av\n";
$one = 0;
foreach my $value (@c_fifth)
{
	$one += $value;
}
$one_av = $one/@c_fifth;
print "Average = $one_av\n";
	
			
		
		                                       
