#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
produces files of first last inter exons & introns. Use v3!!
=head2 Usage

Usage: ./first_exon_last_exon_v2.pl path2exons path2output gene_select?(0|path2list)

=cut

#################################################################
# first_exon_last_exon_v2.pl 
#################################################################

use strict;
use DBI;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./first_exon_last_exon_v2.pl path2exons path2output gene_select?(0|path2list)\nPlease try again.\n\n\n";}

my $path2exons = shift;
my $path2output = shift;
my $gene_select = shift;

my $max_line = 0;
my $max_pos = 1;
my $old_id = 0;
my $first_line;
my $single_count = 0;
my @genes;
my $first_intron_start;
my $first_intron_stop;

my $dbh = DBI->connect("DBI:mysql:database=db1;host=localhost", "user", "pass",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";
 
open (FIRST, ">$path2output/first_exons.gff" ) or die "Can't open $path2output for writing";
open (INTER, ">$path2output/inter_exons.gff" ) or die "Can't open $path2output for writing";
open (LAST, ">$path2output/last_exons.gff" ) or die "Can't open $path2output for writing";
open (FINT, ">$path2output/first_intron.gff" ) or die "Can't open $path2output for writing";
open (INTRON, ">$path2output/introns.gff" ) or die "Can't open $path2output for writing";

if ($gene_select ne "0")
{
	open (LIST, "$gene_select" ) or die "Can't open $gene_select for reading";
	@genes = <LIST>;
	close LIST;
}


open (IN, "$path2exons" ) or die "Can't open $path2exons for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	my $trans_id = $elems[0];
	my $ex_pos = $elems[5];
	my $start = $elems[3];
	my $stop = $elems[4];
	
	my $ok = 1;
	if ($gene_select ne "0")
	{
		my $ens_id = $elems[8];
		my $match = 0;
		foreach my $gene (@genes)
		{
			chomp $gene;
			if ($gene =~m/$ens_id/)
			{
				$match = 1;
			}
		}
		if ($match == 0)
		{
			$ok = 0;
		}
	}
	if ($ok == 1)
	{
		my $gff = "$elems[2]\t$elems[0]"."_$elems[1]\tchr$elems[2]".":$elems[3]"."-$elems[4]\t$elems[3]\t$elems[4]\t.\t.\t$elems[5]\tBiomart52";
		
		if ($trans_id eq $old_id)
		{
			if ($ex_pos == 1)
			{
				$first_line = $gff;
				$first_intron_start = $stop + 1;
				$first_intron_stop = intron_find($first_intron_start, $elems[2]);
				intron_print($first_intron_start,$first_intron_stop,$elems[2],1)
			}
			elsif ($ex_pos > $max_pos)
			{
				$max_pos = $ex_pos;
				if ($max_line ne "0")
				{
					print INTER "$max_line\n";
					my $intron_start = $stop+1;
					my $intron_stop = intron_find($intron_start, $elems[2]);
					intron_print($intron_start,$intron_stop,$elems[2],0)

				}
				$max_line = $gff;
			}
			else
			{
				print INTER "$gff\n";
				my $intron_start = $stop + 1;
				my $intron_stop = intron_find($intron_start, $elems[2]);
				intron_print($intron_start,$intron_stop,$elems[2],0)
			}
		
		}
		else
		{
			if ($max_line ne "0")
			{
				print FIRST "$first_line\n";
				print LAST "$max_line\n";
				intron_print($first_intron_start,$first_intron_stop,$elems[2],1)
			}
			else
			{
				$single_count++;
			}
			$old_id = $trans_id;
			$max_pos = 1;
			$max_line = 0;
			if ($ex_pos == 1)
			{
				$first_line = $gff;
				$first_intron_start = $stop + 1;
				$first_intron_stop = intron_find($first_intron_start, $elems[2]);
			}
			elsif ($ex_pos > $max_pos)
			{
				$max_pos = $ex_pos;
				if ($max_line ne "0")
				{
					print INTER "$max_line\n";
					my $intron_start = $stop + 1;
					my $intron_stop = intron_find($intron_start, $elems[2]);
					intron_print($intron_start,$intron_stop, $elems[2],0)
				}
				$max_line = $gff;
			}
		}
	}
}
close IN;
close FIRST;
close INTER;
close LAST;
close FINT;
close INTRON;	
print "singleton = $single_count\n";
$dbh->disconnect;

sub intron_find
{
	my $intron_start = shift;
	my $chr = shift;
	my $istop;
	my $count = 0;
	my $sth1 = $dbh->prepare("SELECT stop FROM introns where chr = '$chr' and start = $intron_start")
       	       	 or die "Couldn't prepare statement: " . $dbh->errstr;
	$sth1->execute()             # Execute the query
	 	or die "Couldn't execute statement: " . $sth1->errstr;

	while (my @data = $sth1->fetchrow_array())
	{
		$istop = $data[0];
		$count++;
	}
	if ($count == 0)
	{
		$istop = 0;
	}
	return $istop;
}

sub intron_print
{
	my $intron_start = shift;
	my $intron_stop = shift;
	my $chr = shift;
	my $first = shift;
	if ($intron_stop ne "0")
	{
		if ($first == 1)
		{
			print FINT "$chr\tFirst_Intron\tchr$chr".":$intron_start"."-$intron_stop\t$intron_start\t$intron_stop\t.\t.\t.\tBiomart52\n";
		}
		else
		{
			print INTRON "$chr\tIntron\tchr$chr".":$intron_start"."-$intron_stop\t$intron_start\t$intron_stop\t.\t.\t.\tBiomart52\n";
		}
	}
}
