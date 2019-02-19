#Code written by Charles Warden (cwarden@coh.org, x60233)

#This function creates an R script that can be used to create a .RData file

#to run:
#1) move to directory of interest
#2) type in "perl /path/to/file/make_create_RData_file.pl --genome=AncestryDNA_genome_file"


use warnings;
use strict;
use diagnostics;
use Cwd;

my $dir = getcwd;

my $os = $^O;
my $os_name;
if (($os eq "MacOS")||($os eq "darwin")||($os eq "linux"))
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
my $X23andMe_file;
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
				
				$X23andMe_file = $genome_file;
				$X23andMe_file =~ s/.txt/_23andMe.txt/g;
			}#end if ($arg =~ /--genome=/)
	}#end foreach my $arg (@ARGV)
	
unless(defined($genome_file))
	{
		print "You didn't specify a genome file using --genome=!\n";
		exit;
	}
	
unless(defined($X23andMe_file))
	{
		print "Thereis no outputfile!\n";
		exit;
	}

reformat_AncestryDNA_data($genome_file, $X23andMe_file);

exit;

sub reformat_AncestryDNA_data
	{
		my ($inputfile, $outputfile)=@_;
		open(OUTPUTFILE, ">$outputfile") || die("Could not open $outputfile!");
		
		open(INPUTFILE, $inputfile) || die("Could not open $inputfile!");
		while (<INPUTFILE>)
			{
				 my $line = $_;
				 chomp $line;
				 unless ($line =~ /^#/)
				 	{
				 		my @line_info = split("\t",$line);
						my $rs = $line_info[0];
						my $chr = $line_info[1];
						my $pos = $line_info[2];
						my $al1 = $line_info[3];
						my $al2 = $line_info[4];
						
						if(($al1 =~ /[ACGT]/) & ($al2 =~ /[ACGT]/))
							{
								print OUTPUTFILE "$rs\t$chr\t$pos\t$al1$al2\n";
							}#end if(($al1 =~ /[ACGT]/) & ($al2 =~ /[ACGT]/))
						
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