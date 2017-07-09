use warnings;
use strict;
use diagnostics;
use File::Basename;

my $smallVCF = "";
my $largeVCF = "";
my $outputFile = "";

foreach my $arg (@ARGV)
	{
		if ($arg =~ /--smallVCF=/)
			{
				($smallVCF) = ($arg =~ /--smallVCF=(.*)/);
			}#end if ($arg =~ /--smallVCF=/)

		if ($arg =~ /--largeVCF=/)
			{
				($largeVCF) = ($arg =~ /--largeVCF=(.*)/);
			}#end if ($arg =~ /--largeVCF=/)

		if ($arg =~ /--output=/)
			{
				#redefine outputfile
				($outputFile) = ($arg =~ /--output=(.*)/);
			}#end if ($arg =~ /--output=/)
			
		if ($arg =~ /--help=/)
			{
				print "Usage: perl VCF_recovery.pl --smallVCF=[Genos / 23andMe / G4G].vcf --largeVCF=[Veritas_variants].vcf --output=[smallID]_in=_[largeID]_discordant.vcf\n";
				print "--smallVCF : List of variants to recover in VCF format\n";
				print "--largeVCF : List of variants to test in VCF format\n";
				print "--output : Manually specify output file.  Otherwise, set to [smallID]_in_[largeID]_discordant.vcf\n";
				exit;
			}#end if ($arg =~ /--output=/)
	}#end foreach my $arg (@ARGV)
	
unless(defined($smallVCF))
	{
		print "You didn't specify a test vcf (smaller set of variants)!\n";
		exit;
	}
unless(defined($largeVCF))
	{
		print "You didn't specify a recovery vcf (larger set of variants)!\n";
		exit;
	}

my $smallBase = basename($smallVCF);
my $largeBase = basename($largeVCF);
	
my $smallID =substr($smallBase, 0, length($smallBase)-4);
my $largeID =substr($largeBase, 0, length($largeBase)-4);
	
if ($outputFile eq ""){
	print "$smallBase -> $largeBase\n";
	
	if(!(lc($smallBase) =~ /.vcf$/)){
		print "--smallVCF file does not have proper extension (.vcf or .VCF)\n";
		exit;
	}elsif(!(lc($largeBase) =~ /.vcf$/)){
		print "--largeVCF file does not have proper extension (.vcf or .VCF)\n";
		exit;
	}else{
		$outputFile = "$smallID\_in_$largeID\_discordant.vcf";
	}
	
	print "Writing missing variants in $outputFile\n";
}#end if ($outputFile eq "")


my ($SNP_pos_ref, $SNP_var_ref, $ins_pos_ref, $ins_var_ref, $del_pos_ref, $del_var_ref)=create_vcf_hash($smallVCF);
my %small_SNP_PosHash = %$SNP_pos_ref;
my %small_SNP_VarHash = %$SNP_var_ref;
my %small_ins_PosHash = %$ins_pos_ref;
my %small_ins_VarHash = %$ins_var_ref;
my %small_del_PosHash = %$del_pos_ref;
my %small_del_VarHash = %$del_var_ref;

($SNP_pos_ref, $SNP_var_ref, $ins_pos_ref, $ins_var_ref, $del_pos_ref, $del_var_ref)=create_vcf_hash($largeVCF);
my %large_SNP_PosHash = %$SNP_pos_ref;
my %large_SNP_VarHash = %$SNP_var_ref;
my %large_ins_PosHash = %$ins_pos_ref;
my %large_ins_VarHash = %$ins_var_ref;
my %large_del_PosHash = %$del_pos_ref;
my %large_del_VarHash = %$del_var_ref;

#output missing variants and report recovery rate
open(OUT, "> $outputFile")||die("Cannot open $outputFile\n");
print OUT "#ID is from small VCF\n";
print OUT "#FLAG is from file corresponding to variant\n";
print OUT "#$smallID is genotype for small VCF (discordant or missed variants)\n";
print OUT "#$largeID is genotype for large VCF (discordant genotype in multi-sample VCF format)\n";
print OUT "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t$smallID\t$largeID\n";

#SNPs
my $full_recovery_count=0;
my $partial_recovery_count=0;

