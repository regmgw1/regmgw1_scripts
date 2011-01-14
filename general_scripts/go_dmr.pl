#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
takes input file of regions, obtains go id from biomart, queries the simplego db for annotation. 

=head2 Usage

Usage: ./go_obo_to_simple_db.pl path2obo user password

=cut

#################################################################
# go_dmr.pl
#################################################################

use strict;
use lib '/path/to/biomart-perl/lib';
use BioMart::Initializer;
use BioMart::Query;
use BioMart::QueryRunner;
use Getopt::Std;
use IO::String;

my $usage="
Usage:

./go_dmr.pl [-l] [-i <input_file>] [-o <output_directory>] [-u <username>] [-p <password>]

Options:

-l convert assembly using liftOver
-g GO type (1 = biological process, 2 = cellular component, 3 = molecular function)
-i path to input file
-o path to output directory
-f final output file name
-u mysql username
-p mysql password
";

my ($path2output, $path2input, $liftover, $username, $pswd, $filename, $go_type);

###############
# get options #
###############
my %opts=();
getopts('hli:o:u:p:g:f:',\%opts);
# print help message
if (defined $opts{h})
{
	print $usage;
	exit;
}
if (defined $opts{o})
{
	$path2output = $opts{o};
}
else
{
	print STDERR "Please select your path2output directory\n";
	print STDERR $usage;
	exit;
}
if (defined $opts{f})
{
	$filename = $opts{f};
}
else
{
	print STDERR "No filename selected, final output will be printed to bio_data_raw.txt\n";
	$filename = "bio_data_raw.txt";
}
if (defined $opts{i})
{
	$path2input = $opts{i};
}
else
{
	print STDERR "Please select your path2input\n";
	print STDERR $usage;
	exit;
}
if (defined $opts{u})
{
	$username = $opts{u};
}
else
{
	print STDERR "Please enter your mysql username\n";
	print STDERR $usage;
	exit;
}
if (defined $opts{p})
{
	$pswd = $opts{p};
}
else
{
	print STDERR "Please enter your mysql password\n";
	print STDERR $usage;
	exit;
}
if (defined $opts{g})
{
	$go_type = $opts{g};
}
else
{
	print STDERR "Please enter a GO type\n";
	print STDERR $usage;
	exit;
}
if (defined $opts{l})
{
	$liftover = 1;
}
else
{
	$liftover = 0;
}

my @old;
######
# Connect to simple_go db
######
#print "username = $username\npassword = $pswd\n";
my $dbh = DBI->connect("DBI:mysql:database=simple_go;host=localhost", "$username", "$pswd",
                                 { RaiseError => 1,
                                   AutoCommit => 0 }) || die "Unable to connect to localhost because $DBI::errstr";

#######
# run liftover if required
#######
if ($liftover == 1)
{
	print STDERR "\nCurrently configured to convert human ncbi35 to ncbi36. If require something different need to change name of cross file in code\n\n";
	system "/path/to/gff_to_bed_for_liftover.pl $path2input $path2output/bedfile.bed";
	system "/path/to/liftOver/liftOver.linux.x86_64 $path2output/bedfile.bed /path/to/liftOver/cross_files/hg17ToHg18.over.chain $path2output/converted.bed $path2output/liftOver_output";
	$path2input = "$path2output/converted.bed";
	open (OLD, "$path2output/bedfile.bed" ) or die "Can't open $path2output/bedfile.bed for reading";
	while (my $old = <OLD>)
	{
		push @old, $old;
	}
}

my $out_var;
open (OUT, ">$path2output/$filename") or die "Can't open $path2output/$filename for writing";

my $initializer = BioMart::Initializer->new('registryFile'=>'/path/to/biomart-perl/conf/apiExampleRegistry.xml');
my $registry = $initializer->getRegistry;

close STDOUT;
open STDOUT, '>', \$out_var or die "Can't open STDOUT: $!";


open (IN, "$path2input" ) or die "Can't open $path2input for reading";
while (my $line = <IN>)
{
	chomp $line;
	my @elems = split/\t/, $line;
	my ($d_chr,$d_start,$d_stop, $old_info);
	if ($liftover == 0)
	{
		$d_chr = $elems[1];
		$d_start = $elems[2];
		$d_stop = $elems[3];
		print "\nDMR\tchr$d_chr\t$d_start\t$d_stop\n";
		
	}
	else
	{
		$d_chr = $elems[0];
		$d_start = $elems[1];
		$d_stop = $elems[2];
		$d_chr =~s/chr//;
		my $count = $elems[3] - 1;
		$old_info = $old[$count];
		chomp $old_info;
		print "\nDMR\tchr$d_chr\t$d_start\t$d_stop ($old_info)\n";
	}
	my $query = BioMart::Query->new('registry'=>$registry,'virtualSchemaName'=>'default');
	$query->setDataset("hsapiens_gene_ensembl");
	$query->addFilter("chromosome_name", ["$d_chr"]);
	$query->addFilter("start", ["$d_start"]);
	$query->addFilter("end", ["$d_stop"]);
	$query->addAttribute("start");
	$query->addAttribute("end");
	$query->addAttribute("ensembl_gene_id");
	$query->addAttribute("external_gene_id");
	if ($go_type == 1)
	{
		$query->addAttribute("go_biological_process_id");
	}
	elsif ($go_type == 2)
	{
		$query->addAttribute("go_cellular_component_id");
	}
	elsif ($go_type == 3)
	{
		$query->addAttribute("go_molecular_function_id");
	}
	else
	{
		print STDERR "GO type $go_type not an option, running biological process by default.\n";
		$query->addAttribute("go_biological_process_id");
	}
		
	my $query_runner = BioMart::QueryRunner->new();
	# to obtain unique rows only
	$query_runner->uniqueRowsOnly(1);
	$query_runner->execute($query);
	$query_runner->printResults();
}
close IN;

my @mart_lines = split/\n/,$out_var;
foreach my $line (@mart_lines)
{
	if ($line =~m/GO:(\d{7})/)
	{
		my $go_id = $1;
		
		my $sth = $dbh->prepare('SELECT name FROM simple_annotation WHERE go_id = ?')
                or die "Couldn't prepare statement: " . $dbh->errstr;
	
		$sth->execute($go_id)             # Execute the query
          	or die "Couldn't execute statement: " . $sth->errstr;
          	
        	if (my @data = $sth->fetchrow_array())
        	{
        		print OUT "$line\t$data[0]\n";
       		}
       		else
       		{
       			print OUT "$line\tno annno $go_id\n";
       		}
		
	}
	else
	{
		print OUT "$line\n";
	}
}
close OUT;	

$dbh->disconnect;
