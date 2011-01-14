#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Calculate average bat score upstream, across and downstream of exons
=head2 Usage

Usage: ./bat_average_across_exons_v2.pl path2data database path2output upstream?(1|0) downstream(1|0)

=cut

#################################################################
# bat_average_across_exons.pl
#################################################################

use strict;
use DBI;
use Math::Round qw(:all);
use Statistics::Descriptive;


unless (@ARGV ==6) {
        die "\n\nUsage:\n ./bat_average_across_exons_v2.pl path2data database path2output upstream?(1|0) downstream(1|0)\nPlease try again.\n\n\n";}

my $path2data = shift;
my $database = shift;
my $path2output = shift;
my $up = shift;
my $down = shift;
my $type = shift;

my (%inc_hash,%count_hash,%up_count_hash,%up_inc_hash,%down_count_hash,%down_inc_hash);
my (@var_array,@up_var_array,@down_var_array);
my $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";


open (OUT, ">>$path2output") or die "Can't open $path2output for writing";
        
open (IN, "$path2data" ) or die "Can't open $path2data for reading";
while (my $line = <IN>)
{
	chomp $line;
        my @elems = split/\t/, $line;
        my $chrom = $elems[0];
        my $id = $elems[1];
        my $start = $elems[3];
        my $stop = $elems[4];
        my $strand = $elems[5];
        my $island_length = $stop - $start;
        my $increment = $island_length/10;
        print "$chrom $id $start $stop";
        my $j = 9;
	for (my $i = 0;$i<10;$i++)
	{
		
		my $cum_score = 0;
		my $score_count = 0;
		my $new_start = $start + ($increment*$i);
		my $new_stop = $new_start + $increment - 1;
		my $window_start = nlowmult(100, $new_start) + 1;
		my $sth = $dbh->prepare("SELECT start, stop, score FROM `batman_output` where start >= $window_start and start < $new_stop and chr='$chrom'")
       	        	or die "Couldn't prepare statement: " . $dbh->errstr;
		$sth->execute()             # Execute the query
			or die "Couldn't execute statement: " . $sth->errstr;
		while (my @can = $sth->fetchrow_array())
		{
			$cum_score +=$can[2];
			$score_count++;
		}
		if ($score_count > 0)
		{
			my $av_score = $cum_score/$score_count;
			if ($strand == 1)
			{
				my $total_inc = $inc_hash{$i};
				$inc_hash{$i} = $total_inc + $av_score;
				print "\t$av_score";
				$count_hash{$i}++;
				# add to array in hash
				push @{$var_array[$i]}, $av_score;
			}
			elsif ($strand == -1)
			{
				my $total_inc = $inc_hash{$j};
				$inc_hash{$j} = $total_inc + $av_score;
				print "\t$av_score";
				$count_hash{$j}++;
				# add to array in hash
				push @{$var_array[$j]}, $av_score;
			}
		}
		else
		{
			print "\tN/A";
		}
		$j--;
	}
	print "\n";
	
	if ($up == 1)
	{
		my $up_stop;
		my $up_start;
		my $island_length;
		if ($strand == 1)
		{
			$up_start = $start - 2000;
			$up_stop = $start - 1;
			$island_length = $up_stop - $up_start;
		}
		elsif ($strand == -1)
		{
			$up_start = $stop + 2000;
			$up_stop = $stop + 1;
			$island_length = $up_start - $up_stop;
		}
		
		
        	my $increment = $island_length/10;
		print "$chrom $up_start $up_stop";
		for (my $i = 0;$i<10;$i++)
		{
			my $cum_score = 0;
			my $score_count = 0;
			my ($new_start,$new_stop,$sth);
			if ($strand == 1)
			{
				$new_start = $up_start + ($increment*$i);
				$new_stop = $new_start + $increment - 1;
				my $window_start = nlowmult(100, $new_start) + 1;
				$sth = $dbh->prepare("SELECT start, stop, score FROM `batman_output` where start >= $window_start and start < $new_stop and chr='$chrom'")
       		        	or die "Couldn't prepare statement: " . $dbh->errstr;
			}
			elsif ($strand == -1)
			{
				$new_start = $up_start - ($increment*$i);
				$new_stop = $new_start - $increment + 1;
				my $window_stop = nlowmult(100, $new_stop) + 1;
				$sth = $dbh->prepare("SELECT start, stop, score FROM `batman_output` where start >= $window_stop and start < $new_start and chr='$chrom'")
       		        	or die "Couldn't prepare statement: " . $dbh->errstr;
			}
			$sth->execute()             # Execute the query
				or die "Couldn't execute statement: " . $sth->errstr;
			while (my @can = $sth->fetchrow_array())
			{
				$cum_score +=$can[2];
				$score_count++;
			}
			if ($score_count > 0)
			{
				my $av_score = $cum_score/$score_count;
				my $total_inc = $up_inc_hash{$i};
				$up_inc_hash{$i} = $total_inc + $av_score;
				print "\t$av_score";
				$up_count_hash{$i}++;
				push @{$up_var_array[$i]}, $av_score;
			}
			else
			{
				print "\tN/A";
			}
		}
		print "\n";
	}
	if ($down == 1)
	{
		my $down_stop;
		my $down_start;
		my $island_length;
		if ($strand == 1)
		{
			$down_start = $stop + 1;
			$down_stop = $stop + 2000;
			$island_length = $down_stop - $down_start;
		}
		elsif ($strand == -1)
		{
			$down_start = $start - 1;
			$down_stop = $start - 2000;
			$island_length = $down_start - $down_stop;
		}
		
		my $increment = $island_length/10;
		print "$chrom $down_start $down_stop";
		for (my $i = 0;$i<10;$i++)
		{
			my $cum_score = 0;
			my $score_count = 0;
			my ($new_start,$new_stop,$sth);
			if ($strand == 1)
			{
				$new_start = $down_start + ($increment*$i);
				$new_stop = $new_start + $increment - 1;
				my $window_start = nlowmult(100, $new_start) + 1;
				$sth = $dbh->prepare("SELECT start, stop, score FROM `batman_output` where start >= $window_start and start < $new_stop and chr='$chrom'")
       		        	or die "Couldn't prepare statement: " . $dbh->errstr;
       		        }
       		        elsif ($strand == -1)
			{
				$new_start = $down_start - ($increment*$i);
				$new_stop = $new_start - $increment + 1;
				my $window_stop = nlowmult(100, $new_stop) + 1;
				$sth = $dbh->prepare("SELECT start, stop, score FROM `batman_output` where start >= $window_stop and start < $new_start and chr='$chrom'")
       		        	or die "Couldn't prepare statement: " . $dbh->errstr;
       		        }
			$sth->execute()             # Execute the query
				or die "Couldn't execute statement: " . $sth->errstr;
			while (my @can = $sth->fetchrow_array())
			{
				$cum_score +=$can[2];
				$score_count++;
			}
			if ($score_count > 0)
			{
				my $av_score = $cum_score/$score_count;
				my $total_inc = $down_inc_hash{$i};
				$down_inc_hash{$i} = $total_inc + $av_score;
				print "\t$av_score";
				$down_count_hash{$i}++;
				push @{$down_var_array[$i]}, $av_score;
				
			}
			else
			{
				print "\tN/A";
			}
			
		}
		print "\n";
	}
	
}
close IN;
$dbh->disconnect;	

