#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Removes random lines from pippy files
=head2 Usage

Usage: ./pippy_random_line_removal.pl path2pip_in path2fileslist max_lines path2output

=cut

#################################################################
# pippy_random_line_removal.pl
#################################################################

use strict;
use File::Basename;

unless (@ARGV ==4) {
        die "\n\nUsage:\n ./pippy_random_line_removal.pl path2pip_in path2fileslist max_lines path2output\nPlease try again.\n\n\n";}

my $path2input = shift;
my $path2fileslist = shift;
my $threshold = shift;
my $path2output = shift;

my (@all, @gff_files);
my %rem;

open (FILES, "$path2fileslist" ) or die "Can't open $path2fileslist for reading";
while (my $gff_file = <FILES>)
{
	chomp $gff_file;
	print "file = $gff_file\n";
	push @gff_files, $gff_file;
	open (IN, "$path2input/$gff_file" ) or die "Can't open $path2input/$gff_file for reading";
	while (my $line = <IN>)
	{
		push @all, $line;
	}
	close IN;
}
close FILES;
my $length = $#all + 1;
print "$length\n";
my $removal = $length - $threshold;
print "$removal\n";
open (OUT, ">$path2output/removed_lines.txt") or die "Can't open $path2output/removed_lines.txt for writing";
for (my $i = 0;$i<=$removal;$i++)
{
	my $random = $all[int(rand($length))];
	
	my @elems = split/\t/, $random;
	my $coords = $elems[0]."_".$elems[3]."_".$elems[4];
	if (exists $rem{$coords})
	{
		$i--;
	}
	else
	{
		$rem{$coords} = $coords;
		print OUT "$random";
	}
}
close OUT;
my $hash_size = scalar(keys %rem);
print "hash sizze = $hash_size\n";
my $rem_count;
foreach my $gff_file (@gff_files)
{
	print "file = $gff_file\n";
	open (OUT, ">$path2output/$gff_file"."_mod") or die "Can't open $path2output/$gff_file"."_mod for writing";

	open (IN, "$path2input/$gff_file" ) or die "Can't open $path2input/$gff_file for reading";
	while (my $line = <IN>)
	{
		my @elems = split/\t/, $line;
		my $coords = $elems[0]."_".$elems[3]."_".$elems[4];
		if (exists $rem{$coords})
		{
			$rem_count++;
			next;
		}
		else
		{
			print OUT "$line";
		}
	}
	close IN;
	close OUT;
}
print "$rem_count\n";


