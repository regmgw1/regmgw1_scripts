#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Obtain seq_id and seq from array design file (.ndf) and convert to .fastq file for use in maq.
=head2 Usage

Usage: ./ndf_to_fastq.pl path2ndf species(human/mouse) path2fastaqoutput path2maqoutput path2refgenome

=cut

#################################################################
# ndf_to_fastq.pl 
# Obtain seq_id and seq from array design file (.ndf) and convert to .fastq file for use in maq.
#################################################################
use strict;

unless (@ARGV ==5) {
        die "\n\nUsage:\n ./ndf_to_fastq.pl path2ndf species(human/mouse) path2fastaqoutput path2maqoutput path2refgenome\nPlease try again.\n\n\n";}

my $path2ndf = shift;
my $species = shift;
my $path2output = shift;
my $path2maqoutput = shift;
my $path2refgenome = shift;

my @chroms;

if ($species eq 'mouse')
{
	@chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,'X','Y');
}
elsif ($species eq 'human')
{
	@chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,'X','Y');
}
else
{
	print "Don't recognise species: $species. Exiting programme\n";
	die;
}

foreach my $chrom (@chroms)
{
	print "chr$chrom\n";
	my $count = 0;
	# create the fastq file
	open (OUT ,">$path2output/chr$chrom.fastq") or die "Can't open $path2ndf for writing";
	open (IN, "$path2ndf" ) or die "Can't open $path2ndf for reading";
	while (my $line = <IN>)
	{
		if ($count > 0)
		{
			chomp $line;
			my @elems = split/\t/, $line;
			my $seq_id = $elems[4];
			my $seq = $elems[5];
			my $probe_id = $elems[12];
			my @id_elems = split/:/,$seq_id;
			#print "$id_elems[0]\n";
			if ($id_elems[0] eq "chr$chrom")
			{
				print OUT "@".$probe_id."\n";
				print OUT "$seq\n+\n";
				my $length = length($seq);
				for(my $i=0;$i<$length;$i++)
				{
					print OUT "9";
				}
				print OUT "\n";
			}
		}
		$count++;
	}
	close OUT;
	# need to make output dir for maq data
	mkdir("$path2maqoutput$chrom");		
	# run maq
	my @args = ("maq.pl", "easyrun", "-d $path2maqoutput$chrom", "$path2refgenome/mm_ref_chr$chrom.fa", "$path2output/chr$chrom.fastq");
	system(@args) == 0
	or die "system @args failed: $?";
	
	if ($? == -1)
	{
		print "failed to execute: $!\n";
	}
	elsif ($? & 127)
	{
		printf "child died with signal %d, %s coredump\n",
		($? & 127),  ($? & 128) ? 'with' : 'without';
    	}
    	else
    	{
		printf "child exited with value %d\n", $? >> 8;
	}
	
	#format the mapping file to create a text file using maqview
	my $formatted_map = `maq mapview $path2maqoutput$chrom/all.map`;
	open (MAP ,">$path2maqoutput$chrom/all_map.txt") or die "Can't open $path2maqoutput$chrom/all_map.txt for writing";
	print MAP "$formatted_map";
	close MAP;
	
	# process the map file to generate a new gff file ready for input into batman with the correct coordinates. 
	#Do in seperate script so that maq only has to be run once for any experiment, can then use the maq output for any number of experiments.
	
}
close IN;
