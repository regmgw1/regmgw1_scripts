#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
passes through files looking for consistency in coorodinates of regions. if all files contain the same coordinate for a given region, it will printed to output.
=head2 Usage

Usage: ./gap_filling.pl  path2files (comma separated) path2output (comma separated) chr species

=cut

#################################################################
# gap_filling.pl 
# 
#################################################################
use strict;
use IO::File;

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./gap_filling.pl  path2files (comma separated) path2output (comma separated) chr species\nPlease try again.\n\n\n";}

my $path2files = shift;
my $path2output = shift;
my $chr = shift;
my $species = shift;

my @input = split/,/,$path2files;
my @output = split/,/,$path2output;

my %fht;
#create filehandles for all output files
my $out_count = 0;
foreach my $file (@output)
{
	my $fh = new IO::File(">$file") or die "can't write to file";
	$fht{$out_count} = $fh;
	$out_count++;
}

my $file_number = $#input;
my %file_hash;
my $count = 0;

# parse each input file and put contents in hash of hashes (file_hash)
foreach my $input (@input)
{
	open (IN, "$input" ) or die "Can't open $input for reading";
	while (my $line = <IN>)
	{
		chomp $line;
		my @elems = split/\t/, $line;
		$file_hash{$count}{$elems[3]} = $line;
	}
	$count++;
	close IN;
}
#obtain length of chrom and use to increment through file_hash
my $chrom_length = chrom_length($species, $chr);		
for (my $i = 1;$i<$chrom_length;$i+=100)
{
	my $fh;
	my $ex_count = 0;
	my $ok = 0;
	my $ok_string;
	# for each input file in file hash determine if value exists for given key (coordinate)
	while ($ex_count <= $file_number)
	{
		if (exists $file_hash{$ex_count}{$i})
		{
			$ok++;
			$ok_string .= " ".$ex_count;
		}
		
		$ex_count++;
	}
	# if exists in all files, values can be printed to output files
	if ($ok == $file_number+1)
	{
		my $print_count = 0;
		while ($print_count <= $file_number)
		{
			$fh = $fht{$print_count};
			print $fh "$file_hash{$print_count}{$i}\n";
			$print_count++;
		}
	}
	elsif ($ok > 0)
	{
		print "chr$chr\t$i\t$ok_string\n";
	}
	
}

# close all output files
foreach my $fh (values (%fht))
{
	close $fh;
}

sub chrom_length
{
	my $species = shift;
	my $chr = shift;
	my $chr_length;
	my %human_chrom_hash = (
        1 => '247249719',
        2 => '242951149',
        3 => '199501827',
        4 => '191273063',
        5 => '180857866',
        6 => '170899992',
        7 => '158821424',
        8 => '146274826',
        9 => '140273252',
        10 => '135374737',
        11 => '134452384',
        12 => '132349534',
        13 => '114142980',
        14 => '106368585',
        15 => '100338915',
        16 => '88827254',
        17 => '78774742',
        18 => '76117153',
        19 => '63811651',
        20 => '62435964',
        21 => '46944323',
        22 => '49691432',
        X => '154913754',
        Y => '57772954',      
	);
	my %mouse_chrom_hash = (
        1 => '197195432',
        2 => '181748087',
        3 => '159599783',
        4 => '155630120',
        5 => '152537259',
        6 => '149517037',
        7 => '152524553',
        8 => '131738871',
        9 => '124076172',
        10 => '129993255',
        11 => '121843856',
        12 => '121257530',
        13 => '120284312',
        14 => '125194864',
        15 => '103494974',
        16 => '98319150',
        17 => '95272651',
        18 => '90772031',
        19 => '61342430',
        X => '166650296',
        Y => '15902555',      
	);
	if ($species eq "mouse")
	{
		$chr_length = $mouse_chrom_hash{$chr};
	}
	elsif ($species eq "human")
	{
		$chr_length = $human_chrom_hash{$chr};
	}
	return $chr_length;
}
