#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Reads in output from intersectBed (vcf file vs bed file) and counts number of snps with allele freq > threshold. Counts snps at varying hscpg peak levels
=head2 Usage

Usage: ./hscpg_snps_allele_freq_v2.pl path2hscpgs path2snps max_peak_size path2output

=cut

#################################################################
# hscpg_snps_allele_freq_v2.pl
#################################################################

use strict;

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./hscpg_snps_allele_freq_v2.pl path2hscpgs path2snps max_peak_size path2output\nPlease try again.\n\n\n";}

my $path2hscpgs = shift;
my $path2snps = shift;
my $maxPeak = shift;
my $path2output = shift;

my (%hash);
for (my $i = 1;$i<=$maxPeak;$i++)
{
	$hash{$i} = 0;
}

open (OUT, ">$path2output") or die "Can't open $path2output for writing";
print OUT "Feature";
my $time = time();
for (my $i = 1;$i<=$maxPeak;$i++)
{
	print STDERR "$i\n";
	my $hscpg_in = "$path2output"."_tmp$time.tmp";
	open (TMP, ">$hscpg_in") or die "Can't open $hscpg_in for writing";
	open (DMR, $path2hscpgs ) or die "Can't open $path2hscpgs for reading";
	while (my $dmr = <DMR>)
	{
		$dmr =~s/chr//;
		my @elems = split/\t/, $dmr;
		if ($elems[4] eq ".")
		{
			print TMP "$dmr";
		}
		else
		{
			if ($elems[4] >= $i)
			{
				print TMP "$dmr";
			}
		}
	}
	close DMR;
	close TMP;
	my @count = `intersectBed -a $path2snps -b $hscpg_in -wa -wb`;
	foreach my $snp (@count)
	{
		chomp $snp;
		my @elems = split /\t/, $snp;
		my $info = $elems[7];
		if ($info =~m/AF=((0|1)\.\d{3});/)
		{
			my $freq = $1;
			if ($freq >= 0.05)
			{
				$hash{$i}++;
			}
		}
	}
	undef(@count);
	print OUT "\t$i";
	unlink ("$hscpg_in");
}
print OUT "\n";
print OUT "Thresh_0.05";
foreach my $num (sort {$a<=>$b} (keys %hash))
{
	print OUT "\t$hash{$num}";
	print "$num\n";
}
print OUT "\n";
close OUT; 