foreach my $smallPos (keys %small_SNP_PosHash){
	my $small_varInfo = $small_SNP_PosHash{$smallPos};
	my @small_var_info = split("\t",$smallPos);
	my @small_var_info2 = split("\t",$small_varInfo);
	my $small_chr = $small_var_info[0];
	my $small_pos = $small_var_info[1];
	my $smallID = $small_var_info2[0];
	my $small_ref = $small_var_info2[1];
	my $small_var = $small_var_info2[2];
	my $small_flag = $small_var_info2[3];
	my $small_varID = "$small_chr\t$small_pos\tNA\t$small_ref\t$small_var";
	if(!exists($small_SNP_VarHash{$small_varID})){
		print "Problem finding matching small var info for $smallPos-->$small_varInfo\n";
		exit;
	}
	my $small_geno = $small_SNP_VarHash{$small_varID};
	if(exists($large_SNP_PosHash{$smallPos})){
		my $large_varInfo = $large_SNP_PosHash{$smallPos};
		my @large_var_info = split("\t",$smallPos);
		my @large_var_info2 = split("\t",$large_varInfo);
		my $large_chr = $large_var_info[0];
		my $large_pos = $large_var_info[1];
		my $largeID = $large_var_info2[0];
		my $large_ref = $large_var_info2[1];
		my $large_var = $large_var_info2[2];
		my $large_flag = $large_var_info2[3];
		my $large_varID = "$large_chr\t$large_pos\tNA\t$large_ref\t$large_var";
		my $large_geno = $large_SNP_VarHash{$large_varID};
		
		if ($small_varID eq $large_varID){
			if ($small_geno eq $large_geno){
				$partial_recovery_count++;
				$full_recovery_count++;
			}else{
				$partial_recovery_count++;
			}
		}else{
			print OUT "$small_chr\t$small_pos\t$smallID\t$small_ref\t$small_var\tNA\t$small_flag\tNA\tGT\t$small_geno\t0\\0\n";	
			print OUT "$large_chr\t$large_pos\t$largeID\t$large_ref\t$large_var\tNA\t$large_flag\tNA\tGT\t0\\0\t$large_geno\n";	
		}
	}else{
		print OUT "$small_chr\t$small_pos\t$smallID\t$small_ref\t$small_var\tNA\t$small_flag\tNA\tGT\t$small_geno\t0\\0\n";
	}
}#end foreach my $smallPos (keys %small_SNP_PosHash)

my $total_small_SNPs = scalar(keys(%small_SNP_VarHash));
my $full_percent_recovery = 100 * $full_recovery_count / $total_small_SNPs;
print "$full_recovery_count / $total_small_SNPs (".sprintf("%.1f",$full_percent_recovery)."%) full SNP recovery\n";
my $partial_percent_recovery = 100 * $partial_recovery_count / $total_small_SNPs;
print "$partial_recovery_count / $total_small_SNPs (".sprintf("%.1f",$partial_percent_recovery)."%) partial SNP recovery\n";

#insertions
$full_recovery_count=0;
$partial_recovery_count=0;

foreach my $smallPos (keys %small_ins_PosHash){
	my $small_varInfo = $small_ins_PosHash{$smallPos};
	my @small_var_info = split("\t",$smallPos);
	my @small_var_info2 = split("\t",$small_varInfo);
	my $small_chr = $small_var_info[0];
	my $small_pos = $small_var_info[1];
	my $smallID = $small_var_info2[0];
	my $small_ref = $small_var_info2[1];
	my $small_var = $small_var_info2[2];
	my $small_flag = $small_var_info2[3];
	my $small_varID = "$small_chr\t$small_pos\tNA\t$small_ref\t$small_var";
	if(!exists($small_ins_VarHash{$small_varID})){
		print "Problem finding matching small var info for $smallPos-->$small_varInfo\n";
		exit;
	}
	my $small_geno = $small_ins_VarHash{$small_varID};
	if(exists($large_ins_PosHash{$smallPos})){
		my $large_varInfo = $large_ins_PosHash{$smallPos};
		my @large_var_info = split("\t",$smallPos);
		my @large_var_info2 = split("\t",$large_varInfo);
		my $large_chr = $large_var_info[0];
		my $large_pos = $large_var_info[1];
		my $largeID = $large_var_info2[0];
		my $large_ref = $large_var_info2[1];
		my $large_var = $large_var_info2[2];
		my $large_flag = $large_var_info2[3];
		my $large_varID = "$large_chr\t$large_pos\tNA\t$large_ref\t$large_var";
		my $large_geno = $large_ins_VarHash{$large_varID};
		
		if ($small_varID eq $large_varID){
			if ($small_geno eq $large_geno){
				$partial_recovery_count++;
				$full_recovery_count++;
			}else{
				$partial_recovery_count++;
			}
		}else{
			print OUT "$small_chr\t$small_pos\t$smallID\t$small_ref\t$small_var\tNA\t$small_flag\tNA\tGT\t$small_geno\t0\\0\n";	
			print OUT "$large_chr\t$large_pos\t$largeID\t$large_ref\t$large_var\tNA\t$large_flag\tNA\tGT\t0\\0\t$large_geno\n";	
		}
	}else{
		print OUT "$small_chr\t$small_pos\t$smallID\t$small_ref\t$small_var\tNA\t$small_flag\tNA\tGT\t$small_geno\t0\\0\n";
	}
}#end foreach my $smallPos (keys %small_SNP_PosHash)

