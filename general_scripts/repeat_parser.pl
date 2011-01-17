#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
parses repeat gff file to create seperate file for each repeat type
=head2 Usage

Usage: ./repeat_parser.pl path2repeatdata path2output

=cut

#################################################################
# repeat_parser.pl 
#################################################################
use strict;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./repeat_parser.pl path2repeatdata path2output\nPlease try again.\n\n\n";}

my $path2files = shift;
my $path2output = shift;

for (my $i=1; $i<=24; $i++)
{
    my $infile  = "";
    my $alufile = "";
    my $mirfile = "";
    my $lfile = "";
    my $l2file = "";
    my $l4file = "";
    my $l3file = "";
    my $dustfile = "";
    my $trffile = "";
    my $miscfile = "";
    my $chr     = "";
    my $start_count = 0;

    if ($i <= 22)
    {
	#$infile  = "$path2files/chr".$i."_repeat.gff";
	$infile  = "$path2files/chr".$i."_misc.gff";
	$alufile = "$path2output/chr".$i."_alu.gff";
	$mirfile = "$path2output/chr".$i."_mir.gff";
	$lfile = "$path2output/chr".$i."_l1.gff";
	$l2file = "$path2output/chr".$i."_l2.gff";
	$l3file = "$path2output/chr".$i."_l3.gff";
	$l4file = "$path2output/chr".$i."_l4.gff";
	$dustfile = "$path2output/chr".$i."_dust.gff";
	$trffile = "$path2output/chr".$i."_trf.gff";
	$miscfile = "$path2output/chr".$i."_misc.gff";
	$chr = $i;
    }
    elsif ($i == 23)
    {
	#$infile  = "$path2files/chrX_repeat.gff";
	$infile  = "$path2files/chrX_misc.gff";
	$alufile = "$path2output/chrX_alu.gff";
	$mirfile = "$path2output/chrX_mir.gff";
	$lfile = "$path2output/chrX_l1.gff";
	$l2file = "$path2output/chrX_l2.gff";
	$l3file = "$path2output/chrX_l3.gff";
	$l4file = "$path2output/chrX_l4.gff";
	$dustfile = "$path2output/chrX_dust.gff";
	$trffile = "$path2output/chrX_trf.gff";
	$miscfile = "$path2output/chrX_misc.gff";
	$chr = "X"
    }
    elsif ($i == 24)
    {
	#$infile  = "$path2files/chrY_repeat.gff";
	$infile  = "$path2files/chrY_misc.gff";
	$alufile = "$path2output/chrY_alu.gff";
	$mirfile = "$path2output/chrY_mir.gff";
	$lfile = "$path2output/chrY_l1.gff";
	$l2file = "$path2output/chrY_l2.gff";
	$l3file = "$path2output/chrY_l3.gff";
	$l4file = "$path2output/chrY_l4.gff";
	$dustfile = "$path2output/chrY_dust.gff";
	$trffile = "$path2output/chrY_trf.gff";
	$miscfile = "$path2output/chrY_misc.gff";
	$chr = "Y"
    }
                                       
	open (IN, "$infile" ) or die "Can't open $infile for reading";
	open (ALU, ">$alufile") or die "Can't open $alufile for writing";
	open (MIR, ">$mirfile") or die "Can't open $mirfile for writing";
	open (L1, ">$lfile") or die "Can't open $lfile for writing";
	open (L2, ">$l2file") or die "Can't open $lfile for writing";
	open (L4, ">$l4file") or die "Can't open $lfile for writing";
	open (L3, ">$l3file") or die "Can't open $lfile for writing";
	open (DUST, ">$dustfile") or die "Can't open $dustfile for writing";
	open (TRF, ">$trffile") or die "Can't open $trffile for writing";
	open (MISC, ">$miscfile") or die "Can't open $miscfile for writing";
	print "chr = $chr\n";
	while (my $line = <IN>)
	{
		#chomp $line;
		my @elems = split/\t/, $line;
		my $id = $elems[1];
		$id =~m/Repeat_(.*)/;
		my $type = $1;
		if ($type eq "dust")
		{
			print DUST "$line";
		}
		elsif ($type eq "trf")
		{
			print TRF "$line";
		}
		elsif ($type =~m/^L1/)
		{
			print L1 "$line";
		}
		elsif ($type =~m/^MIR/)
		{
			print MIR "$line";
		}
		elsif ($type =~m/^Alu/)
		{
			print ALU "$line";
		}
		elsif ($type =~m/^L2/)
		{
			print L2 "$line";
		}
		elsif ($type =~m/^L3/)
		{
			print L3 "$line";
		}
		elsif ($type =~m/^L4/)
		{
			print L4 "$line";
		}
		else
		{
			print MISC "$line";
		}
	}
	close ALU;
	close MIR;
	close L1;
	close L2;
	close L3;
	close L4;
	close DUST;
	close TRF;
	close MISC;
}
