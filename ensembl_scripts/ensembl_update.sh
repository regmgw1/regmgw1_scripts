# $1 = cvs version number (gene build e.g. 60)
# $2 = path2scripts
# $3 = max chrom number (human = 22)
# $4 = species
# $5 = path2output
# $6 = assembly number (e.g 37)

#mkdir cvs_v$1
#cd cvs_v$1
#cvs -d :pserver:cvsuser@cvs.sanger.ac.uk:/cvsroot/ensembl login
#password = CVSUSER
#cvs -d :pserver:cvsuser@cvs.sanger.ac.uk:/cvsroot/ensembl checkout -r branch-ensembl-$1 ensembl
#cvs -d :pserver:cvsuser@cvs.sanger.ac.uk:/cvsroot/ensembl checkout -r branch-ensembl-$1 ensembl-functgenomics
#cvs -d :pserver:cvsuser@cvs.sanger.ac.uk:/cvsroot/ensembl checkout -r branch-ensembl-$1 ensembl-compara
#echo "export PERL5LIB=/path/to/ensembl_api/src/bioperl-live:/path/to/ensembl_api/cvs_v$1/ensembl/modules:/path/to/ensembl_api/cvs_v$1/ensembl-functgenomics/modules:/path/to/ensembl_api/cvs_v$1/ensembl-compara/modules:/path/to/biomart-perl/lib" >release$1.env
#source ./release$1.env
#cd $2
CURRENT=`pwd`
cd $5
mkdir genes
for c in `seq 1 $3` X Y;do echo $c;perl $2/ensembl_features.pl gene Ensembl$1 $4 $5/genes/ ${c};cat $5/genes/chr${c}_genes.gff >>$5/genes/genes.gff;done
mkdir cpg_islands
for c in `seq 1 $3` X Y;do echo $c;perl $2/ensembl_features.pl cpg_island Ensembl$1 $4 $5/cpg_islands/ ${c};cat $5/cpg_islands/chr${c}_cpg_islands.gff >>$5/cpg_islands/cpg_islands.gff;done
mkdir exons
for c in `seq 1 $3` X Y;do echo $c;perl $2/ensembl_features.pl exon Ensembl$1 $4 $5/exons/ ${c};cat $5/exons/chr${c}_exons.gff >>$5/exons/exons.gff;done
mkdir introns
for c in `seq 1 $3` X Y;do echo $c;perl $2/ensembl_features.pl intron Ensembl$1 $4 $5/introns/ ${c};cat $5/introns/chr${c}_introns.gff >>$5/introns/introns.gff;done
mkdir miscs
for c in `seq 1 $3` X Y;do echo $c;perl $2/ensembl_features.pl misc Ensembl$1 $4 $5/miscs/ ${c};cat $5/miscs/chr${c}_miscs.gff >>$5/miscs/miscs.gff;done
mkdir repeats
for c in `seq 1 $3` X Y;do echo $c;perl $2/ensembl_features.pl repeat Ensembl$1 $4 $5/repeats/ ${c};cat $5/repeats/chr${c}_repeats.gff >>$5/repeats/repeats.gff;done
mkdir transcripts
for c in `seq 1 $3` X Y;do echo $c;perl $2/ensembl_features.pl transcript Ensembl$1 $4 $5/transcripts/ ${c};cat $5/transcripts/chr${c}_transcripts.gff >>$5/transcripts/transcripts.gff;done

mkdir cpg_shores_2000
perl $2/cpg_shores.pl $4$6  $5/cpg_islands/ $5/cpg_shores_2000 2000 $1
for c in `seq 1 $3` X Y;do echo $c;cat $5/cpg_shores_2000/chr${c}_cpg_shores_2000.gff >>$5/cpg_shores_2000/cpg_shores_2000.gff;done

mkdir intergenics
perl $2/get_intergenic_v2.pl $4$6 $1 $5/genes $5/intergenics/
for c in `seq 1 $3` X Y;do echo $c;cat $5/intergenics/chr${c}_intergenics.gff >>$5/intergenics/intergenics.gff;done

mkdir promoters
for c in `seq 1 $3` X Y;do echo $c;perl $2/transcript2promoter.pl $5/transcripts/chr${c}_transcripts.gff $5/promoters $1 $c;cat $5/promoters/chr${c}_promoters.gff >> $5/promoters/promoters.gff;done

echo "cpg_islands
cpg_shores_2000
exons
introns
transcripts
genes
intergenics
promoters
miscs" >$5/features.list
echo "LINE
SINE
RNA
DNA
Satellite
LTR
Other" >$5/repeat_familes.txt

