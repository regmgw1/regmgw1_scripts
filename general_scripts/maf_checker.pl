#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
parse .maf file using bioperl alignio. Determine whether any regions overlap
=head2 Usage

Usage: ./maf_checker.pl path2maf

=cut

#################################################################
# maf_checker.pl - parse .maf file using bioperl alignio. 
# Determine whether any regions overlap
#################################################################

use Bio::AlignIO;

unless (@ARGV ==1) {
        die "\n\nUsage:\n ./maf_checker.pl path2maf \nPlease try again.\n\n\n";}

my $path2input = shift;

$in  = Bio::AlignIO->new(-file => "$path2input", '-format' => 'maf');
while(my $aln = $in->next_aln())
{
	foreach my $seq ($aln->each_seq)
	{
		my $start = $seq->start - 1;
		my $stop = $seq->end - 1;
		print "$start .... $stop\n";
		$hash{$start} = $stop;
		last;
	}
}
my $prev_stop = 0;
foreach my $key (sort { $a <=> $b }(keys %hash))
{
	if ($key < $prev_stop)
	{
		print "$prev_stop\t$key\t$hash{$key}\n";
	}
	$prev_stop = $hash{$key};
}	
