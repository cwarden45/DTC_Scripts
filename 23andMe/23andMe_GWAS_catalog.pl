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
my $overlap_file;
my $GWAS_file;
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
						$GWAS_file = "$dir/gwascatalog.txt";
					}#end if ($os eq "MacOS")
				elsif ($os_name eq "PC")
					{
						#PC
						$genome_file = "$dir\\$genome_file";
						$GWAS_file = "$dir\\gwascatalog.txt";
					}#end if ($os eq "MacOS")
				
				$overlap_file = $genome_file;
				$overlap_file =~ s/.txt/_GWAS.txt/g;
			}#end if ($arg =~ /--genome=/)
	}#end foreach my $arg (@ARGV)
	
unless(defined($genome_file))
	{
		print "You didn't specify a genome file~!\n";
		exit;
	}
unless(defined($GWAS_file))
	{
		print "You didn't specify a GWAS file!\n";
		exit;
	}
	
unless(defined($overlap_file))
	{
		print "There is no outputfile!\n";
		exit;
	}
	
GWAS_23andMe_data($genome_file, $GWAS_file, $overlap_file);

exit;

sub GWAS_23andMe_data
	{
		my ($inputfile, $gwas_file, $outputfile)=@_;
		
		my %SNP_hash=define_23andMe_hash($inputfile);
		
		open(OUTPUTFILE, ">$outputfile") || die("Could not open $outputfile!");
		print OUTPUTFILE "rsid\tgenotype\trisk.allele\trisk.control.freq\trisk.status\tdisease\tOR\tOR.CI\tpvalue\tlink\n";
		
		my $line_count=0;
		open(INPUTFILE, $gwas_file) || die("Could not open $gwas_file!");
		while (<INPUTFILE>)
			{
				 $line_count++;
				 my $line = $_;
				 chomp $line;
				 if(($line_count > 1) && ($line =~ /\w+/))
				 	{
				 		my @line_info = split("\t",$line);
						my $link = $line_info[5];
						my $disease = $line_info[7];
						my $control_freq = $line_info[26];
						my $OR = $line_info[30];
						my $OR_CI = $line_info[31];
						my $pvalue = $line_info[27];
						if($line_info[20] =~ /^rs\d+-\w/)
							{
								unless($line_info[20] =~ /\?/)
									{
										$line_info[20] =~ s/\s//g;
										my ($SNP, $risk_allele)=($line_info[20] =~ /(rs\d+)-(\w)/);
								
										#print "$line_info[20]\t$SNP\n";
										if(defined($SNP_hash{$SNP}))
											{
												my $genotype = $SNP_hash{$SNP};
												
												my $status = "WT";
												
												my $allele1 = substr($genotype,0,1);
												my $allele2 = substr($genotype,1,1);
												
												my $allele_status = 0;
												
												if($risk_allele eq $allele1)
													{
													$allele_status++;
													}

												if($risk_allele eq $allele2)
													{
													$allele_status++;
													}
													
												if($allele_status == 1)
													{
														$status = "Heterozygous";
													}
												elsif($allele_status == 2)
													{
														$status = "Homozygous";
													}
												
												print OUTPUTFILE "$SNP\t$genotype\t$risk_allele\t$control_freq\t$status\t$disease\t$OR\t$OR_CI\t$pvalue\t$link\n";
											}#end if(defined($SNP_hash{$SNP}))
									}#end unless($line_info[20] =~ /?/)
							}#end if($line_info[20] =~ /^rs/)
				 	}#end if($line_count > 1)
			}#end while (<INPUTFILE>)
			
		close(INPUTFILE);
		close(OUTPUTFILE);
		
	}#end def check_sample_ids

sub define_23andMe_hash
	{
		my ($inputfile)=@_;
		
		my %hash;
		open(INPUTFILE, $inputfile) || die("Could not open $inputfile!");
		while (<INPUTFILE>)
			{
				 my $line = $_;
				 chomp $line;
				 unless ($line =~ /^#/)
				 	{
						if($line =~ /^rs/)
							{
								my @line_info = split("\t",$line);
								my $rs = $line_info[0];
								my $genotype = $line_info[3];
								$hash{$rs}=$genotype;
							}#end if($line =~ /^rs/)
				 	}#end if($line_count > 1)
			}#end while (<INPUTFILE>)
			
		close(INPUTFILE);		
		return %hash;
	}#end def define_23andMe_hash
	
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
