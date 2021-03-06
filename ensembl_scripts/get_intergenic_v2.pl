#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
This script creates a gff file containing intergenic regions, using genes gff file as input
=head2 Usage

Usage: ./get_intergenic_v2.pl path2genes path2output

=cut


#################################################################
# get_intergenic_v2.pl
#################################################################


use strict;
$|=1;

unless (@ARGV ==4 ) {
        die "\n\nUsage:\n ./create_signal_map_from_maq_gff.pl species versionID path2gffs path2output\nPlease try again.\n\n\n";}

my $species = shift;
my $version_id = shift;
my $path2files = shift;
my $path2output = shift;


my (%end_chrom_hash, $chrom_number);

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
}
elsif ($species eq "chimp2")
{
	%end_chrom_hash = (
        1 => '229974691',
        #2A => '114460064',
        #2B => '248603653'
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
}
for (my $i=1; $i<=$chrom_number+2; $i++) {

    my $infile  = "";
    my $outfile = "";
    my $chr     = "";
    my $start_count = 0;
    my $access_hash = $i;

    if ($i <= $chrom_number) {
	$infile  = "$path2files/chr".$i."_genes.gff";
	$outfile = "$path2output/chr".$i."_intergenics.gff";
	$chr = $i;
    }
    elsif ($i == $chrom_number+1) {
	$infile  = "$path2files/chrX_genes.gff";
	$outfile = "$path2output/chrX_intergenics.gff";
	$chr = "X";
	$access_hash = "X";
    }
    elsif ($i == $chrom_number+2) {
	$infile  = "$path2files/chrY_genes.gff";
	$outfile = "$path2output/chrY_intergenics.gff";
	$chr = "Y";
	$access_hash = "Y";
    }
    
    open (IN, "$infile") or die "Can't open $infile for reading";
    open (OUT, ">$outfile") or die "Can't open $outfile for writing";
    my %data = ();
    
    while (<IN>) {
	chomp;
	
	my ($chrt, $t2, $t3, $start, $stop, @rest) = split /\t/, $_;
	if ($start_count == 0)
	{
		$data{0} = 0;
	}
	$data{$start} += 1;
	$data{$stop} += -1;
	$start_count++;
    }
    
    close IN;
    
	
    my @sorted_pos = sort {$a <=> $b} (keys %data);
    my $height = 0;
    my $pos_length = @sorted_pos;
    for (my $j=0; $j<$pos_length; $j++)
    {
    	$height += $data{$sorted_pos[$j]};
    	my $end_point;
    	if ($j + 1 == $pos_length)
    	{
    		$end_point = $end_chrom_hash{$access_hash};
    	}
    	else
    	{
    		$end_point = $sorted_pos[$j+1] - 1;
    	}
    	if ($height == 0)
    	{
    		my $inter_s = $sorted_pos[$j] + 1;
		print OUT "$chr\tIntergenic_region\tchr$chr".":$inter_s"."-$end_point\t$inter_s\t$end_point\t.\t-\t.\t$version_id; get_intergenic_v2.pl\n";
		
	}
	}
    			
    
    close OUT;
    print "chr$access_hash\n";
    
}
