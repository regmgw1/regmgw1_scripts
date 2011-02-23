#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Generate file listing log ratio of cnv value for regions across chromosome from two cnv input files.
=head2 Usage

Usage: ./cnv_all_base.pl species path2cnv path2cnv2 chrom

=cut

#################################################################
# cnv_all_base.pl
#################################################################

use strict;

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./cnv_all_base.pl species path2cnv path2cnv2 chrom\nPlease try again.\n\n\n";}

my $species = shift;
my $path2cnv = shift;
my $path2cnv2 = shift;
my $chrom = shift;

my (%startH,%startH2,%cnvH,%cnvH2,  %end_chrom_hash);

if ($species eq "mouse")
{
	%end_chrom_hash = (
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
}
elsif ($species eq "human36")
{
	%end_chrom_hash = (
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
}
elsif ($species eq "human37")
{
	%end_chrom_hash = (
        1 => '249250621',
        2 => '243199373',
        3 => '198022430',
        4 => '191154276',
        5 => '180915260',
        6 => '171115067',
        7 => '159138663',
        8 => '146364022',
        9 => '141213431',
        10 => '135534747',
        11 => '135006516',
        12 => '133851895',
        13 => '115169878',
        14 => '107349540',
        15 => '102531392',
        16 => '90354753',
        17 => '81195210',
        18 => '78077248',
        19 => '59128983',
        20 => '63025520',
        21 => '48129895',
        22 => '51304566',
        X => '155270560',
        Y => '59373566',        
	);
}
my $test_previous = 0;
open (IN, "$path2cnv" ) or die "Can't open $path2cnv for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	if ($elems[0] eq "chr$chrom")
	{
		# takes account of bug in input files whereby the end of previous has same coord as start of new region
		if ($elems[1] == $test_previous)
		{
			$startH{$elems[1]+1} = $elems[2];
			$cnvH{$elems[1]+1} = $elems[4];
		}
		else
		{
			$startH{$elems[1]} = $elems[2];
			$cnvH{$elems[1]} = $elems[4];
		}
		$test_previous = $elems[2];
	}
}
close IN;
$test_previous = 0;
open (IN, "$path2cnv2" ) or die "Can't open $path2cnv2 for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	if ($elems[0] eq "chr$chrom")
	{
		if ($elems[1] == $test_previous)
		{
			$startH2{$elems[1]+1} = $elems[2];
			$cnvH2{$elems[1]+1} = $elems[4];
		}
		else
		{
			$startH2{$elems[1]} = $elems[2];
			$cnvH2{$elems[1]} = $elems[4];
		}
		$test_previous = $elems[2];
	}
}
close IN;

my $time = time();
my $tmpOut = "cnv_tmp$time.tmp";
my @cnv1;

for (my $i = 1;$i<=$end_chrom_hash{$chrom};$i++)
{
	if (exists $startH{$i})
	{
		my $j = $i;
		while ($j <= $startH{$i})
		{
			push @cnv1,$cnvH{$i};
			$j++;
		}
		$i = $j-1;
	}
	else
	{
		push @cnv1,2;
	}
}
open (TMP, ">$tmpOut") or die "Can't open $tmpOut for writing";
for (my $i = 1;$i<=$end_chrom_hash{$chrom};$i++)
{
	if (exists $startH2{$i})
	{
		my $j = $i;
		while ($j <= $startH2{$i})
		{
			my $ind = $j-1;
			my $logRat = sprintf("%.2f",log($cnv1[$ind]) - log($cnvH2{$i}));
			
			#print TMP "j=$j\tcnv1=$cnv1[$ind]\tcnv2=$cnvH2{$i}\tlog=$logRat\n";
			print TMP "$logRat\n";
			$j++;
		}
		$i = $j-1;
	}
	else
	{
		my $ind = $i-1;
		my $logRat = log($cnv1[$ind]) - log(2);
		#print TMP "$i\t$cnv1[$ind]\t2\t$logRat\n";
		print TMP "$logRat\n";
	}
}
close TMP;
# parse through tmp file to create output akin to sgr file. remove tmp file.
my $prev_start = 1;
my $base_count = 0;
my $prev_base = 0;
open (TMP, "$tmpOut") or die "Can't open $tmpOut for writing";
while (my $line = <TMP>)
{
	chomp $line;
	if ($line != $prev_base)
	{
		print "$prev_start\t$base_count\t$prev_base\n";
		$prev_start = $base_count+1;
	}
	$base_count++;
	$prev_base = $line;
}
print "$prev_start\t$base_count\t$prev_base\n";
close TMP;
unlink ("$tmpOut");	
