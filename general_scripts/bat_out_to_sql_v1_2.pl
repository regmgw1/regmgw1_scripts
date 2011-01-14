#!/usr/bin/perl -w

=head2 Authors

=head3 Created by

Gareth Wilson
gareth.wilson@cancer.ucl.ac.uk

=head2 Description
Convert batman output to the correct format for the sql database and load the data
in to the table batman_output and batman_expt_join 

Produce a proserver adaptor file and modify the proserver ini file. These 
will then be copied to the correct location using the correct user id.

To create the tracks necessary to enable proserver to display data as a DAS track
the script must be run with sudo root priveleges

=head2 Usage

Usage: ./bat_out_to_sql_v1_2.pl path2config

=cut

#################################################################
# bat_out_to_sql.pl 
# Convert batman output to the correct format for the sql database and load the data
# in to the table batman_output and batman_expt_join 
#
# Produce a proserver adaptor file and modify the proserver ini file. These 
# will then be copied to the correct location using the correct user id.
#
# To create the tracks necessary to enable proserver to display data as a DAS track
# the script must be run with sudo root priveleges
#
#################################################################
use strict;
use Config::Simple;
use DBI;
use Math::Round;
use Sudo;

unless (@ARGV ==2) {
        die "\n\nUsage:\n ./bat_out_to_sql.pl path2config\nPlease try again.\n\n\n";}

my $path2config = shift;
my $data = shift;

#import parameters from config file
my $config = new Config::Simple("$path2config") or die "Can't open config file $path2config: $!";
my $io = $config->param(-block=>'IO');
my $db = $config->param(-block=>'DATABASE');
my $dbtype = $db->{dbtype};
my $dbhost = $db->{dbhost};
my $dbname = $db->{dbname};
my $username = $db->{dbuser};
my $pswd = $db->{dbpswd};
my $misc = $config->param(-block=>'MISC');
my $tissue = $misc->{tissue};
my $iq_check = $misc->{obtain_iqr};
my $reads = $misc->{read_density};
my $reads_head = $misc->{read_expt};
my $sa = $config->param(-block=>'ADAPTOR');
my $write_adaptor = $sa->{write_adaptor_template};
my $path2proserver = $sa->{path2proserver};
my $template = $sa->{template};
my $adaptor = $sa->{adaptor};
my $stylesheet = $sa->{stylesheet};
my $source_desc = $sa->{description};
my $ensembl = $config->param(-block=>'ENSEMBL');
my $ens_species = $ensembl->{species};
my $ens_build = $ensembl->{build};
my $calib = $config->param(-block=>'CALIBRATION');
my $scatter = $calib->{scatter_file};
my $trend = $calib->{trend_file};
my $plot_file= $calib->{plot_file};
my $calib_output = $calib->{calib_output};

# database that stores info about data stored in other databases e.g species, build
my $databases_db = "batman_databases";


# Need to insert data relating to the build and species used for the analyses into the database_list table in batman_databases database
my $dbh2 = DBI->connect("DBI:$dbtype:database=$databases_db;host=$dbhost", "$username", "$pswd",
                                 { RaiseError => 1,
                                   AutoCommit => 0 }) || die "Unable to connect to $dbhost because $DBI::errstr";

#run ensembl_info sub to determine if information needs to be entered
ensembl_info($dbh2, $dbname, $ens_species, $ens_build);
$dbh2->disconnect;



print "my data = $data\n";

my $dbh = DBI->connect("DBI:$dbtype:database=$dbname;host=$dbhost", "$username", "$pswd",
                                     { RaiseError => 1,
                                       AutoCommit => 0 }) || die "Unable to connect to $dbhost because $DBI::errstr";



open (OUT, ">/home/regmgw1/batman_scripts/test_roi_sub.txt") or die "Can't write out: $!";

# open file containing summarized batman output
open (IN, "$data" ) or die "Can't open $data for reading";

my $count = 0;
my $output_id;
my @expt_ids;

