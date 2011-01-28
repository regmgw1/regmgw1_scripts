#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Utilises bedTools to find overlaps between repeats and hscpgs at incrementally increasing cluster counts
=head2 Usage

Usage: /hscpg_in_repeats_bedtools.pl path2hscpgs path2featureList path2features max_cluster_number path2output

=cut

#################################################################
# hscpg_in_repeats_bedtools.pl
#################################################################


use strict;

unless (@ARGV ==5) {
        die "\n\nUsage:\n ./peaks_in_repeats_bedtools.pl path2hscpgs path2featureList path2features max_peak_size path2output\nPlease try again.\n\n\n";}

my $path2hscpgs = shift;
my $path2list = shift;
my $path2feature = shift;
my $maxPeak = shift;
my $path2output = shift;

my (%hash);

open (OUT, ">$path2output") or die "Can't open $path2output for writing";
print OUT "Repeat";
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
		if ($elems[4] >= $i)
		{
			print TMP "$dmr";
		}
	}
	close DMR;
	close TMP;
	open (IN, "$path2list" ) or die "Can't open $path2list for reading";
	while (my $line = <IN>)
	{
		print STDERR $line;
		chomp $line;
		open (TMP, ">$path2output"."_tmp$time.rep") or die "Can't open $path2output"."_tmp$time.rep for writing";
		#open (REP, "$path2feature/repeat_family/repeat_family.gff" ) or die "Can't open $path2feature/repeat_family/repeat_family.gff for reading";
		open (REP, "$path2feature/repeats/alus/alu.gff" ) or die "Can't open $path2feature$path2feature/repeats/alus/alu.gff for reading";
		while (my $reps = <REP>)
		{
			chomp $reps;
			my @elems = split /\t/,$reps;
			my $temp_fam = $elems[1];
			$temp_fam =~s/Repeat_//;
			my $family;
			if ($temp_fam =~m/(.*)\//)
			{
				$family = $1;
			}
			else
			{
				$family = $temp_fam;
			}
			if ($family eq $line)
			{
				print TMP "$reps\n";
			}
		}
		close REP;
		close TMP;
		my $rep_in = "$path2output"."_tmp$time.rep";
		my @count = `intersectBed -a $hscpg_in -b $rep_in -u`;
		#my @count = `intersectBed -a $hscpg_in -b $path2feature/$line/$line"."gff -u`;
		my $out = $#count + 1;
		$hash{$line}{$i} = $out;
		undef(@count);
		unlink($rep_in);
	}
	close IN;
	print OUT "\t$i";
	unlink ($hscpg_in);
}
print OUT "\n";
foreach my $feat (sort(keys %hash))
{
	print OUT "$feat";
	foreach my $num (sort {$a<=>$b} (keys %{$hash{$feat}}))
	{
		print OUT "\t$hash{$feat}{$num}"
	}
	print OUT "\n";
}
close OUT; 