if ($up == 1)
{
	print OUT "UP_2000_MEAN";
	for (my $i = 0;$i<10;$i++)
	{
		my $inc_average = $up_inc_hash{$i}/$up_count_hash{$i};
		print OUT "\t$inc_average";
	}
	print OUT "\n";
	print OUT "UP_2000_STDEV";
	foreach my $row (0..@up_var_array-1)
	{
		my $stat = Statistics::Descriptive::Full->new();
		my @temp = @{$up_var_array[$row]};
	
		$stat->add_data(\@temp);
		my $mean = $stat->mean();
		my $variance  = $stat->variance();
		my $stdev = $stat->standard_deviation();
		print OUT "\t$stdev";
	}
	print OUT "\n";
}
print OUT "$type"."_MEAN";
for (my $i = 0;$i<10;$i++)
{
	my $inc_average = $inc_hash{$i}/$count_hash{$i};
	print OUT "\t$inc_average";
}
print OUT "\n";
print OUT "$type"."_STDEV";
foreach my $row (0..@var_array-1)
{
	my $stat = Statistics::Descriptive::Full->new();
	my @temp = @{$var_array[$row]};
	
	$stat->add_data(\@temp);
	my $mean = $stat->mean();
	my $variance  = $stat->variance();
	my $stdev = $stat->standard_deviation();
	print OUT "\t$stdev";
}
print OUT "\n";

if ($down == 1)
{
	print OUT "DOWN_2000_MEAN";
	for (my $i = 0;$i<10;$i++)
	{
		my $inc_average = $down_inc_hash{$i}/$down_count_hash{$i};
		print OUT "\t$inc_average";
	}
	print OUT "\n";
	print OUT "DOWN_2000_STDEV";
	foreach my $row (0..@down_var_array-1)
	{
		my $stat = Statistics::Descriptive::Full->new();
		my @temp = @{$down_var_array[$row]};
	
		$stat->add_data(\@temp);
		my $mean = $stat->mean();
		my $variance  = $stat->variance();
		my $stdev = $stat->standard_deviation();
		print OUT "\t$stdev";
	}
	print OUT "\n";
}
close OUT;
