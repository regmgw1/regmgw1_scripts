#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
obtains entrez id from input files, converts to gene_symbol, concatenates the hyper and hypo,
# ranking according to diff in meth scores. Hyper = +, hypo = -
=head2 Usage

Usage: ./convert2rnk.pl path2hyperdmrs path2hypodmrs path2output

=cut

#################################################################
# convert2rnk.pl - obtains entrez id from input files, converts to gene_symbol, concatenates the hyper and hypo,
# ranking according to diff in meth scores. Hyper = +, hypo = -
#################################################################

use strict;
use DBI;

unless (@ARGV ==3) {
        die "\n\nUsage:\n ./convert2rnk.pl path2hyperdmrs path2hypodmrs path2output\nPlease try again.\n\n\n";}

my $path2hyperdmrs = shift;
my $path2hypodmrs = shift;
my $path2output = shift;

my $path2conversion = "/path/Homo_sapiens.gene_info";
my (%id_hash,%dmr_hash);

open (OUT, ">$path2output") or die "Can't open $path2output for writing";

open (IN, "$path2conversion" ) or die "Can't open $path2conversion for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	$id_hash{$elems[1]} = $elems[2];
}
close IN;
open (IN, "$path2hyperdmrs" ) or die "Can't open $path2hyperdmrs for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	my $entrez = $elems[3];
	if (exists $id_hash{$entrez})
	{
		if (exists $dmr_hash{$id_hash{$entrez}})
		{
			next;
			print "Exist $entrez hyper\n";
		}
		else
		{
			$dmr_hash{$id_hash{$entrez}}=$elems[8];
		}
	}
	else
	{
		print "Missing symbol $entrez\n";
	}		
}
close IN;
open (IN, "$path2hypodmrs" ) or die "Can't open $path2hypodmrs for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/,$line;
	my $entrez = $elems[3];
	if (exists $id_hash{$entrez})
	{
		if (exists $dmr_hash{$id_hash{$entrez}})
		{
			print "Exist $entrez hypo\n";
			delete $dmr_hash{$id_hash{$entrez}};
		}
		else 
		{
			$dmr_hash{$id_hash{$entrez}}=$elems[8]*-1;
		}
	}
	else
	{
		print "Missing symbol $entrez\n";
	}	
}
close IN;


foreach my $key (sort hashValueDescendingNum (keys(%dmr_hash)))
{
	print OUT "$key\t$dmr_hash{$key}\n";
}

close OUT;

sub hashValueDescendingNum {
   $dmr_hash{$b} <=> $dmr_hash{$a};
}
