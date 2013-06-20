#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
This script creates a gff file containing intergenic regions, using genes gff file as input
=head2 Usage

Usage: ./get_intergenic_v2.pl path2genes path2output

=cut


#################################################################
# get_intergenic_v3.pl
#################################################################


use strict;
$|=1;

unless (@ARGV ==4 ) {
        die "\n\nUsage:\n ./get_intergenic_v3.pl path2chrom versionID path2gffs path2output\nPlease try again.\n\n\n";}

my $path2chrom = shift;
my $version_id = shift;
my $path2files = shift;
my $path2output = shift;


my %end_chrom_hash;

open (IN, "$path2chrom" ) or die "Can't open $path2chrom for reading";
while (my $line = <IN>)
{
	chomp $line;	
	my @elems=split/\t/, $line;
	$end_chrom_hash{$elems[0]} = $elems[1];
}

foreach my $i (keys %end_chrom_hash)
{
    my $infile  = "$path2files/$i"."_genes.gff";
    my $outfile = "$path2output/$i"."_intergenics.gff";
    #my $infile  = "$path2files/$i"."_cpg_islands.gff";
    #my $outfile = "$path2output/$i"."_interIslands.gff";
    my $chr     = $i;
    my $start_count = 0;
    my $access_hash = $i;    
    open (IN, "$infile") or die "Can't open $infile for reading";
    open (OUT, ">$outfile") or die "Can't open $outfile for writing";
    my %data = ();
    
    while (<IN>) {
	chomp;
	
	my ($chrt, $t2, $t3, $start, $stop, @rest) = split /\t/, $_;
	if ($start_count == 0)
	{
		$data{0} = 0;
	}
	$data{$start} += 1;
	$data{$stop} += -1;
	$start_count++;
    }
    
    close IN;
    
	
    my @sorted_pos = sort {$a <=> $b} (keys %data);
    my $height = 0;
    my $pos_length = @sorted_pos;
    $chr =~s/chr//;
    for (my $j=0; $j<$pos_length; $j++)
    {
    	$height += $data{$sorted_pos[$j]};
    	my $end_point;
    	if ($j + 1 == $pos_length)
    	{
    		$end_point = $end_chrom_hash{$access_hash};
    	}
    	else
    	{
    		$end_point = $sorted_pos[$j+1] - 1;
    	}
    	if ($height == 0)
    	{
    		my $inter_s = $sorted_pos[$j] + 1;
		if ($end_point <= $inter_s)
		{
			next;
		}
		else
		{
			print OUT "$chr\tIntergenic_region\tchr$chr".":$inter_s"."-$end_point\t$inter_s\t$end_point\t.\t-\t.\t$version_id; get_intergenic_v3.pl\n";
		}
	}
    }
    			
    
    close OUT;
    print "$access_hash\n";
    
}
