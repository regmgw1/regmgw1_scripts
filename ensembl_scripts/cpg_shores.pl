#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
This script generates cpg_shore annotation files from cpg_island gff files
=head2 Usage

Usage: ./cpg_shores.pl species path2islands path2output threshold (in bases) versionID

=cut

#################################################################
# cpg_shores.pl
#################################################################

use strict;

unless (@ARGV ==5) {
        die "\n\nUsage:\n ./cpg_shores.pl species path2islands path2output threshold (in bases) versionID\nPlease try again.\n\n\n";}

my $species = shift;
my $path2islands = shift;
my $path2output = shift;
my $threshold = shift;
my $version_id = shift;

print "path2islands = $path2islands\npath2output = $path2output\n";

my (%end_chrom_hash, $chrom_number, @chroms);

$species = lc($species);
if ($species eq "mouse37")
{
	%end_chrom_hash = (
        1 => '197195432',
        2 => '181748087',
        3 => '159599783',
        4 => '155630120',
        5 => '152537259',
        6 => '149517037',
        7 => '152524553',
        8 => '131738871',
        9 => '124076172',
        10 => '129993255',
        11 => '121843856',
        12 => '121257530',
        13 => '120284312',
        14 => '125194864',
        15 => '103494974',
        16 => '98319150',
        17 => '95272651',
        18 => '90772031',
        19 => '61342430',
        X => '166650296',
        Y => '15902555',      
	);
	$chrom_number = 19;
	@chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,'X','Y');

}
elsif ($species eq "human36")
{
	%end_chrom_hash = (
        1 => '247249719',
        2 => '242951149',
        3 => '199501827',
        4 => '191273063',
        5 => '180857866',
        6 => '170899992',
        7 => '158821424',
        8 => '146274826',
        9 => '140273252',
        10 => '135374737',
        11 => '134452384',
        12 => '132349534',
        13 => '114142980',
        14 => '106368585',
        15 => '100338915',
        16 => '88827254',
        17 => '78774742',
        18 => '76117153',
        19 => '63811651',
        20 => '62435964',
        21 => '46944323',
        22 => '49691432',
        X => '154913754',
        Y => '57772954',        
	);
	$chrom_number = 22;
	@chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,'X','Y');

}
elsif ($species eq "human37")
{
	%end_chrom_hash = (
        1 => '249250621',
        2 => '243199373',
        3 => '198022430',
        4 => '191154276',
        5 => '180915260',
        6 => '171115067',
        7 => '159138663',
        8 => '146364022',
        9 => '141213431',
        10 => '135534747',
        11 => '135006516',
        12 => '133851895',
        13 => '115169878',
        14 => '107349540',
        15 => '102531392',
        16 => '90354753',
        17 => '81195210',
        18 => '78077248',
        19 => '59128983',
        20 => '63025520',
        21 => '48129895',
        22 => '51304566',
        X => '155270560',
        Y => '59373566',        
	);
	$chrom_number = 22;
	@chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,'X','Y');

}
elsif ($species eq "dog2")
{
	%end_chrom_hash = (
	X =>'126883977',
	1=>'125616256',
	3=>'94715083',
	5=>'91976430',
	4=>'91483860',
	2=>'88410189',
	7=>'83999179',
	6=>'80642250',
	11=>'77416458',
	8=>'77315194',
	12=>'75515492',
	10=>'72488556',
	17=>'67347617',
	15=>'67211953',
	13=>'66182471',
	9=>'64418924',
	22=>'64401119',
	14=>'63938239',
	16=>'62570175',
	20=>'61280721',
	18=>'58872314',
	19=>'56771304',
	23=>'55389570',
	25=>'54563659',
	21=>'54024781',
	24=>'50763139',
	27=>'48908698',
	34=>'45128234',
	29=>'44831629',
	28=>'44191819',
	30=>'43206070',
	31=>'42263495',
	26=>'42029645',
	32=>'41731424',
	33=>'34424479',
	37=>'33915115',
	36=>'33840356',
	35=>'29542582',
	38=>'26897727',
	);
	$chrom_number = 38;
	@chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,'X','Y');
}
elsif ($species eq "chimp2")
{
	%end_chrom_hash = (
        1 => '229974691',
        '2a' => '114460064',
        '2b' => '248603653',
        3 => '203962478',
        4 => '194897272',
        5 => '183994906',
        6 => '173908612',
        7 => '160261443',
        8 => '145085868',
        9 => '138509991',
        10 => '135001995',
        11 => '134204764',
        12 => '135371336',
        13 => '115868456',
        14 => '107349158',
        15 => '100063422',
        16 => '90682376',
        17 => '83384210',
        18 => '77261746',
        19 => '64473437',
        20 => '62293572',
        21 => '46489110',
        22 => '50165558',
        X => '155361357',
        Y => '23952694',        
	);
	$chrom_number = 23;
	@chroms = (1,'2a','2b',3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,'X','Y');

}
elsif ($species eq "macaque1")
{
	%end_chrom_hash = (
        1 => '228252215',
        2 => '189746636',
        3 => '196418989',
        4 => '167655696',
        5 => '182086969',
        6 => '178205221',
        7 => '169801366',
        8 => '147794981',
        9 => '133323859',
        10 => '94855758',
        11 => '134511895',
        12 => '106505843',
        13 => '138028943',
        14 => '133002572',
        15 => '110119387',
        16 => '78773432',
        17 => '94452569',
        18 => '73567989',
        19 => '64391591',
        20 => '88221753',
        X => '153947521',
	);
	$chrom_number = 20;
	@chroms = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,'X');

}
elsif ($species eq "gorilla3")
{
	%end_chrom_hash = (
        1 => '229507203',
        '2a' => '111351968',
        '2b' => '131632457',
        3 => '199944510',
        4 => '201139530',
        5 => '165930986',
        6 => '171703152',
        7 => '158137892',
        8 => '145327772',
        9 => '121947112',
        10 => '147764049',
        11 => '133470886',
        12 => '133360231',
        13 => '97499607',
        14 => '88974843',
        15 => '82026568',
        16 => '80971650',
        17 => '94257108',
        18 => '78787515',
        19 => '56181278',
        20 => '62603092',
        21 => '35451371',
        22 => '35671106',
        X => '154045127',
	);
	$chrom_number = 23;
	@chroms = (1,'2a','2b',3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,'X');

}
foreach my $chrom (@chroms)
{
	print "Chrom = $chrom\n";
	my %hash = ();
	open (OUT, ">$path2output/chr$chrom"."_cpg_shores_$threshold".".gff" ) or die "Can't open $path2output/chr$chrom"."_cpg_shores_$threshold".".gff for writing";
	open (IN, "$path2islands/chr$chrom"."_cpg_islands".".gff" ) or die "Can't open $path2output/chr$chrom"."_cpg_islands".".gff for reading";
	#open (IN, "$path2islands/chr$chrom"."_hsCpG-hsGpC_t5_GRCh37_58_cpg_island".".txt" ) or die "Can't open $path2islands/chr$chrom"."_hsCpG-hsGpC_t5_GRCh37_58_cpg_island".".gff for reading";
	while (my $line = <IN>)
	{
		my @elems=split/\t/, $line;
		my $ds_shore_start = $elems[3] - $threshold;
		my $ds_shore_end = $elems[3] - 1;
		if ($ds_shore_start < 0)
		{
			$ds_shore_start = 0;
		}
		my $us_shore_start = $elems[4] + 1;
		my $us_shore_end = $elems[4] + $threshold;
		if ($us_shore_end > $end_chrom_hash{$chrom})
		{
			$us_shore_end = $end_chrom_hash{$chrom};
		}
		print OUT "$elems[0]\tCpG_shore_down_$threshold\tchr$elems[0]".":$ds_shore_start"."-$ds_shore_end\t$ds_shore_start\t$ds_shore_end\t.\t.\t.\t$version_id; cpg_shores.pl\n";
		print OUT "$elems[0]\tCpG_shore_up_$threshold\tchr$elems[0]".":$us_shore_start"."-$us_shore_end\t$us_shore_start\t$us_shore_end\t.\t.\t.\t$version_id; cpg_shores.pl\n";

		
	}
	close IN;
	close OUT;
}
