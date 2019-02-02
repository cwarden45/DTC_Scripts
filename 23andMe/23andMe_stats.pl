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

			}#end if ($arg =~ /--genome=/)
	}#end foreach my $arg (@ARGV)

	
unless(defined($combined_file))
	{
		print "You didn't specify an inputfile!\n";
		exit;
	}
	

	
SNP_stats($combined_file);
exit;

sub SNP_stats
	{
		my ($inputfile)=@_;

		my %total_SNPs;
		my %risk_SNPs;
		my %hetero_risk;
		my %homo_risk;
		my %OR2;
		my %coding;
		my %nonsyn;
		my %PAM;
		my %stop;
		my %disease;
		
		
		my $line_count=0;
		open(INPUTFILE, $inputfile) || die("Could not open $inputfile!");
		while (<INPUTFILE>)
			{
				 $line_count++;
				 my $line = $_;
				 chomp $line;
				 if($line_count > 1)
					{
						my @line_info = split("\t",$line);
						my $chr = $line_info[1];
						my $pos = $line_info[2];
						my $SNP_type = $line_info[9];
						my $OR_test = $line_info[33];
						my $risk_status = $line_info[31];
						my $PAM_test = $line_info[28];
						my $disease = $line_info[32];
						
						unless(defined($total_SNPs{"$chr$pos"}))
							{
								$total_SNPs{"$chr$pos"}=1;
							}
						
						#print "$SNP_type\n";
						if($SNP_type eq "missense")
							{
								$nonsyn{"$chr$pos"}=1;
								$coding{"$chr$pos"}=1;
							}
						elsif($SNP_type eq "coding-synonymous")
							{
								$coding{"$chr$pos"}=1;
							}
						
						unless($disease eq "NA")
							{
								$disease{"$chr$pos"}=1;
							}
						
						if(($OR_test ne "NA") && ($OR_test ne "NR"))
							{
								if($OR_test > 2)
									{
										$total_SNPs{"$chr$pos"}=1;
									}
							}#ne elsif($OR_test ne "NA")
						
						if($risk_status eq "Homozygous")
							{
								$risk_SNPs{"$chr$pos"}=1;
								$homo_risk{"$chr$pos"}=1;
							}
						elsif($risk_status eq "Heterozygous")
							{
								$risk_SNPs{"$chr$pos"}=1;
								$hetero_risk{"$chr$pos"}=1;
							}
						
						if($PAM_test eq "STOP")
							{
								$stop{"$chr$pos"}=1;
							}	
						elsif($PAM_test ne "NA")
							{
								if($PAM_test < 0)
									{
										$PAM{"$chr$pos"}=1;
									}
							}#ne elsif($OR_test ne "NA")
							
					}#end else
			}#end while (<INPUTFILE>)
			
		close(INPUTFILE);

		print "Total SNPs: ", scalar(keys  %total_SNPs),"\n";
		print "\nSNPs with GWAS Annotations: ", scalar(keys  %disease),"\n";
		print "SNPs with GWAS Catalog Risk Allele: ", scalar(keys  %risk_SNPs),"\n";
		print "SNPs Heterozygous for Risk Allele: ", scalar(keys  %hetero_risk),"\n";
		print "SNPs Homozygous for Risk Allele: ", scalar(keys  %homo_risk),"\n";
		print "\nCoding SNPs: ", scalar(keys  %coding),"\n";
		print "Non-Synonymous SNPs: ", scalar(keys  %nonsyn),"\n";
		print "Non-Synonymous SNPs with PAM Score < 0: ", scalar(keys  %PAM),"\n";
		print "SNPs Causing Premature Stop Codons: ", scalar(keys  %stop),"\n";
		
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
