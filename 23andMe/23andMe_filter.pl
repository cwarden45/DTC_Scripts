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
#print "$os\n";
#exit;
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

	
my $combined_file;
my $filtered_file;
my $OR_cutoff = 2;
my $GWAS_status = "Heterozygous";
my $PAM_cutoff = 0;
my $freq_cutoff = "none";

foreach my $arg (@ARGV)
	{
		if ($arg =~ /--input=/)
			{
				#redefine outputfile
				($combined_file) = ($arg =~ /--input=(.*)/);

				if ($os_name eq "MAC")
					{
						#Mac
						$combined_file = "$dir/$combined_file";
					}#end if ($os eq "MacOS")
				elsif ($os_name eq "PC")
					{
						#PC
						$combined_file = "$dir\\$combined_file";
					}#end if ($os eq "MacOS")
				
				$filtered_file = $combined_file;
				$filtered_file =~ s/.txt/_filtered.txt/g;
			}#end if ($arg =~ /--genome=/)
	}#end foreach my $arg (@ARGV)

foreach my $arg (@ARGV)
	{
		if ($arg =~ /--output=/)
			{
				#redefine outputfile
				($filtered_file) = ($arg =~ /--output=(.*)/);

				if ($os_name eq "MAC")
					{
						#Mac
						$filtered_file = "$dir/$filtered_file";
					}#end if ($os eq "MacOS")
				elsif ($os_name eq "PC")
					{
						#PC
						$filtered_file = "$dir\\$filtered_file";
					}#end if ($os eq "MacOS")
			}#end if ($arg =~ /--genome=/)
		elsif ($arg =~ /--OR=/)
			{
				#redefine outputfile
				($OR_cutoff) = ($arg =~ /--OR=(.*)/);
			}#end if ($arg =~ /--genome=/)
		elsif ($arg =~ /--risk_status=/)
			{
				#redefine outputfile
				($GWAS_status) = ($arg =~ /--risk_status=(.*)/);
			}#end if ($arg =~ /--genome=/)
		elsif ($arg =~ /--PAM=/)
			{
				#redefine outputfile
				($PAM_cutoff) = ($arg =~ /--PAM=(.*)/);
			}#end if ($arg =~ /--genome=/)
		elsif ($arg =~ /--allele_freq=/)
			{
				#redefine outputfile
				($freq_cutoff) = ($arg =~ /--allele_freq=(.*)/);
			}#end if ($arg =~ /--genome=/)
	}#end foreach my $arg (@ARGV)
	
unless(defined($combined_file))
	{
		print "You didn't specify an inputfile!\n";
		exit;
	}
	
unless(defined($filtered_file))
	{
		print "There is no outputfile!\n";
		exit;
	}
	
reformat_23andMe_data($combined_file, $filtered_file, $OR_cutoff, $GWAS_status, $PAM_cutoff, $freq_cutoff);

exit;

sub reformat_23andMe_data
	{
		my ($inputfile, $outputfile, $OR_cutoff, $GWAS_status, $PAM_cutoff, $freq_cutoff)=@_;
		print "OR > $OR_cutoff\nRisk Status: $GWAS_status\nPAM < $PAM_cutoff\nRisk Freq: $freq_cutoff\n";
		
		open(OUTPUTFILE, ">$outputfile") || die("Could not open $outputfile!");
		
		my $line_count=0;
		open(INPUTFILE, $inputfile) || die("Could not open $inputfile!");
		while (<INPUTFILE>)
			{
				 $line_count++;
				 my $line = $_;
				 chomp $line;
				 if($line_count == 1)
					{
						print OUTPUTFILE "$line\n";
				 	}#end if($line_count == 1)
				else
					{
						my @line_info = split("\t",$line);
						my $OR_test = $line_info[33];
						my $risk_status = $line_info[31];
						my $euro_freq = $line_info[20];
						my $asian_freq = $line_info[21];
						my $african_freq = $line_info[19];
						my $PAM_test = $line_info[28];
						
						my $OR_flag = 0;
						if($OR_cutoff eq "none")
							{
								$OR_flag = 1;
							}
						elsif(($OR_test ne "NA") && ($OR_test ne "NR"))
							{
								if($OR_test > $OR_cutoff)
									{
										$OR_flag = 1;
									}
							}#ne elsif($OR_test ne "NA")

						
						my $GWAS_flag = 0;
						if($GWAS_status eq "none")
							{
								$GWAS_flag = 1;
							}
						elsif(($GWAS_status eq "Homozygous") && ($GWAS_status eq $risk_status))
							{
								$GWAS_flag = 1;
							}
						elsif(($GWAS_status eq "Heterozygous") && (($risk_status eq "Homozygous") || ($risk_status eq "Heterozygous")))
							{
								$GWAS_flag = 1;
							}
						
						my $freq_flag=0;
						if($freq_cutoff eq "none")
							{
								#print "No filtering for risk allele frequency in controls.\n";
								#exit;
								$freq_flag=1;
							}#end if($freq_cutoff eq "none")
						else
							{
								my ($bg, $comp, $freq_threshold)=($freq_cutoff =~ /(.*)_(.*)_(.*)/);
								my $test_freq;
								
								if($bg eq "European")
									{
										$test_freq = $euro_freq;
									}#end if($bg eq "European")
								elsif($bg eq "African")
									{
										$test_freq = $african_freq;
									}#end elsif($bg eq "African")
								elsif($bg eq "Asian")
									{
										$test_freq = $asian_freq;
									}#end elsif($bg eq "African")
								else
									{
										print "$bg is not defined as a background!  Please use European, African, or Asian.\n";
										exit;
									}#end else
								
								unless($test_freq eq "NA")
									{
										if($comp eq "gt")
											{
												if($test_freq > $freq_threshold)
													{
														$freq_flag=1;
													}
											}#end if($comp eq "gt")
										elsif($comp eq "lt")
											{
												if($test_freq < $freq_threshold)
													{
														$freq_flag=1;
														#print "$freq_threshold\n";
													}
											}#end if($comp eq "gt")
										else
											{
												print "$comp is not defined as a comparison type!  Please use \"gt\" if you want samples above a cutoff frequency and \"lt\" if you want samples below a cutoff frequency.";
												exit;
											}#end else

									}#end unless($test_freq eq "NA")
								
							}#end else
						
						my $PAM_flag = 0;
						if($PAM_cutoff eq "none")
							{
								$PAM_flag = 1;
							}
						elsif($PAM_test eq "STOP")
							{
								#print "$line\n";
								$PAM_flag = 1;
							}
						elsif($PAM_test ne "NA")
							{
								if($PAM_test < $PAM_cutoff)
									{
										$PAM_flag = 1;
									}
							}#ne elsif($OR_test ne "NA")
							
						if($OR_flag && $GWAS_flag && $freq_flag && $PAM_flag)
							{
								print OUTPUTFILE "$line\n";
							}#end if($OR_flag && $GWAS_flag && $freq_flag && $PAM_flag)
					}#end else
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