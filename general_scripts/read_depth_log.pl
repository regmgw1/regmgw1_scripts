#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Generate file listing log ratio of read depth for regions across chromosome from two input files generated from bedtools genomeCoverage.

=head2 Usage

Usage: ./read_depth_log.pl species path2bed path2bed2 chrom

=cut

#################################################################
# read_depth_log.pl
#################################################################

use strict;

unless (@ARGV ==5) {
        die "\n\nUsage:\n ./read_depth_log.pl species path2bed path2bed2 chrom window_size\nPlease try again.\n\n\n";}

my $species = shift;
my $path2bed = shift;
my $path2bed2 = shift;
my $chrom = shift;
my $ws = shift;

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

my $time = time();
my $tmpOut = "cover_tmp$time.tmp";
my $tmpBed = "cover_1_tmp$time.bed";
my $tmpBed2 = "cover_2_tmp$time.bed";
my $tmpChr = "tmp$time.chrom.sizes";
open (TMPC, ">$tmpChr") or die "Can't open $tmpChr for writing";
print TMPC "chr$chrom\t$end_chrom_hash{$chrom}";
close TMPC;

print STDERR "Processing BED file 1\n";
system("grep ^chr$chrom $path2bed >$tmpBed");
my $sampleSize1 = `wc -l <$tmpBed`;
print STDERR "chr$chrom bed1 sample size = $sampleSize1\n"; 
system("genomeCoverageBed -d -i $tmpBed -g $tmpChr|cut -f 3 >$tmpOut");
unlink ("$tmpBed");
print STDERR "Processing BED file 2\n";
system("grep ^chr$chrom $path2bed2 >$tmpBed2");
my $sampleSize2 = `wc -l <$tmpBed2`;
print STDERR "chr$chrom bed2 sample size = $sampleSize2\n"; 
my @cover2 = `genomeCoverageBed -d -i $tmpBed2 -g $tmpChr|cut -f 3`;
unlink ("$tmpBed2");
my $count = 0;
my @rats;
print STDERR "Calculating ratios\n";
open (TMP, "$tmpOut") or die "Can't open $tmpOut for reading";
while (my $line = <TMP>)
{
	chomp $line;
	my ($norm1,$norm2);
	if ($line == 0)
	{
		$norm1 = 0;
	}
	else
	{
		$norm1 = ($line*1000000)/$sampleSize1;
	}
	if ($cover2[$count] == 0)
	{
		$norm2 = 0;
	}
	else
	{
		$norm2 = ($cover2[$count]*1000000)/$sampleSize2;
	}
	my $logRat = sprintf("%.2f",log($norm1+1) - log($norm2+1));
	push @rats, $logRat;
	$count++;
}
close TMP;
undef(@cover2);
print STDERR "Generating output data\n";
# parse through @rats to create output averaged over given window size. remove tmp files.
my $prev_start = 1;
my $base_count = 1;
my $prev_base = 0;

my $cum_base = 0;
my $incre_count = 1;
my $av_base;
foreach my $rat (@rats)
{
	chomp $rat;
	$cum_base += $rat;
	if ($incre_count == $ws)
	{
		$av_base = $cum_base/$ws;
		print "$prev_start\t$base_count\t$av_base\n";
		$cum_base = 0;
		$incre_count = 1;
	}
	else
	{
		$incre_count++;
	}
	$base_count++;
}
print "$prev_start\t$base_count\t$av_base\n";
unlink ("$tmpOut","$tmpChr");
