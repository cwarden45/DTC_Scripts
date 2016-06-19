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

	
my $SeattleSNP_file;
my $GWAS_file;
my $PAM_file;
my $combined_file;
foreach my $arg (@ARGV)
	{
		if ($arg =~ /--SeattleSNP=/)
			{
				#redefine outputfile
				($SeattleSNP_file) = ($arg =~ /--SeattleSNP=(.*)/);

				if ($os_name eq "MAC")
					{
						#Mac
						$SeattleSNP_file = "$dir/$SeattleSNP_file";
					}#end if ($os eq "MacOS")
				elsif ($os_name eq "PC")
					{
						#PC
						$SeattleSNP_file = "$dir\\$SeattleSNP_file";
					}#end if ($os eq "MacOS")
				
				$combined_file = $SeattleSNP_file;
				$combined_file =~ s/.txt/_combined.txt/g;
			}#end if ($arg =~ /--genome=/)

		if ($arg =~ /--seattleSNP=/)
			{
				#redefine outputfile
				($SeattleSNP_file) = ($arg =~ /--seattleSNP=(.*)/);

				if ($os_name eq "MAC")
					{
						#Mac
						$SeattleSNP_file = "$dir/$SeattleSNP_file";
					}#end if ($os eq "MacOS")
				elsif ($os_name eq "PC")
					{
						#PC
						$SeattleSNP_file = "$dir\\$SeattleSNP_file";
					}#end if ($os eq "MacOS")
				
				$combined_file = $SeattleSNP_file;
				$combined_file =~ s/.txt/_combined.txt/g;
			}#end if ($arg =~ /--genome=/)
			
		if ($arg =~ /--GWAS=/)
			{
				#redefine outputfile
				($GWAS_file) = ($arg =~ /--GWAS=(.*)/);

				if ($os_name eq "MAC")
					{
						#Mac
						$GWAS_file = "$dir/$GWAS_file";
					}#end if ($os eq "MacOS")
				elsif ($os_name eq "PC")
					{
						#PC
						$GWAS_file = "$dir\\$GWAS_file";
					}#end if ($os eq "MacOS")

			}#end if ($arg =~ /--genome=/)

		if ($arg =~ /--PAM=/)
			{
				#redefine outputfile
				($PAM_file) = ($arg =~ /--PAM=(.*)/);

				if ($os_name eq "MAC")
					{
						#Mac
						$PAM_file = "$dir/$PAM_file";
					}#end if ($os eq "MacOS")
				elsif ($os_name eq "PC")
					{
						#PC
						$PAM_file = "$dir\\$PAM_file";
					}#end if ($os eq "MacOS")

			}#end if ($arg =~ /--genome=/)
			
	}#end foreach my $arg (@ARGV)
	
	
unless(defined($SeattleSNP_file))
	{
		print "There is no SeattleSNP file!\n";
		exit;
	}

unless(defined($GWAS_file))
	{
		print "You didn't specify a GWAS Catalog file!\n";
		exit;
	}
	
unless(defined($PAM_file))
	{
		print "You didn't specify a PAM file!\n";
		exit;
	}
	
unless(defined($combined_file))
	{
		print "Outputfile wasn't defined from SeattleSNP file!\n";
		exit;
	}
	
reformat_23andMe_data($SeattleSNP_file, $GWAS_file, $PAM_file, $combined_file);

exit;

