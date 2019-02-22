#from ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/release/20130502/supporting/hd_genotype_chip/ALL.chip.omni_broad_sanger_combined.20140818.snps.genotypes.vcf
my $VCF_1KG = "ALL.chip.omni_broad_sanger_combined.20140818.snps.genotypes.vcf";
my $pop_freq = "ALL.chip.omni_broad_sanger_combined.20140818.snps_frequencies_UNRELATED_plus_1child.txt";

#require a minimum of 20 individuals counted for population / super-population

#only consider children and unrelated individuals
#from ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/working/20140502_sample_summary_info/
my $family_mapping = "20140502_all_samples.ped";

#from https://github.com/cwarden45/QCarray_Ethnicity (from http://www.internationalgenome.org/category/population/)
my $super_pop_mapping = "super-pop_mapping_for_Ogembo_QCarray_plus_CHD.txt";

#define individuals to consider, and define individual-to-population hash
my %sample_hash;
my %pop_indices;#initialize populations in output hash

my $line_count=0;
open(INPUTFILE, $family_mapping) || die("Could not open $family_mapping!");
while (<INPUTFILE>){
	$line_count++;
	my $line = $_;
	chomp $line;
	if($line_count > 1){
		my @line_info = split("\t",$line);
		my $ID = $line_info[1];
		my $pop = $line_info[6];
		my $rela = $line_info[7];
		
		$pop_indices{$pop}="";
		
		if ($rela eq "unrel"){
			$sample_hash{$ID}=$pop;
		}elsif(($rela eq "Child")|($rela eq "child")|($rela eq "daughter")){
			$sample_hash{$ID}=$pop;
		}elsif($rela eq "Child2"){
			##start by only counting one child, but can add back in these types relatively easily
			
			#$sample_hash{$ID}=$pop;
		}elsif(($rela ne "not father")|($rela ne "wife of child")){
			#skip stuff like "not father," just to be safe
		}elsif(($rela ne "father")&($rela ne "mother")&($rela ne "pat grandfather")&($rela ne "pat grandmother")&($rela ne "mat grandfather")&($rela ne "mat grandmother")&($rela ne "father; child")&($rela ne "mother; child")&($rela ne "mat grandfather; father")&($rela ne "pat grandfather; father")&($rela ne "mat grandmother; mother")&($rela ne "pat grandmother; mother")){
	
			print "Check relative code:\n";
			print "$line\n";
			print "$ID --> $pop --> $rela\n";
			exit;
		}

	}#end if($line_count > 1)
}#end while (<INPUTFILE>)
			
close(INPUTFILE);

#define population to super-population hash
my %super_pop_hash;
my %super_pop_indices;#initialize populations in output hash

my $line_count=0;
open(INPUTFILE, $super_pop_mapping) || die("Could not open $super_pop_mapping!");
while (<INPUTFILE>){
	$line_count++;
	my $line = $_;
	chomp $line;
	if($line_count > 1){
		my @line_info = split("\t",$line);
		my $pop = $line_info[0];
		my $super_pop = $line_info[1];
		
		$super_pop_hash{$pop}=$super_pop;
		$super_pop_indices{$super_pop}="";
	}#end if($line_count > 1)
}#end while (<INPUTFILE>)
			
close(INPUTFILE);

#define indices to count, output allele frequencies

open(OUTPUTFILE, ">$pop_freq") || die("Could not open $pop_freq!");

my @sorted_pop;
my @sorted_super_pop;

