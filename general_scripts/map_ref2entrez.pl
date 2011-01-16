#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
obtain refseq id and coords from refgene_ucsc.txt. Map id to reflink_ucsc.txt to obtain entrez id
=head2 Usage

Usage: ./map_ref2entrez path2ref_files

=cut

#################################################################
# map_ref2entrez.pl - obtain refseq id and coords from refgene_ucsc.txt. Map id to reflink_ucsc.txt to obtain entrez id
#################################################################

unless (@ARGV ==1) {
        die "\n\nUsage:\n ./map_ref2entrez path2ref_files\nPlease try again.\n\n\n";}

my $path2ref_files = shift;

my %link;

open (LINK, "$path2ref_files/reflink_ucsc.txt" ) or die "Can't open $path2ref_files for reading";
while (my $line = <LINK>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	$link{$elems[2]} = $elems[6];
}
close LINK;
open (GENE, "$path2ref_files/refgene_ucsc.txt" ) or die "Can't open $path2ref_files for reading";
while (my $line = <GENE>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	my $chr = $elems[2];
	$chr =~s/chr//;
	if (exists $link{$elems[1]})
	{
		if ($link{$elems[1]} > 0)
		{
			print "$chr\tGene_$link{$elems[1]}\t$chr".":$elems[4]"."-$elems[5]\t$elems[4]\t$elems[5]\t.\t$elems[3]\t.UCSC_AssemblyFeb2009\n";
		}
	}
	else
	{
		print "MISSING $elems[1] !!!\n";
	}
}
close GENE;
