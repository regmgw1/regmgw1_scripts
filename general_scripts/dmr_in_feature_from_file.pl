#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Determine what feature each dmr falls in and print out to relevant file
=head2 Usage

Usage: ./dmr_in_feature_from_file.pl feature_type path2data path2output sample1 sample2 hyper_table hypo_table

=cut

#################################################################
# dmr_in_feature_from_file.pl
#################################################################

use strict;
use DBI;

unless (@ARGV ==7) {
        die "\n\nUsage:\n ./dmr_in_feature_from_file.pl feature_type path2data path2output sample1 sample2 hyper_table hypo_table\nPlease try again.\n\n\n";}

my $path2featurelist = shift;
my $path2data = shift;
my $path2output = shift;
my $sample1 = shift;
my $sample2 = shift;
my $hyper_tab= shift;
my $hypo_tab = shift;

my @chroms = (22,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21);
my @types;
open (IN, "$path2featurelist" ) or die "Can't open $path2featurelist for reading";
while (my $line = <IN>)
{
	chomp $line;
	push @types, $line;
}
close IN;

foreach my $repeat (@types)
{
	my $hyper = 0;
	my $hypo = 0;
	my $hyper_bases = 0;
	my $hypo_bases = 0;
	my $feature_count = 0;
	my %unique;
	open (HYPER, ">$path2output/$repeat"."_hyper_$sample1"."_$sample2".".txt") or die "Can't open $path2output for writing";
	open (HYPO, ">$path2output/$repeat"."_hypo_$sample1"."_$sample2".".txt") or die "Can't open $path2output for writing";
	my $dbh = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
        	{ RaiseError => 1,
                AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";
                                       
	open (IN, "$path2data" ) or die "Can't open $path2data for reading";
	while (my $line = <IN>)
	{
		my @data = split /\t/,$line;
		my $chr = $data[1];
		my $start = $data[2];
		my $stop = $data[3];
		my $coords = $chr."_".$start;
		if (exists $unique{$coords})
		{
			next;
		}
		else
		{
			$unique{$coords} = "";
		}
		my $feature_length = $stop - $start;
		$feature_count++;
		my $ok = 0;
		my $region_count = 0;
		my $sth_er = $dbh->prepare("SELECT id,chr,start,stop FROM $hyper_tab where start < $stop and stop > $start and chr = '$chr'")
	       	        or die "Couldn't prepare statement: " . $dbh->errstr;
		$sth_er->execute()             # Execute the query
			or die "Couldn't execute statement: " . $sth_er->errstr;
		while (my @hyper = $sth_er->fetchrow_array())
		{
			# only count if >50% DMR found within region
			my $dmr_length = $hyper[3] - $hyper[2];
			if ($hyper[2] > $start && $hyper[3] > $stop)
			{
				my $overlap = $stop - $hyper[2];
				if ($overlap/$dmr_length > 0.5)
				{
					$ok = 1;
				}
				elsif ($feature_length < 500 && $overlap/$feature_length > 0.5)
				{
					$ok = 1;
				}
			}
			elsif ($hyper[2] < $start && $hyper[3] < $stop)
			{
				my $overlap = $hyper[3] - $stop;
				if ($overlap/$dmr_length > 0.5)
				{
					$ok = 1;
				}
				elsif ($feature_length < 500 && $overlap/$feature_length > 0.5)
				{
					$ok = 1;
				}
			}
			else
			{
				$ok = 1;
			}
			if ($ok == 1)
			{
				$hyper++;
				if ($region_count == 0)
				{
					my $region = $stop - $start;
					$hyper_bases += $region;
					$region_count++;
				}
				print HYPER "$chr\t$start\t$stop\t$hyper[1]\t$hyper[2]\t$hyper[3]\n";
			}
		}
		$ok = 0;
		$region_count = 0;
		my $sth_o = $dbh->prepare("SELECT id,chr,start,stop FROM $hypo_tab where start < $stop and stop > $start and chr = '$chr'")
       		        or die "Couldn't prepare statement: " . $dbh->errstr;
		$sth_o->execute()             # Execute the query
			or die "Couldn't execute statement: " . $sth_o->errstr;
		while (my @hypo = $sth_o->fetchrow_array())
		{
			my $dmr_length = $hypo[3] - $hypo[2];
			if ($hypo[2] > $start && $hypo[3] > $stop)
			{
				my $overlap = $stop - $hypo[2];
				if ($overlap/$dmr_length > 0.5)
				{
					$ok = 1;
				}
				elsif ($feature_length < 500 && $overlap/$feature_length > 0.5)
				{
					$ok = 1;
				}
			}
			elsif ($hypo[2] < $start && $hypo[3] < $stop)
			{
				my $overlap = $hypo[3] - $stop;
				if ($overlap/$dmr_length > 0.5)
				{
					$ok = 1;
				}
				elsif ($feature_length < 500 && $overlap/$feature_length > 0.5)
				{
					$ok = 1;
				}
			}
			else
			{
				$ok = 1;
			}
			if ($ok == 1)
			{
				$hypo++;
				if ($region_count == 0)
				{
					my $region = $stop - $start;
					$hypo_bases += $region;
					$region_count++;
				}
				print HYPO "$chr\t$start\t$stop\t$hypo[1]\t$hypo[2]\t$hypo[3]\n";
			}
		}	
	}
	close IN;
	$dbh->disconnect;

	my $hyper_per_base;
	my $hypo_per_base;
	my $hyper_per_feature;
	my $hypo_per_feature;
	if ($hyper > 0)
	{
		$hyper_per_base = $hyper/$hyper_bases;
		$hyper_per_feature = $hyper/$feature_count;
	}
	else
	{
		$hyper_per_base = 0;
		$hyper_per_feature = 0;
	}
	if ($hypo > 0)
	{
		$hypo_per_base = $hypo/$hypo_bases;
		$hypo_per_feature = $hypo/$feature_count;
	}
	else
	{
		$hypo_per_base = 0;
		$hypo_per_feature = 0;
	}
	print "Hyper in $repeat = $hyper\nHyper per feature in $repeat = $hyper_per_feature\nHypo in $repeat = $hypo\nHypo per feature in $repeat = $hypo_per_feature\n";		
	close HYPO;
	close HYPER;
}		
