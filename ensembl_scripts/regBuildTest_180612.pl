#!/usr/bin/perl -w

use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
    #The Registry automatically picks port 5306 for ensembl db
    #-verbose => 1, #specificy verbose to see exactly what it loaded
);

my $regfeat_adaptor = $registry->get_adaptor('Human', 'funcgen', 'regulatoryfeature');
my $slice_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Slice' );
my $slice = $slice_adaptor->fetch_by_region('chromosome',1,54960000,54980000);
my $fset_adaptor = $registry->get_adaptor('Human', 'funcgen', 'featureset');
my $ftype_adaptor = $registry->get_adaptor('Human', 'funcgen', 'featuretype');
my $seg_adaptor = $registry->get_adaptor('Human', 'funcgen', 'segmentationfeature');
my @reg_feats = @{$seg_adaptor->fetch_all_by_Slice($slice)};
foreach my $multi_rf (@reg_feats)
	{
		my $label = $multi_rf->display_label();
		my $info_ref = get_feature($multi_rf);
		print "$label\n";
		my @info = @$info_ref;
		print "chr1\t$info[0]_$info[1]_$info[2]_$info[3]\n";
		}
=pod
		my @annotated_features = @{$multi_rf->regulatory_attributes('annotated')};
		foreach my $annotated_feature (@annotated_features)
		{
			print "$type\t".$annotated_feature->feature_type->name."\n";
			my $anno_feat_name = $annotated_feature->feature_type->name;
			if ($type =~m/$anno_feat_name/)
			{
				$details .= "\t".$annotated_feature->feature_type->name."\t".$annotated_feature->feature_set->name."\t".$annotated_feature->score."\t".$annotated_feature->summit;
			}
		}
=cut
		
=pod
my @tfs = @{$ftype_adaptor->fetch_all_by_class('Transcription Factor')};
foreach my $ft (@tfs){
	print "NAME: ".$ft->name."\n";
	my @fsets = @{$fset_adaptor->fetch_all_by_FeatureType($ft)};
	foreach my $fset (@fsets){ print $fset->name."\n"; }
}
=cut
my @ext_fsets = @{$fset_adaptor->fetch_all_by_type('external')};

foreach my $ext_fset (@ext_fsets){
  print "External FeatureSet:\t".$ext_fset->name."\n";
}
=pod
my @reg_fsets = @{$fset_adaptor->fetch_all_by_type('annotated')};
foreach my $reg_fset (@reg_fsets) {
	if (my @features = @{$reg_fset->get_Features_by_Slice($slice)})
	{
	print $reg_fset->name."\n";
	#Regulatory Feature Sets
	print $reg_fset->feature_class."\n";
	#The Regulatory Build
	print $reg_fset->analysis->logic_name."\n";
	#Regulatory Feature Type
	print $reg_fset->feature_type->name."\n";
	#Regulatory Feature Sets have Cell Type defined
	print $reg_fset->cell_type->name."\n";
	#Finally, you can also get features from this set
	#my @features = @{$reg_fset->get_Features_by_Slice($slice)};
	foreach my $feat (@features) { print_feature($feat); }
	}
	print "END\n\n";
}


my @reg_feats = @{$regfeat_adaptor->fetch_all_by_Slice($slice)};
foreach my $rf (@reg_feats){
my @annotated_features = @{$rf->regulatory_attributes('annotated')};
#An example to print annotated feature properties
foreach my $annotated_feature (@annotated_features) {
	print_feature($annotated_feature);
	#print $annotated_feature->feature_type->name."\n";
	#print $annotated_feature->feature_set->name."\n";
	#Analysis-depends property
	#print $annotated_feature->score."\n";
	#Summit is usually present, but may not exist
	if($annotated_feature->analysis->logic_name =~ /SWEmbl/){
	#	print $annotated_feature->summit."\n";
	}
	my @motif_features = @{$annotated_feature->get_associated_MotifFeatures()};
	#An example to print motif feature properties
	foreach my $motif_feature (@motif_features) {
	print_feature($motif_feature);
	print $motif_feature->binding_matrix->name."\n";
	print $motif_feature->seq."\n";
	print $motif_feature->score."\n";
	my $afs = $motif_feature->associated_annotated_features();	
	foreach my $feat (@$afs){
		#Each feature is an annotated feature
		print_feature($feat); 
	}
}
}
}


foreach my $rf (@reg_feats){ 	
	print $rf->stable_id.": ";
	print_feature($rf);
	print "\tCell: ".$rf->cell_type->name."\n"; 	
	print "\tFeature Type: ".$rf->feature_type->name."\n"; 
	foreach my $feature (@{$rf->regulatory_attributes()}){
	print_feature($feature) 
	}
}

my $rfs = $regfeat_adaptor->fetch_all_by_stable_ID('ENSR00000165384'); 

foreach my $cell_rf (@{$rfs}){
	#The stable id will always be 'ENSR00000165384' 	
	print $cell_rf->stable_id.": \n"; 	
	#But now it will be for a specific cell type
	print "\tCell: ".$cell_rf->cell_type->name."\n";
	#It will also contain cell-specific annotation
	print "\tType: ".$cell_rf->feature_type->name."\n";
	#And cell-specific extra boundaries
	print 	"\t".$cell_rf->seq_region_name.":".	
		$cell_rf->bound_start."..".
		$cell_rf->start."-". $cell_rf->end."..".
		$cell_rf->bound_end."\n";	
	#Unlike the generic MultiCell Regulatory Features, Histone
	# modifications and Polymerase are also used as attributes	
	print "\tEvidence Features: \n"; 	
	foreach my $attr_feat (@{$cell_rf->regulatory_attributes()}){
		print_feature($attr_feat);
	}	
}
=cut



#Prints absolute coordinates and not relative to the slice
sub print_feature {
	my $feature = shift;
	print 	$feature->display_label.
		"\t(".$feature->seq_region_name.":".
	  	$feature->seq_region_start."-". 
		$feature->seq_region_end.")\n";
}
sub get_feature {
	my $feature = shift;
	my @info = ($feature->display_label,$feature->seq_region_name,$feature->seq_region_start,$feature->seq_region_end);
	return \@info;
}

