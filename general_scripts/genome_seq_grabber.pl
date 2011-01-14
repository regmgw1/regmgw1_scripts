#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
obtains the specified region of the given genome, output as fasta

=head2 Usage

Usage: ./genome_seq_grabber.pl path2genomefile header start_coord stop_coord path2output

=cut

#################################################################
# genome_seq_grabber.pl
#################################################################

use strict;
use Bio::SeqIO;

unless (@ARGV ==5 ) {
        die "\n\nUsage:\n ./genome_seq_grabber.pl path2genomefile header start_coord stop_coord path2output\nPlease try again.\n\n\n";}

my $path2genome = shift;
my $header = shift;
my $start = shift;
my $stop = shift;
my $path2output = shift;

my $seq_in = Bio::SeqIO->new(-format=>'fasta', -file=>"$path2genome");
my $seq = $seq_in->next_seq();
my $subseq = $seq->subseq($start, $stop);

open (OUT, ">$path2output") or die "Can't open $path2output for writing";
print OUT ">$header\n";
print OUT "$subseq";
close OUT;
