#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Reads in output from intersectBed (vcf file vs bed file) and counts number of snps with allele freq > threshold for a spectrum of thresholds. Example of input file = hsCpG_snp1000GenomeDec.txt
=head2 Usage

Usage: ./hscpg_snps_allele_freq.pl path2hscpgSNP allele_freq_threshold path2output

=cut

#################################################################
# hscpg_snps_allele_freq.pl
#################################################################


use strict;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./hscpg_snps_allele_freq.pl path2hscpgSNP total_hsCpGs\nPlease try again.\n\n\n";}

my $path2hscpgs = shift;
my $totalCpGs = shift; #1820319

my %hash;
my $line_count = 0;

for (my $i = 0;$i<=0.051;$i+=0.001)
{
	$hash{$i} = 0;
}
open (CPG, $path2hscpgs ) or die "Can't open $path2hscpgs for reading";
while (my $line = <CPG>)
{
	chomp $line;
	my @elems = split /\t/, $line;
	my $info = $elems[7];
	if ($info =~m/AF=((0|1)\.\d{3});/)
	{
		my $freq = $1;
		for (my $i = 0;$i<=0.051;$i+=0.001)
		{
			if ($freq >= $i)
			{
				$hash{$i}++;
			}
		}
	}
	else
	{
		print STDERR "eh!? $info\n";
	}
	$line_count++;
}
print "Allele_Frequency\tCount\tPercent\tPercent_of_total\n";
foreach my $key (sort {$a<=>$b} (keys %hash))
{
	my $percent = sprintf("%.2f",($hash{$key}/$line_count) * 100);
	my $total_percent = sprintf("%.2f",($hash{$key}/$totalCpGs) * 100);
	print "$key\t$hash{$key}\t$percent\t$total_percent\n";
}
