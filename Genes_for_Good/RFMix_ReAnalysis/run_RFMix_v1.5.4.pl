use warnings;
use strict;
#use diagnostics;

my $random_seed = 190505;#date - earlier version doesn't explicity consider seed as parameter
#my $random_seed = 190511;#date

my $threads = 16;#I think they are expecting you to run multiple threads per core: I tested this with 8 core / 16 GB RAM without crashing instance (and could have been run locally, if I wasn't waiting for SHAPEIT phasing)
my $SHAPEIT_folder = "../Genes_for_Good/SHAPEIT";
my $genetic_map_folder = "../genetic_map_files";
my $test_sample_ID = "GFG";
my $test_gender_num = 1;#male
my $K1G_pheno_file = "../../23andMe/1000_Genomes/20140502_all_samples.ped";
my $super_pop_mapping_file = "../../23andMe/1000_Genomes/super-pop_mapping_for_Ogembo_QCarray_plus_CHD.txt";

my $output_folder = "../Genes_for_Good/RFMix_seed$random_seed";
my $sample_map_test = "../Genes_for_Good/test_sample_GFG_CW.txt";
my $sample_map_ref = "../sample_map_1000_Genomes_UNRELATED_plus_1_child.txt";

#assume running within RFMix_v1.5.4
my $RFMix_folder = ".";
my $command = "mkdir $output_folder";
system($command);

print "Create test sample map for file conversion\n";
open(OUT,"> $sample_map_test") || die("Could not open $sample_map_test!");
print OUT "$test_sample_ID\n";
close(OUT);

#preprocessing scripts from https://github.com/armartin/ancestry_pipeline
#assuming this is within the RFMix_v1.5.4 folder (and the script is being run from that folder)
my $Alicia_folder = "ancestry_pipeline";

#previous script only looked at autosomal chromosomes, but you could add in other chromosomes (if you previously processed them) this  way
my @chr_long = ("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chr20","chr21","chr22","chrX_nonPAR");
my @chr_short = ("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X");

print "Converting files and running RFMix\n";

for (my $i=0; $i < scalar(@chr_long); $i++){
	print "##### Working on chr$chr_short[$i] #####\n";
	##compress .haps file
	print "--> Compressing .haps file (for Alicia's script)...\n";
	my $haps_file = "$SHAPEIT_folder/chr$chr_short[$i]\_phased.haps";
	my $hapsGZ = "$SHAPEIT_folder/chr$chr_short[$i]\_phased.haps.gz";
	
	my $command = "gzip -c $haps_file > $hapsGZ";
	system($command);

	#create classes file from SHAPEIT output
	my $sample_file = "$SHAPEIT_folder/chr$chr_short[$i]\_phased.sample";
	my $classes_file = "$output_folder/RFMIX_in_chr$chr_short[$i].classes";
	create_classes_file($sample_file, $classes_file, $K1G_pheno_file, $super_pop_mapping_file, $test_sample_ID, $sample_map_ref);
	
	##previous RFMix version file conversion
	print "-->Convert SHAPEIT to RFMix format...\n";
	$command = "python $Alicia_folder/shapeit2rfmix.py --shapeit_hap_ref $hapsGZ --shapeit_hap_admixed $hapsGZ --shapeit_sample_ref $sample_file --shapeit_sample_admixed $sample_file --ref_keep $sample_map_ref --admixed_keep $sample_map_test --chr $chr_short[$i] --genetic_map $genetic_map_folder/genetic_map_$chr_long[$i]\_combined_b37.txt --out $output_folder/RFMIX_in";
	system($command);
	
	#create alternative alleles file
	print "-->I think I have the shapeit2rfmix.py input format messed up, so create new .alleles file...\n";
	my $allele_file = "$output_folder/RFMIX_in_chr$chr_short[$i].alleles";
	allele_conversion($haps_file,$allele_file);
	
	##Run RFMix
	print "-->Run RFMix\n";
	my $loc_file = "$output_folder/RFMIX_in_chr$chr_short[$i].snp_locations";
	my $RFmix_out = "$output_folder/chr$chr_short[$i].rfmix";

	#have to run code within RFMix directory
	#remove -e 2 -w 0.2 --use-reference-panels-in-EM: default parameters finished within a couple hours on 16 GB / 4 core computer, but I believe it was stuck on chr1 for 12+ hours with these added
	$command = "python $RFMix_folder/RunRFMix.py --num-threads $threads --forward-backward PopPhased $allele_file $classes_file $loc_file -o $RFmix_out";
	system($command);
}#end for (my $i=0; $i < scalar(@chr_long); $i++)