while (my $line = <IN>)
{
	chomp $line;
	# check to see if header line, if so need to extract expt names
	if ($count == 0)
	{
		print "$line\n";
		my @expts;
		if ($reads == 0)
		{
			$line =~m/#(.*)/;
			my $header = $1; 
			@expts = split/,/, $header;
		}
		elsif ($reads == 1) # from sgr file
		{
			push @expts, $reads_head;
		} 
		# obtain expt ids for the expt names
		my $sth = $dbh->prepare('SELECT id FROM medip_expt WHERE expt_name = ?')
                or die "Couldn't prepare statement: " . $dbh->errstr;
		foreach my $expt (@expts)
		{
			$expt = trim($expt);
			print "expt = $expt\n";
			# now need to connect to database to obtain the expt ids for these expts.
			$sth->execute($expt)             # Execute the query
           		or die "Couldn't execute statement: " . $sth->errstr;
           		
           		while (my @data = $sth->fetchrow_array())
           		{
           			my $expt_id = $data[0];
           			push @expt_ids, $expt_id;
           			# produce batman calibration plot for each experiment
				calibrate_plot($expt,$expt_id,$scatter,$trend,$calib_output,$plot_file);
			}
			
		}
		# in order to enter row in the batman_expt_join table, need to find out what the latest output id is,
		# as this will be the next entry (therefore increment by 1)
		my $sth2 = $dbh->prepare('SELECT max(expt_join) FROM batman_output')
                or die "Couldn't prepare statement: " . $dbh->errstr;
                $sth2->execute;
                while (my @max_data = $sth2->fetchrow_array())
           	{
           		my $max_id = $max_data[0];
           		if ($max_id)
           		{
           			$output_id = $max_id + 1;
           		}
           		else
           		{
           			$output_id = 1;
           		}
           	}
           	# create entry in batman_expt_join table for each experiment
           	foreach my $expt_id (@expt_ids)
           	{
             		my $insert_handle = $dbh->prepare_cached('INSERT INTO batman_expt_join VALUES (batman_join_id,?,?)'); 
			die "Couldn't prepare queries; aborting" unless defined $insert_handle;

			my $success = 1;
			$success &&= $insert_handle->execute($expt_id, $output_id);
		 	my $result = ($success ? $dbh->commit : $dbh->rollback);
			unless ($result)
			{ 
				die "Couldn't finish transaction: " . $dbh->errstr 
			}
           	} 
	}
	# if not header, then must be data. Therefore needs to be formatted and put into batman_output table using database_insert sub
	else
	{
		if ($line =~m/\#/ || $line=~/^track/)
		{
			next;
		}
		else
		{
			my @elems = split/\t/, $line;
			my ($chr,$start,$stop,$coords,$score);
			if ($reads == 0)
			{
				$chr = $elems[0];
				$start = $elems[3];
				$stop = $elems[4];
				$coords = "$chr:$start,$stop";
				
				$score = $elems[5];
				$score = $score * 100;
				$score = round($score);
			}
			elsif ($reads == 1) # from .sgr file
			{
				$chr = $elems[0];
				$start = $elems[1];
				$stop = $elems[2];
				$chr=~s/chr//;
				$coords = "$chr:$start,$stop";
				$score = $elems[3];
				
			}
			else
			{
				die "Need a value of 0 or 1 for the reads parameter\n";
			}
			# determine whether suitable for obtaining iqr. not suitable if e.g. inserting averages from arrays
			my $iq;
			if ($iq_check == 1)
			{
				my $temp_iq = $elems[8];
				$temp_iq =~m/(\d\.\d*|0)/;
				$iq = $1;
				if ($iq > 0)
				{
					$iq = $iq * 100;
					$iq = round($iq);
				}
				else
				{
					$iq = 0.00;
				}
			}
			else
			{
				$iq = 0.00;
			}
			my $roi = "temp";
			database_insert($dbh,$chr,$start,$stop,$coords,$score,$iq,$roi,$tissue,$output_id);
		}
	}
	$count++;
}
close IN;

# write the source adaptor
if ($write_adaptor == 1)
{
	source_adaptor($path2proserver,$template,$adaptor,$dbname,$tissue, $output_id);
}
$dbh->disconnect;

############
#SUBROUTINES
############

sub roi_locator # no longer used
{
	my ($dbh, $chr, $start, $stop) = @_;
	my $roi_count = 0;
	my $roi_name;
	#edit the query to select roi from probe table where start and stop are ok, then select roi_name from roi table,
	# need to check to see if have value returned from first query, if not roi = n/a.
	my $sth = $dbh->prepare('SELECT medip_roi.roi_name FROM medip_probe, medip_roi WHERE medip_roi.id = medip_probe.roi AND chr = ? AND ((? >= min_pos AND ? <= max_pos) OR (? >= min_pos AND ? <= max_pos))') or die "Couldn't prepare statement: " . $dbh->errstr;
	$sth->execute($chr,$start,$start,$stop,$stop)             # Execute the query
           	or die "Couldn't execute statement: " . $sth->errstr;
        while (my @roi_result = $sth->fetchrow_array())
	{
        	$roi_name = $roi_result[0];
           	$roi_count++;
	}
	if ($roi_count == 0)
	{
		$roi_name = "N/A";
	}
	return $roi_name;   
}

sub database_insert
{
	my ($dbh, $chr, $start, $stop, $coords, $score, $iq, $roi, $tissue, $output_id) = @_;
	
	my $insert_handle = $dbh->prepare_cached('INSERT INTO batman_output VALUES (batman_id,?,?,?,?,?,?,?,?,?)'); 
	die "Couldn't prepare queries; aborting" unless defined $insert_handle;

	my $success = 1;
	$success &&= $insert_handle->execute($chr, $start, $stop, $coords, $score, $iq, $roi, $tissue, $output_id);
	my $result = ($success ? $dbh->commit : $dbh->rollback);
	unless ($result)
	{ 
		die "Couldn't finish transaction: " . $dbh->errstr 
	}
	return $success;
}
sub source_adaptor
{
	# subroutine to set up newly inserted data as a DAS track.
	my ($path2proserver, $template, $adaptor, $dbname, $tissue, $output_id) = @_;
	# open ini file to check for current adaptor entries
	my @current;
	open (RINI, "$path2proserver/eg/batman.ini") or die "Can't read: $!";
	while (my $line = <RINI>)
	{
		if ($line =~m/^\[(\w+)\]/)
		{
			push @current, $1;
		}
	}
	close RINI;
	
	my $check;
	# open template, parse through and replace "animals" with e.g name of tissue, dbname
	# create new adaptor file and open the batman.ini file for editing - need root priveleges
	open (OUT, ">$path2proserver/lib/Bio/Das/ProServer/SourceAdaptor/$adaptor".".pm") or die "Can't write out: $!";
	open (INI, ">>$path2proserver/eg/batman.ini") or die "Can't write out: $!";
	open (IN, "$template" ) or die "Can't open $template for reading";
	my $temp_species = $ens_species;
	$temp_species =~s/_/ /;
	while (my $line = <IN>)
	{
		$line =~s/BADGER/$tissue/;
		$line =~s/PUFFIN/$dbname/;
		$line =~s/MULE/$adaptor/;
		$line =~s/GOPHER/$ens_build/;
		$line =~s/PLATYPUS/$temp_species/;
		$line =~s/AYEAYE/$stylesheet/;
		$line =~s/CUCKOO/$source_desc/;
		if ($line =~m/^!!/) # these lines in the template indicate information for the .ini file
		{
			$line =~s/!!//;
			if ($line =~m/^\[(\w+)\]/)
			{
				$check = $1;
				foreach my $current (@current)
				{
					if ($current eq $check)
					{
						print "$current already exists in the batman.ini file, please add a suffix that can be used to identify the new entry: ";
						my $suffix = <STDIN> ;
						chomp $suffix;
						$check = $check."_".$suffix;
					}
				}
				print INI "[$check]\n";
			}
			else
			{
				print INI "$line";
			}
		}
		elsif ($line =~m/^££/) # lines can be ignored
		{
			next;
		}
		else # otherwise lines should be printed to the newly created adaptor script
		{
			print OUT "$line";
		}
	}
	
	print INI "\n";
	close INI;
	close IN;
	close OUT;
	
	# now need to restart proserver by first killing and then starting again. Need to use Sudo to perform actions as nobody user.	
	my $name = "nobody";
	my $pass = "Sch0le5";
	my $pid;
	open (PID, "$path2proserver/eg/proserver.linux0-00.pid") or die "Can't open pid for reading";
	while (my $line = <PID>)
	{
		$pid = $line;
		chomp $pid;
	}
	close PID;
	#print "$pid\n";
	my $su_k;
  	$su_k = Sudo->new(
        {
       		sudo         => "sudo",
        	username     => $name, 
        	password     => $pass,
        	program      => "/bin/kill",
        	program_args => "$pid"
        }
        );
   
  	my $kill_result = $su_k->sudo_run();
  	if (exists($kill_result->{error})) 
  	{ 
       		&handle_error($kill_result); 
     	}
    	else
    	{
    		printf "STDOUT: %s\n",$kill_result->{stdout};
       		printf "STDERR: %s\n",$kill_result->{stderr};
       		printf "return: %s\n",$kill_result->{rc};
     	}
     	chdir $path2proserver;
	my $su_l;
  	$su_l = Sudo->new(
        {
       		sudo         => "sudo",
        	username     => $name, 
        	password     => $pass,
        	program      => "eg/proserver",
        	program_args => "-c eg/file.ini"
        }
        );
     	my $launch_result = $su_l->sudo_run();
  	if (exists($launch_result->{error})) 
  	{ 
       		&handle_error($launch_result); 
     	}
    	else
    	{
    		printf "STDOUT: %s\n",$launch_result->{stdout};
       		printf "STDERR: %s\n",$launch_result->{stderr};
       		printf "return: %s\n",$launch_result->{rc};
     	}
	
	my $insert_handle = $dbh->prepare_cached('INSERT INTO output_adaptor VALUES (?,?,?)'); 
			die "Couldn't prepare queries; aborting" unless defined $insert_handle;

	my $success = 1;
	$success &&= $insert_handle->execute($output_id, $check, $adaptor);
	my $result = ($success ? $dbh->commit : $dbh->rollback);
	unless ($result)
	{ 
		die "Couldn't finish transaction: " . $dbh->errstr 
	}
}
sub ensembl_info
{
	my ($dbh2, $dbname, $ens_species, $ens_build) = @_;
	
	my $success = 0;
	#before inserting, need to make sure database hasn't already been entered
	my $sth = $dbh2->prepare('SELECT * FROM database_list WHERE database_name = ?')
                or die "Couldn't prepare statement: " . $dbh2->errstr;
	
	$sth->execute($dbname)             # Execute the query
          	or die "Couldn't execute statement: " . $sth->errstr;
          	
        if (my @data = $sth->fetchrow_array())
        {
        		print "$data[1] is already present\n";
        		$success = 1;
	}
	else
	{	
		my $insert_handle = $dbh2->prepare_cached('INSERT INTO database_list VALUES (database_id,?,?,?)'); 
				die "Couldn't prepare queries; aborting" unless defined $insert_handle;

		$success = 1;
		$success &&= $insert_handle->execute($dbname,$ens_species,$ens_build);
		my $result = ($success ? $dbh2->commit : $dbh2->rollback);
		unless ($result)
		{ 
			die "Couldn't finish transaction: " . $dbh2->errstr 
		}
		
	}
	return $success;
}
sub calibrate_plot
{
	my ($expt,$expt_id,$scatter,$trend,$calib_output,$plot_file) = @_;
	
	if ($plot_file eq "")
	{
	open GNU, ">$calib_output/calib_commands.dat" or die "Can't write out to $calib_output/calib_commands.dat: $!";
	print GNU "set terminal jpeg small\n";
	my $output_jpeg = "$calib_output/calibrate_$expt_id"."_$expt".".jpeg";
	print GNU "set output '$output_jpeg'\n";
	print GNU "set xlabel \"log2 ratio\"\n";
	print GNU "set ylabel \"Total CpG influence\"\n";
	print GNU "plot '$scatter$expt"."_scatter.dat' ti 'MeDIP data', '$trend$expt"."_trend.dat' ti 'Means of central portion' with linespoints lw 2";
	close GNU;
	
	system "gnuplot $calib_output/calib_commands.dat";
	}
	else
	{
		system("cp $plot_file/calibrate_$expt_id"."_$expt".".jpeg $calib_output/calibrate_$expt_id"."_$expt".".jpeg")
	}
	#unlink "$calib_output/calib_commands.dat";
}
sub trim
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