sub reformat_23andMe_data
	{
		my ($inputfile, $GWAS, $PAM, $outputfile)=@_;
		open(OUTPUTFILE, ">$outputfile") || die("Could not open $outputfile!");

		my ($GWAS_header, $hash_ref)=define_GWAS_hash($GWAS);
		my %GWAS_hash = %$hash_ref;
		my %PAM_hash = create_PAM_hash($PAM);
		my %aa_hash = aa_symbol_to_letter();
		
		my $line_count=0;
		open(INPUTFILE, $inputfile) || die("Could not open $inputfile!");
		while (<INPUTFILE>)
			{
				 $line_count++;
				 my $line = $_;
				 chomp $line;
				 if($line_count == 1)
					{
						print OUTPUTFILE "$line\tPAM.score\t$GWAS_header\n";
					}#end if($line_count == 1)
				 elsif($line =~ /\w+/)
				 	{
				 		unless($line =~ /^#/)
							{
								my @line_info = split("\t",$line);
								my $rs = "rs$line_info[10]";
								my $aa_sub = $line_info[11];
								
								my $PAM_score = "NA";
								unless($aa_sub eq "none")
									{

										my ($aa1,$aa2)= ($aa_sub =~ /(\w+),(\w+)/);
										if(($aa1 eq "stop") || ($aa2 eq "stop"))
											{
												$PAM_score = "STOP";
											}
										else
											{
												unless(defined($aa_hash{$aa1}))
													{
														print "$aa1 isn't defined!\n";
														exit;
													}#end unless(defined($aa_hash{$aa1}))
												$aa1 = $aa_hash{$aa1};
												unless(defined($aa_hash{$aa2}))
													{
														print "$aa1 isn't defined!\n";
														exit;
													}#end unless(defined($aa_hash{$aa1}))
												$aa2 = $aa_hash{$aa2};
												$PAM_score = $PAM_hash{"$aa1$aa2"};	
											}#end else														
									}#end unless($aa_sub eq "none")
								#print "|$aa_sub|$PAM_score|\n";
								
								#print "$rs\n";
								if(defined($GWAS_hash{$rs}))
									{
										#print "$rs\n";
										foreach my $GWAS_text (split("\n",$GWAS_hash{$rs}))
											{
												print OUTPUTFILE "$line\t$PAM_score\t$GWAS_text\n";
											}
									}#end if(defined($GWAS_hash{$rs}))
								else
									{
										#print "$rs\n";
										my @GWAS_info = split("\t",$GWAS_header);
										my $GWAS_filer_count = scalar(@GWAS_info);
										print OUTPUTFILE "$line\t$PAM_score";
										for (my $i = 0; $i < $GWAS_filer_count; $i++)
											{
												print OUTPUTFILE "\tNA";
											}#end for ($i = 0; $i < $GWAS_filer_count; $i++)
										print OUTPUTFILE "\n";
									}#end else
							}#end if($line_count > 1)
							}#end unless($line =~ /^#/)
			}#end while (<INPUTFILE>)
			
		close(INPUTFILE);
		close(OUTPUTFILE);
		
	}#end def check_sample_ids

sub define_GWAS_hash
	{
		my ($inputfile)=@_;
		
		my %hash;
		my $header;

		my $line_count=0;
		open(INPUTFILE, $inputfile) || die("Could not open $inputfile!");
		while (<INPUTFILE>)
			{
				 $line_count++;
				 my $line = $_;
				 chomp $line;
				 my @line_info = split("\t",$line);
				 if($line_count == 1)
					{
						shift(@line_info);
						shift(@line_info);
						$header = join("\t",@line_info);
					}#end if($line_count == 1)
				 else
				 	{
						my $rs = shift(@line_info);
						shift(@line_info);
						if(defined($hash{$rs}))
							{
								$hash{$rs} = $hash{$rs}."\n".join("\t",@line_info);
							}
						else
							{
								$hash{$rs} = join("\t",@line_info);
							}
				 	}#end if($line_count > 1)
			}#end while (<INPUTFILE>)
			
		close(INPUTFILE);
		return($header, \%hash);
	}#end def define_GWAS_hash
	
sub create_PAM_hash
	{
		my ($inputfile)=@_;
		
		my %hash;
		
		my @aa_indices;
		
		my $line_count=0;
		open(INPUTFILE, $inputfile) || die("Could not open $inputfile!");
		while (<INPUTFILE>)
			{
				my $line = $_;
				chomp $line;
				$line =~ s/\r//g;
				my @line_info = split("\t",$line);
				$line_count++;
				if($line_count == 1 )
					{
						@aa_indices = @line_info;
						#print "@aa_indices\n";
					}#end if($line_count == 1 )
				else
					{
						my $aa1 = $line_info[0];
						for (my $i=1; $i < scalar(@line_info); $i++)
							{
								my $aa2 = $aa_indices[$i];
								my $score = $line_info[$i];
								
								#print "|$aa2|\n";
								
								my $hash_key = "$aa1$aa2";
								#print "$hash_key --> $score\n";
								$hash{$hash_key}=$score;
							}#end for (my $i=1; $i < scalar(@line_info); $i++)
					}#end else
			}#end 	while (<INPUTFILE>)
		close(INPUTFILE);		
		
		return %hash;
	}#end def create_PAM_hash
	
sub  aa_symbol_to_letter
	{
		my %hash;
		
		$hash{"ALA"}="A";
		$hash{"CYS"}="C";
		$hash{"ASP"}="D";
		$hash{"GLU"}="E";
		$hash{"PHE"}="F";
		$hash{"GLY"}="G";
		$hash{"HIS"}="H";
		$hash{"ILE"}="I";
		$hash{"LYS"}="K";
		$hash{"LEU"}="L";
		$hash{"MET"}="M";
		$hash{"ASN"}="N";
		$hash{"PRO"}="P";
		$hash{"GLN"}="Q";
		$hash{"ARG"}="R";
		$hash{"SER"}="S";
		$hash{"THR"}="T";
		$hash{"TRP"}="W";
		$hash{"TYR"}="Y";
		$hash{"VAL"}="V";

		
		return %hash;
	}#end def  aa_symbol_to_letter
	
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