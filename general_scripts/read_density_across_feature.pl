#!/usr/bin/perl -w


#################################################################
# read_density_across_feature.pl
#################################################################

use strict;
use DBI;
use Math::Round qw(:all);

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./read_density_across_feature.pl feature_db feature database path2output chrom\nPlease try again.\n\n\n";}

my $feature_db = shift;
my $feature = shift;
my $database = shift;
my $path2output = shift;
#my $chrom = shift;

my (%inc_hash,%count_hash,$chrom,@repeats);

#connect to sgr database
my $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost", "regmgw1", "bongrel",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";

# connect to feature database e.g. repeat_families_human_ncbi36
my $dbh_f = DBI->connect("DBI:mysql:database=$feature_db;host=localhost", "regmgw1", "bongrel",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";


open (OUT, ">$path2output") or die "Can't open $path2output for writing";

my $sth_f = $dbh_f->prepare("SELECT start, stop, chr FROM `$feature`")
  		or die "Couldn't prepare statement: " . $dbh_f->errstr;
$sth_f->execute()             # Execute the query
	or die "Couldn't execute statement: " . $sth_f->errstr;
while (my @temp = $sth_f->fetchrow_array())
{
	push @repeats, \@temp;
}

#determine number of repeats stored in array
my $repeat_num = @repeats;
#print "repeats = $repeat_num\n";
my $rep_count = 0;
#obtain 1000 random repeat regions
while ($rep_count < 200)
{
	my $ref_array = $repeats[int(rand($repeat_num))];
	my @features = @$ref_array;
        my $start = $features[0];
        my $stop = $features[1];
        my $chr = $features[2];
        #calculate length of feature and length of increments
        my $feature_length = $stop - $start;
        my $increment = $feature_length/10;
	#print "$chr $start $stop\n";
	for (my $i = 0;$i<10;$i++)
	{
		#obtain the sgr counts for each increment
		my $cum_score = 0;
		my $score_count = 0;
		my $new_start = $start + ($increment*$i);
		my $new_stop = $new_start + $increment - 1;
		#print "$new_start .... $new_stop\n";
		my $sth = $dbh->prepare("SELECT start, stop, depth FROM `chrom_$chr` where stop > $new_start and start < $new_stop and chr='$chr'")
       	        	or die "Couldn't prepare statement: " . $dbh->errstr;
		$sth->execute()             # Execute the query
			or die "Couldn't execute statement: " . $sth->errstr;
		while (my @can = $sth->fetchrow_array())
		{
			#print "$can[0]\t$can[1]\t$can[2]\t";
			#determine the number of bases in each increment covered by each sgr record
			if ($can[0] >= $new_start && $can[1] <= $new_stop)
			{
				my $depth_length = $can[1] - $can[0];
				$cum_score +=$depth_length * $can[2];
				#$cum_score +=$can[2];
				#$score_count++;
				#print "A - ".$depth_length * $can[2]."\n";
			}
			elsif ($can[0] >= $new_start && $can[1] > $new_stop)
			{
				my $depth_length = $new_stop - $can[0];
				$cum_score +=$depth_length * $can[2];
				#print "B - ".$depth_length * $can[2]."\n";
			}
			elsif ($can[0] < $new_start && $can[1] <= $new_stop)
			{
				my $depth_length = $can[1] - $new_start;
				$cum_score +=$depth_length * $can[2];
				#print "C - ".$depth_length * $can[2]."\n";
			}
			elsif ($can[0] < $new_start && $can[1] > $new_stop)
			{
				my $depth_length = $new_stop - $new_start;
				$cum_score +=$depth_length * $can[2];
				#print "D - ".$depth_length * $can[2]."\n";
			}
			else
			{
				print STDERR "ERROR read start $can[0], stop $can[1]\nincrement start $new_start stop $new_stop\n";
			}
		}
		#calculate the average sgr for each increment and store in hash
		my $av_score = $cum_score/$increment;
		#print "cumul = $cum_score\nincrement = $increment\naverage = $av_score\n";
		my $total_inc = $inc_hash{$i};
		$inc_hash{$i} = $total_inc + $av_score;
		print "$av_score\t";
		$count_hash{$i}++;
		
		
	}
	print "\n";
	$rep_count++;
}
$dbh->disconnect;
$dbh_f->disconnect;

#obtain the average read level for each increment from all sampled repeats
for (my $i = 0;$i<10;$i++)
{
	my $inc_average = $inc_hash{$i}/$count_hash{$i};
	print OUT "\t$inc_average";
}