my $total_small_ins = scalar(keys(%small_ins_VarHash));
$full_percent_recovery = 100 * $full_recovery_count / $total_small_ins;
print "$full_recovery_count / $total_small_ins (".sprintf("%.1f",$full_percent_recovery)."%) full insertion recovery\n";
$partial_percent_recovery = 100 * $partial_recovery_count / $total_small_ins;
print "$partial_recovery_count / $total_small_ins (".sprintf("%.1f",$partial_percent_recovery)."%) partial insertion recovery\n";


#deletions
$full_recovery_count=0;
$partial_recovery_count=0;

foreach my $smallPos (keys %small_del_PosHash){
	my $small_varInfo = $small_del_PosHash{$smallPos};
	my @small_var_info = split("\t",$smallPos);
	my @small_var_info2 = split("\t",$small_varInfo);
	my $small_chr = $small_var_info[0];
	my $small_pos = $small_var_info[1];
	my $smallID = $small_var_info2[0];
	my $small_ref = $small_var_info2[1];
	my $small_var = $small_var_info2[2];
	my $small_flag = $small_var_info2[3];
	my $small_varID = "$small_chr\t$small_pos\tNA\t$small_ref\t$small_var";
	if(!exists($small_del_VarHash{$small_varID})){
		print "Problem finding matching small var info for $smallPos-->$small_varInfo\n";
		exit;
	}
	my $small_geno = $small_del_VarHash{$small_varID};
	if(exists($large_del_PosHash{$smallPos})){
		my $large_varInfo = $large_del_PosHash{$smallPos};
		my @large_var_info = split("\t",$smallPos);
		my @large_var_info2 = split("\t",$large_varInfo);
		my $large_chr = $large_var_info[0];
		my $large_pos = $large_var_info[1];
		my $largeID = $large_var_info2[0];
		my $large_ref = $large_var_info2[1];
		my $large_var = $large_var_info2[2];
		my $large_flag = $large_var_info2[3];
		my $large_varID = "$large_chr\t$large_pos\tNA\t$large_ref\t$large_var";
		my $large_geno = $large_del_VarHash{$large_varID};
		
		if ($small_varID eq $large_varID){
			if ($small_geno eq $large_geno){
				$partial_recovery_count++;
				$full_recovery_count++;
			}else{
				$partial_recovery_count++;
			}
		}else{
			print OUT "$small_chr\t$small_pos\t$smallID\t$small_ref\t$small_var\tNA\t$small_flag\tNA\tGT\t$small_geno\t0\\0\n";	
			print OUT "$large_chr\t$large_pos\t$largeID\t$large_ref\t$large_var\tNA\t$large_flag\tNA\tGT\t0\\0\t$large_geno\n";	
		}
	}else{
		print OUT "$small_chr\t$small_pos\t$smallID\t$small_ref\t$small_var\tNA\t$small_flag\tNA\tGT\t$small_geno\t0\\0\n";
	}
}#end foreach my $smallPos (keys %small_SNP_PosHash)

