#Code written by Charles Warden (cwarden@coh.org, x60233)

#This function creates an R script that can be used to create a .RData file

#to run:
#1) move to directory of interest
#2) type in "perl /path/to/file/make_create_RData_file.pl --genome=23andMe_genome_file"


use warnings;
use strict;
use diagnostics;
use Cwd;

my $dir = getcwd;

my $os = $^O;
my $os_name;
if (($os eq "MacOS")||($os eq "darwin"))
	{
		#Mac
		$os_name = "MAC";
	}#end if ($os eq "MacOS")
elsif ($os eq "MSWin32")
	{
		#PC
		$os_name = "PC";
	}#end if ($os eq "MacOS")
else
	{
		print "Need to specify folder structure for $os!\n";
		exit;
	}#end

	
my $genome_file;
my $SeattleSNP_file;
foreach my $arg (@ARGV)
	{
		if ($arg =~ /--genome=/)
			{
				#redefine outputfile
				($genome_file) = ($arg =~ /--genome=(.*)/);

				if ($os_name eq "MAC")
					{
						#Mac
						$genome_file = "$dir/$genome_file";
					}#end if ($os eq "MacOS")
				elsif ($os_name eq "PC")
					{
						#PC
						$genome_file = "$dir\\$genome_file";
					}#end if ($os eq "MacOS")
				
				$SeattleSNP_file = $genome_file;
				$SeattleSNP_file =~ s/.txt/_SeattleSNP.txt/g;
			}#end if ($arg =~ /--genome=/)
	}#end foreach my $arg (@ARGV)
	
unless(defined($genome_file))
	{
		print "You didn't specify a genome file~!\n";
		exit;
	}
	
unless(defined($SeattleSNP_file))
	{
		print "Thereis no outputfile!\n";
		exit;
	}
	
reformat_23andMe_data($genome_file, $SeattleSNP_file);

exit;

sub reformat_23andMe_data
	{
		my ($inputfile, $outputfile)=@_;
		open(OUTPUTFILE, ">$outputfile") || die("Could not open $outputfile!");
		print OUTPUTFILE "rsid\tchromosome\tposition\tallele1\tallele2\n";
		
		open(INPUTFILE, $inputfile) || die("Could not open $inputfile!");
		while (<INPUTFILE>)
			{
				 my $line = $_;
				 chomp $line;
				 unless ($line =~ /^#/)
				 	{
				 		my @line_info = split("\t",$line);
						$line_info[3]=substr($line_info[3],0,1)."\t".substr($line_info[3],1,1);
						$line = join("\t",@line_info);
						print OUTPUTFILE "$line\n";
				 	}#end if($line_count > 1)
			}#end while (<INPUTFILE>)
			
		close(INPUTFILE);
		close(OUTPUTFILE);
		
	}#end def check_sample_ids
	
sub pc_to_mac
	{
		my ($file)=@_;
		open(INPUTFILE, $file) || die("Could not open $file!");
		my @lines = <INPUTFILE>;
		close(INPUTFILE);
		
		open(OUTPUTFILE, ">$file") || die("Could not open $file!");
		foreach my $line (@lines)
			{
				$line =~ s/\r/\n/g;
				print OUTPUTFILE "$line";
			}#end foreach my $line (@lines)
		close(OUTPUTFILE);
	}#end def pc_to_mac