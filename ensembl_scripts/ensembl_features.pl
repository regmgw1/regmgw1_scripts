#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
This script obtains data for selected feature type (repeat, misc, exon, intron, transcript, gene, cpg island) from ensembl.
=head2 Usage

Usage: ./ensembl_features.pl feature_type versionID species path2output chrom

=cut

#################################################################
# ensembl_features.pl
#################################################################

use strict;

use Bio::EnsEMBL::Registry;

unless (@ARGV ==5 ) {
        die "\n\nUsage:\n ./ensembl_features.pl feature_type versionID species path2output chrom\nPlease try again.\n\n\n";}

my $feature = shift;
my $version_id = shift;
my $species = shift;
my $path2output = shift;
my $chrom = shift;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
);
die ("Can't initialise registry") if (!$registry);
$registry->set_disconnect_when_inactive();

print STDERR "Chrom = $chrom\n";
open (OUT, ">$path2output/chr$chrom"."_$feature"."s.gff" ) or die "Can't open $path2output/chr$chrom"."_$feature"."s.gff for writing";
	
my $slice_adaptor = $registry->get_adaptor( $species, 'Core', 'Slice' );

# Obtain a slice covering the entire chromosome $chrom
my $slice = $slice_adaptor->fetch_by_region( 'chromosome', $chrom );

if ($feature eq "repeat")
{
	my @repeats = @{ $slice->get_all_RepeatFeatures() };
	foreach my $repeat (@repeats)
	{
		my $strand = $repeat->strand();
		if ($strand == 1)
		{
			$strand = "+";
		}
		else
		{
			$strand = "-";
		}
		printf OUT ( "%s\tRepeat_%s\tchr%s:%d-%d\t%d\t%d\t%d\t%s\t.\t$version_id; ensembl_features.pl\n",$chrom,$repeat->repeat_consensus->repeat_class,$chrom, $repeat->start(), $repeat->end(), $repeat->start(), $repeat->end(), $repeat->score(), $strand );
	}
}
elsif ($feature eq "misc")
{
	my @misc = @{ $slice->get_all_MiscFeatures() };

	foreach my $misc (@misc)
	{
		my $strand = $misc->strand();
		if ($strand == 1)
		{
			$strand = "+";
		}
		else
		{
			$strand = "-";
		}
		printf OUT ( "%s\tMiscFeature_%s\tchr%s:%d-%d\t%d\t%d\t.\t%s\t.\t$version_id; ensembl_features.pl\n",$chrom, $misc->display_id(), $chrom, $misc->start(), $misc->end(), $misc->start(), $misc->end(), $strand );
		
	}
}
elsif ($feature eq "cpg_island")
{
	my @simpletons = @{ $slice->get_all_SimpleFeatures('cpg') };
	foreach my $simple (@simpletons)
	{
		my $strand = $simple->strand();
		if ($strand == 1)
		{
			$strand = "+";
		}
		else
		{
			$strand = "-";
		}
		printf OUT ( "%s\tCpG_Island\tchr%s:%d-%d\t%d\t%d\t%d\t%s\t.\t$version_id; ensembl_features.pl\n",$chrom, $chrom, $simple->start(), $simple->end(), $simple->start(), $simple->end(), $simple->score(), $strand );
		
	}
}
elsif ($feature eq "transcript")
{
	my @trans = @{ $slice->get_all_Transcripts() };
	foreach my $trans (@trans)
	{
		my $strand = $trans->strand();
		my $type = $trans->biotype();
		if ($strand == 1)
		{
			$strand = "+";
		}
		else
		{
			$strand = "-";
		}
		printf OUT ( "%s\tTranscript_%s_%s\tchr%s:%d-%d\t%d\t%d\t.\t%s\t.\t$version_id; ensembl_features.pl\n",$chrom, $type, $trans->display_id(), $chrom, $trans->start(), $trans->end(), $trans->start(), $trans->end(), $strand );
			
		
        }
}
elsif ($feature eq "exon")
{
	my @trans = @{ $slice->get_all_Transcripts() };
	foreach my $tran (@trans)
	{
		my $type = $tran->biotype();
		foreach my $texon (@{$tran->get_all_Exons()})
		{
			my $strand = $texon->strand();
			if ($strand == 1)
			{
				$strand = "+";
			}
			else
			{
				$strand = "-";
			}
			printf OUT ( "%s\tExon_%s_%s\tchr%s:%d-%d\t%d\t%d\t.\t%s\t.\t$version_id; ensembl_features.pl\n",$chrom, $type, $texon->display_id(), $chrom, $texon->start(), $texon->end(), $texon->start(), $texon->end(), $strand );
			
		}
        }
}
elsif ($feature eq "intron")
{
	my @trans = @{ $slice->get_all_Transcripts() };
	foreach my $tran (@trans)
	{
		my $type = $tran->biotype();
		foreach my $tint (@{$tran->get_all_Introns()})
		{
			my $strand = $tint->strand();
			if ($strand == 1)
			{
				$strand = "+";
			}
			else
			{
				$strand = "-";
			}
			printf OUT ( "%s\tIntron_%s_%s\tchr%s:%d-%d\t%d\t%d\t.\t%s\t.\t$version_id; ensembl_features.pl\n",$chrom, $type, $tint->display_id(), $chrom, $tint->start(), $tint->end(), $tint->start(), $tint->end(), $strand );
	      	}
        }
}
elsif ($feature eq "gene")
{
	my @gene = @{ $slice->get_all_Genes() };

	foreach my $gene (@gene)
	{
		my $strand = $gene->strand();
		my $type = $gene->biotype();
		if ($strand == 1)
		{
			$strand = "+";
		}
		else
		{
			$strand = "-";
		}
		#printf OUT ("%s\t$type\t%s\n",$gene->stable_id(),$gene->source());
		printf OUT ( "%s\t%s_%s\tchr%s:%d-%d\t%d\t%d\t.\t%s\t.\t$version_id; ensembl_features.pl\n",$chrom, $type, $gene->stable_id(), $chrom, $gene->start(), $gene->end(), $gene->start(), $gene->end(), $strand );
		
	}
}
else
{
	die "Program terminated.\nPlease select a single valid feature type (repeat, misc, cpg, exon or intron\n";
}
close OUT;