#skip plotting chrX
@chr_short = ("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22");
Viterbi2bed(\@chr_short,$output_folder,$test_sample_ID, $Alicia_folder);

exit;

sub Viterbi2bed{
	my ($arr_ref1, $outputfolder, $ID, $Alicia_folder) =@_;
	
	my @chr_short = @$arr_ref1;

	my $bedA = "$outputfolder/$ID\_A.bed";
	my $bedB = "$outputfolder/$ID\_B.bed";

	my %super_pop_hash;
	$super_pop_hash{1}="AFR";
	$super_pop_hash{2}="AMR";
	$super_pop_hash{3}="EAS";
	$super_pop_hash{4}="EUR";
	$super_pop_hash{5}="SAS";
	
	open(OUTA,"> $bedA") || die("Could not open $bedA!");
	open(OUTB,"> $bedB") || die("Could not open $bedB!");

	for (my $i=0; $i < scalar(@chr_short); $i++){
		print "##### Convering RFMix Output for chr$chr_short[$i] #####\n";
		my $map_file = "$output_folder/RFMIX_in_chr$chr_short[$i].map";
		my $RFmix_Viterbi = "$output_folder/chr$chr_short[$i].rfmix.0.Viterbi.txt";
		
		my $output_chr = $chr_short[$i];
		if($output_chr eq "X"){
			$output_chr=23;
		}
		
		my $A_start_pos = -1;
		my $A_start_cM = -1;
		my $A_start_Ancestry = "";
		
		my $B_start_pos = -1;
		my $B_start_cM = -1;
		my $B_start_Ancestry = "";

		my $prev_pos = -1;
		my $prev_cM = -1;
		
		my $temp_pos = -1;
		my $temp_cM = -1;
			
		open(MAP,"$map_file") || die("Could not open $map_file!");
		open(VIT,"$RFmix_Viterbi") || die("Could not open $RFmix_Viterbi!");
		
		#code base upon https://stackoverflow.com/questions/2498937/how-can-i-walk-through-two-files-simultaneously-in-perl
		while((my $line1 = <MAP>) and (my $line2 = <VIT>)){
			chomp $line1;
			chomp $line2;
			
			my @line_info1 = split(" ",$line1);
			$temp_pos = $line_info1[0];
			$temp_cM = $line_info1[1];
			my @line_info2 = split(" ",$line2);
			my $A_num = $line_info2[0];
			my $A_status = $super_pop_hash{$A_num};
			my $B_num = $line_info2[1];
			my $B_status = $super_pop_hash{$B_num};
			
			if($A_start_Ancestry eq ""){
				#initialize (or re-initialize) A values
				$A_start_pos=$temp_pos;
				$A_start_cM=$temp_cM;
				$A_start_Ancestry=$A_status;
			}elsif($B_start_Ancestry eq ""){
				#initialize (or re-initialize) B values
				$B_start_pos=$temp_pos;
				$B_start_cM=$temp_cM;
				$B_start_Ancestry=$B_status;
			}elsif($A_status ne $A_start_Ancestry){
				print OUTA "$output_chr\t$A_start_pos\t$prev_pos\t$A_start_Ancestry\t$A_start_cM\t$prev_cM\n";

				$A_start_pos = -1;
				$A_start_cM = -1;
				$A_start_Ancestry = "";
			}elsif($B_status ne $B_start_Ancestry){
				print OUTB "$output_chr\t$B_start_pos\t$prev_pos\t$B_start_Ancestry\t$B_start_cM\t$prev_cM\n";

				$B_start_pos = -1;
				$B_start_cM = -1;
				$B_start_Ancestry = "";
			}

			$prev_pos=$temp_pos;
			$prev_cM=$temp_cM;
		}#end while((my $line1 = <MAP>) and (my $line2 = <VIT>))

		close(MAP);
		close(VIT);
		
		print OUTA "$output_chr\t$A_start_pos\t$prev_pos\t$A_start_Ancestry\t$A_start_cM\t$prev_cM\n";
		print OUTB "$output_chr\t$B_start_pos\t$prev_pos\t$B_start_Ancestry\t$B_start_cM\t$prev_cM\n";
		
	}#end for (my $i=0; $i < scalar(@chr_long); $i++)

	close(OUTA);
	close(OUTB);

	print "Plotting Karyogram (based upon Alicia's script)\n";
	my $plotPNG = "$outputfolder/$ID.png";	
	my $command = "python $Alicia_folder/plot_karyogram.py --bed_a $bedA --bed_b $bedB --ind $ID --out $plotPNG --pop_order AFR,AMR,EAS,EUR,SAS --colors red,orange,green,blue,purple";
	system($command);
}#end def Viterbi2bed

