#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
calculate read depth across/upstream/downstream repeat regions.
=head2 Usage

Usage: ./read_density_across_repeats.pl path2repeats sgr_database upstream downstream path2output

=cut

#################################################################
# read_density_across_repeats.pl
#################################################################

use strict;
use DBI;

unless (@ARGV ==5 ) {
        die "\n\nUsage:\n ./read_density_across_repeats.pl path2repeats sgr_database upstream downstream path2output\nPlease try again.\n\n\n";}

my $path2repeats = shift;
my $database = shift;
my $upstream = shift;
my $downstream = shift;
my $path2output = shift;

if ($upstream == 1 && $downstream == 1)
{
	die "Can't have both upstream and downstream set to 1!!\n";
}

my (%inc_hash,%count_hash);

open (OUT, ">>$path2output") or die "Can't open $path2output for writing";

#connect to sgr database
my $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";




my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22);
foreach my $chr (@chroms)
{
	my $rep_count = 0;
	open (IN, "$path2repeats" ) or die "Can't open $path2repeats for reading";
	while (my $line = <IN>)
	{
		my @elems = split/\t/,$line;
		my $chrom = $elems[0];
		$chrom =~s/chr//;
		my $start = $elems[3];
		my $stop = $elems[4];
		if ($rep_count > 100)
		{
			last;
		}
		if ($chr eq $chrom)
		{
			if ($downstream == 1)
			{
				$start = $stop;
				$stop = $stop + 1000;
			}
			elsif ($upstream == 1)
			{
				$stop = $start;
				$start = $start - 1000;
			}
			#print "$start\t$stop\t$class\t$type\n";
			
			my $feature_length = $stop - $start;
       			my $increment = $feature_length/10;
       			print "inc = $increment\n";
			print "$chrom $start $stop\n";
			for (my $i = 0;$i<10;$i++)
			{
				my $cum_score = 0;
				my $score_count = 0;
				my $permitted_bases = 0;
				my $new_start = $start + ($increment*$i);
				my $new_stop = $new_start + $increment - 1;
				my $sth = $dbh->prepare("SELECT start, stop, depth FROM `chrom_$chrom` where stop > $new_start and start < $new_stop and chr='$chrom'")
       	       				or die "Couldn't prepare statement: " . $dbh->errstr;
				$sth->execute()             # Execute the query
					or die "Couldn't execute statement: " . $sth->errstr;
				while (my @can = $sth->fetchrow_array())
				{
					# ignore if depth = 0
					if ($can[2] > 0)
					{
						#determine the number of bases in each increment covered by each sgr record
						my $depth_length;
						if ($can[0] >= $new_start && $can[1] <= $new_stop)
						{
							$depth_length = $can[1] - $can[0] + 1;
							$cum_score +=$depth_length * $can[2];
						}
						elsif ($can[0] >= $new_start && $can[1] > $new_stop)
						{
							$depth_length = $new_stop - $can[0] + 1;
							$cum_score +=$depth_length * $can[2];
						}
						elsif ($can[0] < $new_start && $can[1] <= $new_stop)
						{
							$depth_length = $can[1] - $new_start + 1;
							$cum_score +=$depth_length * $can[2];
						}
						elsif ($can[0] < $new_start && $can[1] > $new_stop)
						{
							$depth_length = $new_stop - $new_start + 1;
							$cum_score +=$depth_length * $can[2];
						}
						else
						{
							print STDERR "ERROR read start $can[0], stop $can[1]\nincrement start $new_start stop $new_stop\n";
						}
						$permitted_bases += $depth_length;
					}
				}
				#calculate the average sgr for each increment and store in hash
				if ($permitted_bases > 0)
				{	
					$rep_count++;
					my $av_score = $cum_score/$permitted_bases;
					if (exists $inc_hash{$i})
					{
						my $total_inc = $inc_hash{$i};
						$inc_hash{$i} = $total_inc + $av_score;
					}
					else
					{
						my $total_inc = 0;
						$inc_hash{$i} = $total_inc + $av_score;
					}
					print "$av_score\t";
					$count_hash{$i}++;
				}
				else
				{
					print "N/A\t";
				}
			}
			print "\n";
		}
	}
	close IN;
}	

#obtain the average read level for each increment from all sampled repeats
for (my $i = 0;$i<10;$i++)
{
	my $inc_average = $inc_hash{$i}/$count_hash{$i};
	print OUT "\t$inc_average";
}
print OUT "\n";
close OUT;
$dbh->disconnect;
