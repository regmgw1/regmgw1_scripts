#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Determine how many reads are found under peaks. peak_explorer_bedtools.pl is much quicker.
=head2 Usage

Usage: ./peaks_in_feature.pl sample_list path2bedDir path2peakroot path2peaklist

=cut

#################################################################
# peaks_explorer.pl
#################################################################

use strict;

unless (@ARGV ==5) {
        die "\n\nUsage:\n ./peaks_in_feature.pl sample_list path2bedDir path2peakroot path2peaklist\nPlease try again.\n\n\n";}

my $path2samplelist = shift;
my $path2bed = shift;
my $path2peakroot = shift;
my $path2peaklist = shift;
my $path2output = shift;

my (@samples, @peak_subs);

# open list of sample names and store in array
open (IN, "$path2samplelist" ) or die "Can't open $path2samplelist for reading";
while (my $line = <IN>)
{
	chomp $line;
	push @samples, $line;
}
close IN;

# open list of directory names containing peaks and store in array
open (IN, "$path2peaklist" ) or die "Can't open $path2peaklist for reading";
while (my $line = <IN>)
{
	chomp $line;
	push @peak_subs, $line;
}
close IN;

foreach my $peaksub (@peak_subs)
{
	open (OUT, ">$path2output/$peaksub"."_peak_explore.txt") or die "Can't open $path2output/$peaksub"."_peak_explore.txt for writing";
	my %peak;
	my (%pos_strand, %neg_strand, %king, %explorer);
	my $peakfile = $peaksub;
	$peakfile =~s/.*Binary/binary/;
	my $count = 0;
	print "$peaksub\n";
	# open file containing info on significant dmrs. Foreach dmr, store the coordinate in a hash.
	open (PEAK, "$path2peakroot/$peaksub/$peakfile".".gff" ) or die "Can't open $path2peakroot/$peaksub/$peakfile".".gff for reading";
	while (my $line = <PEAK>)
	{
		if ($count > 0 && $line !~m/^\#/)
		{
			chomp $line;
			my @elems = split /\t/,$line;
			my $begin = $elems[3];
			my $end = $elems[4];
			my $chr = $elems[0];
			$chr =~s/chr//;
			$peak{$chr}{$begin} = 0;
			$pos_strand{$chr}{$begin} = 0;
			$neg_strand{$chr}{$begin} = 0;
			my $inc = $begin;
			while ($inc <= $end)
			{
				$explorer{$chr}{$inc} = $begin;
				$inc++;
			}
		}
		$count++;
	}
	close PEAK;
	print OUT "Chr\tPeakStart";
	my @chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19);
	# for every sample, read through the bed file, process chrom at a time, determine if a read is contained in a dmr and if so store the strand it's found on.
	foreach my $sample (sort @samples)
	{
		my @bed;
		print OUT "\t$sample Both\t$sample pos\t$sample neg";
		open (FEAT, "$path2bed/$sample".".bed" ) or die "Can't open $path2bed/$sample".".bed for reading";
		while (my $line = <FEAT>)
		{
			push @bed, $line;
		}
		close FEAT;
		foreach my $chrom (@chroms)
		{
			my @tmp;
			my @chr_bed = grep(m/chr$chrom/, @bed);
			foreach my $line (@chr_bed)
			{
				chomp $line;
				my @elems = split /\t/,$line;
				my $begin = $elems[1];
				my $end = $elems[2];
				my $strand = $elems[5];
				my $state = 0;
				while ($begin <= $end && $state == 0)
				{
					if (exists $explorer{$chrom}{$begin})
					{
						my $real_peak_begin = $explorer{$chrom}{$begin};
						$peak{$chrom}{$real_peak_begin}++;
						if ($strand eq "+")
						{
							$pos_strand{$chrom}{$real_peak_begin}++;
						}
						elsif ($strand eq "-")
						{
							$neg_strand{$chrom}{$real_peak_begin}++;
						}
						push @tmp, $line;
						$state = 1;
					}
					$begin++;
				}
			}
		}
		# Add the relevant counts to the king hash.
		foreach my $chr_out (keys %peak)
		{
			for my $begin_out (keys %{$peak{$chr_out}})
			{
				$king{$chr_out}{$begin_out}{$sample} = "$peak{$chr_out}{$begin_out}\t$pos_strand{$chr_out}{$begin_out}\t$neg_strand{$chr_out}{$begin_out}";
				$peak{$chr_out}{$begin_out} = 0;
				$pos_strand{$chr_out}{$begin_out} = 0;
				$neg_strand{$chr_out}{$begin_out} = 0;
			}
		}		
	}
	print OUT "\n";
	# once all samples have been processed, can print out the data stored in the king hash.
	foreach my $chr_out (sort numerically keys %king)
	{
		for my $begin_out (sort numerically keys %{$king{$chr_out}})
		{
			print OUT "$chr_out\t$begin_out";
			foreach my $samp_out (sort keys %{$king{$chr_out}{$begin_out}})
			{
				print OUT "\t$king{$chr_out}{$begin_out}{$samp_out}";
			}
			print OUT "\n";
		}
	}
	close OUT;
}

sub numerically {$a<=>$b};			
