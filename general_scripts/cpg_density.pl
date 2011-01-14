#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Calculate CpG density across chrom
=head2 Usage

Usage: ./cpg_density.pl path2featuredata path2output path2seq chr window_size
 
=cut

#################################################################
# cpg_coverage.pl 
#################################################################
use strict;
use Bio::SeqIO;
use Math::Round qw(:all);

unless (@ARGV ==5) {
        die "\n\nUsage:\n ./cpg_density.pl path2featuredata path2output path2seq chr window_size\nPlease try again.\n\n\n";}

my $path2data = shift;
my $path2output = shift;
my $path2seq = shift;
my $chr = shift;
my $w_size = shift;

my $seq_in = Bio::SeqIO->new(-format=>'fasta', -file=>"$path2seq");
my $seq_ob = $seq_in->next_seq();

open (OUT, ">$path2output" ) or die "Can't open $path2output for writing";
print OUT "Chrom\tStart\tStop\tC\tG\tCG\tCpG(o/e)\n";
	
open (IN, "$path2data" ) or die "Can't open $path2data for reading";
while (my $line = <IN>)
{
	print "$line";
	chomp $line;
	my @elems = split/\t/, $line;
	my $start = $elems[0];
	my $stop = $elems[1];
	# round the coords to nearest batman windows
	my $window_start = nlowmult(100, $start) + 1;
	my $window_stop = nhimult(100, $stop);
	
	while ($window_start < $window_stop)
	{
		my $temp_stop = $window_start + ($w_size-1);
		my $winseq = $seq_ob->subseq($window_start, $temp_stop);
		my @cgs = ($winseq =~/CG/g);
		my $cg_count = @cgs;
		my @gs = ($winseq =~/G/g);
		my $g_count = @gs;
		my @cs = ($winseq =~/C/g);
		my $c_count = @cs;
		if ($c_count > 0 && $g_count > 0)
		{
			my $ratio = ($cg_count * $w_size)/($g_count * $c_count);
			if ($ratio > 0)
			{
				print OUT "$chr\t$window_start\t$temp_stop\t$c_count\t$g_count\t$cg_count\t$ratio\n";
			}
		}
		$window_start = $window_start + $w_size;
	}
}
close IN;
close OUT;