sub allele_conversion
	{
		my ($inputfile, $outputfile) =@_;
		
		open(OUT,"> $outputfile") || die("Could not open $outputfile!");

		open(IN,"$inputfile") || die("Could not open $inputfile!");
		while (<IN>){
			my $line = $_;
			chomp $line;
			my @line_info = split(" ",$line);
			shift(@line_info);
			shift(@line_info);
			shift(@line_info);
			shift(@line_info);
			shift(@line_info);
			print OUT join("",@line_info),"\n";
		}#end while (<IN>)
		close(IN);
		close(OUT);
	}#end def allele_conversion
	
sub create_classes_file
	{
		my ($inputfile, $outputfile, $pop_file, $super_pop_file, $ADMIX_ID, $outputfile2) =@_;
		
		#create hash from ped
		my %ped_hash;

		open(IN,"$K1G_pheno_file") || die("Could not open $K1G_pheno_file!");
		my $line_count=0;
		while (<IN>){
			$line_count++;
			my $line = $_;
			chomp $line;
			if($line_count > 1){
				my @line_info = split("\t",$line);
				my $sample = $line_info[1];
				my $pop = $line_info[6];
				
				#print "$sample\n";
				$ped_hash{$sample}=$pop;
			}#end if($line_count > 1)
		}#end while (<IN>)
		close(IN);

		#create super-pop hash
		my %pop_hash;
		open(IN,"$super_pop_file") || die("Could not open $super_pop_file!");
		$line_count=0;
		while (<IN>){
			$line_count++;
			my $line = $_;
			chomp $line;
			if($line_count > 1){
				my @line_info = split("\t",$line);
				my $pop = $line_info[0];
				my $super_pop = $line_info[1];
				
				#print "$sample\n";
				$pop_hash{$pop}=$super_pop;
			}#end if($line_count > 1)
		}#end while (<IN>)
		close(IN);
		
		#convert .sample file to .classes file
		my %num_super_pop_hash;
		$num_super_pop_hash{"AFR"}=1;
		$num_super_pop_hash{"AMR"}=2;
		$num_super_pop_hash{"EAS"}=3;
		$num_super_pop_hash{"EUR"}=4;
		$num_super_pop_hash{"SAS"}=5;

		my $output_text="";

		open(OUT2,"> $outputfile2") || die("Could not open $outputfile2!");

		$line_count=0;
		open(IN,$inputfile) || die("Could not open $inputfile!");
		while (<IN>){
			my $line = $_;
			chomp $line;
			$line =~ s/\r//g;
			
			$line_count++;
			
			if($line_count > 2){
				my @line_info = split(" ",$line);
				my $sample = $line_info[1];
				
				my $temp_num = 0;
				
				if($sample eq $ADMIX_ID){
					#0 = admixed
					$temp_num = 0;
				}else{
					print OUT2 "$sample\n";
					#need to look up super-pop
					
					if(!exists($ped_hash{$sample})){
						print "Unable to map population for |$sample|!\n";
						exit;
					}
					my $pop = $ped_hash{$sample};

					if(!exists($pop_hash{$pop})){
						print "Unable to map super-pop for |$pop|!\n";
						exit;
					}
					my $super_pop = $pop_hash{$pop};
					
					if(exists($num_super_pop_hash{$super_pop})){
						$temp_num=$num_super_pop_hash{$super_pop};
					}else{
						print "Error with numeric conversion for |$super_pop|!\n";
						exit;
					}
				}#end else
				
				if($output_text eq ""){
					$output_text = "$temp_num\t$temp_num";
				}else{
					$output_text = "$output_text\t$temp_num\t$temp_num";
				}
			}#end if($line_count > 2)
		}#end while (<IN>)
		close(IN);
		close(OUT2);

		open(OUT,"> $outputfile") || die("Could not open $outputfile!");
		print OUT "$output_text\n";
		close(OUT);

	}#end def allele_conversion