open(INPUTFILE, $VCF_1KG) || die("Could not open $VCF_1KG!");
while (<INPUTFILE>){
	$line_count++;
	my $line = $_;
	chomp $line;
	if (!($line =~ /^##/)){
		my @line_info = split("\t",$line);
		my $chr = $line_info[0];
		my $pos = $line_info[1];
		my $ID = $line_info[2];
		my $ref = $line_info[3];	
		my $alt = $line_info[4];
		my $qual = $line_info[5];
		my $filter = $line_info[6];
		my $info = $line_info[7];
		my $format = $line_info[8];

		if(!($line =~ /^#/)){
			#print "$line\n";
			
			print OUTPUTFILE "$chr\t$pos\t$ID\t$ref\t$alt\t$qual\t$filter\t$info\t$format";			

			foreach my $super_pop (@sorted_super_pop){
				my $super_pop_index_text = $super_pop_indices{$super_pop};
				my @super_pop_pos = split(",",$super_pop_index_text);

				my $total_alleles=0;
				my $var_alleles = 0;
				
				foreach my $i (@super_pop_pos){
					if($line_info[$i] ne "./."){
						if (!($line_info[$i] =~ /(\d)\/(\d)/)){
							print "Define alternative code for genotype $line_info[$i]\n";
							exit;
						}
						
						my ($allele1,$allele2) = ($line_info[$i] =~ /(\d)\/(\d)/);
						$total_alleles +=2;
						if($allele1 == 1){
							$var_alleles++
						}
						if($allele2 == 1){
							$var_alleles++
						}
					}#end if($line_info[$i] ne "./.")}
				}#end foreach my $i (@super_pop_pos)
				
				if ($total_alleles == 0){
					print OUTPUTFILE "\tNA";
				}else{
					my $var_freq = $var_alleles / $total_alleles;
					print OUTPUTFILE "\t",sprintf("%.2f", $var_freq);
				}#end else 
			}#end foreach my $super_pop (@sorted_super_pop)

			foreach my $pop (@sorted_pop){
				my $pop_index_text = $pop_indices{$pop};
				my @pop_pos = split(",",$pop_index_text);

				my $total_alleles=0;
				my $var_alleles = 0;
				
				foreach my $i (@pop_pos){
					if($line_info[$i] ne "./."){
						if (!($line_info[$i] =~ /(\d)\/(\d)/)){
							print "Define alternative code for genotype $line_info[$i]\n";
							exit;
						}
						
						my ($allele1,$allele2) = ($line_info[$i] =~ /(\d)\/(\d)/);
						$total_alleles +=2;
						if($allele1 == 1){
							$var_alleles++
						}
						if($allele2 == 1){
							$var_alleles++
						}
					}#end if($line_info[$i] ne "./.")}
				}#end foreach my $i (@pop_pos)
				
				if ($total_alleles == 0){
					print OUTPUTFILE "\tNA";
				}else{
					my $var_freq = $var_alleles / $total_alleles;
					print OUTPUTFILE "\t",sprintf("%.2f", $var_freq);
				}#end else 
			}#end foreach my $super_pop (@sorted_super_pop)
			
			print OUTPUTFILE "\n";
		}else{
			for (my $i = 9; $i < scalar(@line_info); $i++){
				my $sample = $line_info[$i];
				
				if(exists($sample_hash{$sample})){
					my $sample_pop = $sample_hash{$sample};
					my $sample_super_pop = $super_pop_hash{$sample_pop};
					if($sample_super_pop eq ""){
						print "Error finding super-population:\n";
						print "$sample_pop --> $sample_super_pop\n";
						exit;
					}
					
					my $pop_text = $pop_indices{$sample_pop};
					my $super_pop_text = $super_pop_indices{$sample_super_pop};
					
					if($pop_text eq ""){
						$pop_indices{$sample_pop}="$i";
					}else{
						$pop_indices{$sample_pop}="$pop_text,$i";
					}

					if($super_pop_text eq ""){
						$super_pop_indices{$sample_super_pop}="$i";
					}else{
						$super_pop_indices{$sample_super_pop}="$super_pop_text,$i";
					}
					
				}#end if(exists($sample_hash{$sample}))
			}#end for (my $i = 9; $i < scalar(@line_info): $i++)
			
			print OUTPUTFILE "CHR\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT";
			
			print "Total Super-Populations:\n";
			foreach my $super_pop (keys %super_pop_indices){
				my @pop_info = split(",",$super_pop_indices{$super_pop});
				print "$super_pop: ",scalar(@pop_info),"\n";
				push @sorted_super_pop,$super_pop;
			}#end foreach my $super_pop (keys %super_pop_indices)
			@sorted_super_pop = sort @sorted_super_pop;
			foreach my $super_pop (@sorted_super_pop){
				print OUTPUTFILE "\tSuperpop.$super_pop.freq";
			}#end foreach my $super_pop (@sorted_super_pop)
			
			print "Total Populations:\n";
				foreach my $pop (keys %pop_indices){
				my @pop_info = split(",",$pop_indices{$pop});
				
				if(scalar(@pop_info) > 20){
					print "$pop: ",scalar(@pop_info),"\n";
					push @sorted_pop,$pop;
				}#end if(scalar(@pop_info) > 20)
			}#end foreach my $super_pop (keys %super_pop_indices)
			@sorted_pop = sort @sorted_pop;
			foreach my $pop (@sorted_pop){
				print OUTPUTFILE "\tPop.$pop.freq";
			}#end foreach my $pop (@sorted_pop)

			print OUTPUTFILE "\n";
		}#end else
	}#end if (!($line =~ /^##/))
}#end while (<INPUTFILE>)
			
close(INPUTFILE);
close(OUTPUTFILE);

exit;