my $total_small_del = scalar(keys(%small_del_VarHash));
$full_percent_recovery = 100 * $full_recovery_count / $total_small_del;
print "$full_recovery_count / $total_small_del (".sprintf("%.1f",$full_percent_recovery)."%) full deletion recovery\n";
$partial_percent_recovery = 100 * $partial_recovery_count / $total_small_del;
print "$partial_recovery_count / $total_small_del (".sprintf("%.1f",$partial_percent_recovery)."%) partial deletion recovery\n";

close(OUT);

exit;

sub create_vcf_hash{
	my ($inputfile)=@_;
	
	my %small_SNP_PosHash;
	my %small_SNP_VarHash;
	my %small_ins_PosHash;
	my %small_ins_VarHash;
	my %small_del_PosHash;
	my %small_del_VarHash;
	
	open(INPUTFILE, $inputfile) || die("Could not open $inputfile!");
	while (<INPUTFILE>)
		{
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/\n//g;
			
			if (!($line =~ /^#/)){
				my @lineInfo = split("\t",$line);

				my $chr = $lineInfo[0];
				my $pos = $lineInfo[1];
				my $varID = $lineInfo[2];
				my $ref = uc($lineInfo[3]);
				my $var = uc($lineInfo[4]);
				my $flag = $lineInfo[6];
				my $format_text = $lineInfo[8];
				my $geno_text = $lineInfo[9];
				
				#leave in to be compatible with 23andMe .vcf created with `vcf_recovery.py
				if(!($flag =~ "/nocall/")&&($var ne ".")){
					my $genotype = "0";
					
					if($format_text =~ /^GT/){
						my @geno_info = split(":",$geno_text);
						$genotype = $geno_info[0];
					}else{
						print "Need to extract genotype from different position: $format_text\n";
						exit;
					}
						
					if (($genotype ne "0/0") && ($genotype ne "0")){
						my $smallPos = "$chr\t$pos";
						my $smallVarID = "$chr\t$pos\tNA\t$ref\t$var";
						
						if((length($ref)==1)&(length($var)==1)){
							#variant is SNP
							$small_SNP_PosHash{$smallPos}="$varID\t$ref\t$var\t$flag";
							$small_SNP_VarHash{$smallVarID}=$genotype;
						}else{
							if ($var =~ /,/){
								#multi-var result
								my @multi_var = split(",",$var);
								
								foreach my $test_var (@multi_var){
									$smallVarID = "$chr\t$pos\tNA\t$ref\t$test_var";
									if ($test_var ne $ref){
										if((length($test_var)==1)&(length($ref)==1)){
											$small_SNP_PosHash{$smallPos}="$varID\t$ref\t$test_var\t$flag";
											$small_SNP_VarHash{$smallVarID}=$genotype;											
										}elsif(length($ref) > length($test_var)){
											#deletion
											$small_del_PosHash{$smallPos}="$varID\t$ref\t$test_var\t$flag";
											$small_del_VarHash{$smallVarID}=$genotype;									
										}elsif(length($ref) < length($test_var)){
											#insertion
											$small_ins_PosHash{$smallPos}="$varID\t$ref\t$test_var\t$flag";
											$small_ins_VarHash{$smallVarID}=$genotype;									
										}else{
											print "Skip counting $test_var in complex variant -  ref: $ref, var: $var\n";
											#exit;
										}#end else
									}#end if ($test_var != $ref)
								}#end foreach my $test_var (@multi_var)
							}else{
								if(length($ref) > length($var)){
									#deletion
									$small_del_PosHash{$smallPos}="$varID\t$ref\t$var\t$flag";
									$small_del_VarHash{$smallVarID}=$genotype;									
								}elsif(length($ref) < length($var)){
									#insertion
									$small_ins_PosHash{$smallPos}="$varID\t$ref\t$var\t$flag";
									$small_ins_VarHash{$smallVarID}=$genotype;									
								}else{
									print "Skip counting ref: $ref, var: $var\n";
									#exit;
								}#end else
							}#end else
						}#end else
					}#end if (($genotype ne "0/0") && ($genotype ne "0"))
				}#end if(!($flag =~ "nocall"))
			}#end if (!($line =~ /^#/))	
		}#end while (<INPUTFILE>)
	close(INPUTFILE);
	
	return (\%small_SNP_PosHash, \%small_SNP_VarHash,
			\%small_ins_PosHash, \%small_ins_VarHash,
			\%small_del_PosHash, \%small_del_VarHash);
}#end def create_vcf_hash