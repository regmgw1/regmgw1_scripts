#!/usr/bin/perl -w

use strict;
use warnings;
use Bio::EnsEMBL::Registry;

unless (@ARGV ==5 ) {
        die "\n\nUsage:\n ./dmr_ensembl_reg.pl path2dmrs path2summaryOut path2FullOut segmentation? species\nPlease try again.\n\n\n";}

my $path2dmrs = shift;
my $path2summ_out = shift;
my $path2full_out = shift;
my $segment = shift;
my $species = shift;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
    #The Registry automatically picks port 5306 for ensembl db
    #-verbose => 1, #specificy verbose to see exactly what it loaded
);

open (OUT, ">$path2summ_out") or die "Can't write to file $path2summ_out";
open (FULL, ">$path2full_out") or die "Can't write to file $path2full_out";
print FULL "DMR_chr\tDMR_start\tDMR_stop\tType\tchr\tstart\tstop\n";
if ($segment == 1)
{
	if ($species ne "Human")
	{
		die "Segmentation data only available for Human! ...Please try again...\n";
	}
	else
	{
		open (SEG, ">$path2summ_out"."_seg") or die "Can't write to file $path2summ_out"."_seg";
	}
}

my $regfeat_adaptor = $registry->get_adaptor($species, 'funcgen', 'regulatoryfeature');
my $slice_adaptor = $registry->get_adaptor( $species, 'Core', 'Slice' );
my (@dmrs,@slices);
open (IN, $path2dmrs) or die "Can't open $path2dmrs for reading\n";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	my $chr = $elems[0];
	$chr =~s/chr//;
	my $slice = $slice_adaptor->fetch_by_region('chromosome',$chr,$elems[1],$elems[2]);
	push @slices, $slice;
	push @dmrs, "$chr\t$elems[1]\t$elems[2]";	
}
close IN;
my $inc = 0;
my $details;
foreach my $slice (@slices)
{
	my @reg_feats = @{$regfeat_adaptor->fetch_all_by_Slice($slice)};
	my $type;
	foreach my $multi_rf (@reg_feats)
	{
		my $rfs = $regfeat_adaptor->fetch_all_by_stable_ID($multi_rf->stable_id);
		foreach my $cell_rf (@{$rfs})
		{
			my $info_ref = get_feature($cell_rf);
			my @info = @$info_ref;
			print OUT "chr$dmrs[$inc]\t$info[0]_$info[1]_$info[2]_$info[3]\n";
			foreach my $attr_feat (@{$cell_rf->regulatory_attributes()})
			{
				my $details_ref = get_feature($attr_feat);
				my @details_ref = @$details_ref;
				$type = $details_ref[0];
				$details = "chr$dmrs[$inc]\t$details_ref[0]\t$details_ref[1]\t$details_ref[2]\t$details_ref[3]";
				print FULL "$details\n";
			}
		}
	}
	
	if ($segment == 1 && $species eq "Human")
	{
		my $seg_adaptor = $registry->get_adaptor('Human', 'funcgen', 'segmentationfeature');
		my @seg_feats = @{$seg_adaptor->fetch_all_by_Slice($slice)};
		foreach my $multi_seg (@seg_feats)
		{
			my $info_ref = get_feature($multi_seg);
			my @info = @$info_ref;
			print SEG "chr$dmrs[$inc]\t$info[0]_$info[1]_$info[2]_$info[3]\n";
		}	
	}
	$inc++;	
}
close OUT;
close FULL;
close SEG;

#Prints absolute coordinates and not relative to the slice
sub get_feature {
	my $feature = shift;
	my @info = ($feature->display_label,$feature->seq_region_name,$feature->seq_region_start,$feature->seq_region_end);
	return \@info;
}

sub print_feature {
	my $feature = shift;
	print 	$feature->display_label.
		"\t(".$feature->seq_region_name.":".
	  	$feature->seq_region_start."-". 
		$feature->seq_region_end.")\n";
}

