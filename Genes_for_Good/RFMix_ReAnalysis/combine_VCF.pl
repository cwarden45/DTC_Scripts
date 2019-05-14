use warnings;
use strict;
use diagnostics;

#my $sample_name = "GFG";
#my $VCF_Individual = "GFG_filtered_unphased_genotypes.vcf";
#my $VCF_Combined = "ALL.chip.omni_broad_sanger_combined.20140818.snps_frequencies_UNRELATED_plus_1child_PLUS_GFG_CW.vcf";
#my $sample_file = "sample_map_1000_Genomes_UNRELATED_plus_1_child_GFG_CW.txt";

my $sample_name = "CW23";
my $VCF_Individual = "23andMe.vcf";
my $VCF_Combined = "ALL.chip.omni_broad_sanger_combined.20140818.snps_frequencies_UNRELATED_plus_1child_PLUS_23andMe_CW.vcf";
my $sample_file = "sample_map_1000_Genomes_UNRELATED_plus_1_child_23andMe_CW.txt";


#from ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/release/20130502/supporting/hd_genotype_chip/ALL.chip.omni_broad_sanger_combined.20140818.snps.genotypes.vcf
my $VCF_1KG = "ALL.chip.omni_broad_sanger_combined.20140818.snps.genotypes.vcf";

#only consider children and unrelated individuals
#from ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/working/20140502_sample_summary_info/
my $family_mapping = "20140502_all_samples.ped";

#from https://github.com/cwarden45/QCarray_Ethnicity (from http://www.internationalgenome.org/category/population/)
my $super_pop_mapping = "super-pop_mapping_for_Ogembo_QCarray_plus_CHD.txt";

#largely derived from https://github.com/cwarden45/DTC_Scripts/tree/master/23andMe/Ancestry_plus_1000_Genomes/calculate_vcf_frequencies.pl

#define population to super-population hash
my %super_pop_hash;

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
	}#end if($line_count > 1)
}#end while (<INPUTFILE>)
			
close(INPUTFILE);


#define individuals to consider, and define individual-to-population hash
my %sample_hash;

open(OUTPUTFILE, ">$sample_file") || die("Could not open $sample_file!");

$line_count=0;
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
		
		my $super_pop = "";
		if(exists($super_pop_hash{$pop})){
			$super_pop = $super_pop_hash{$pop};
		}else{
			print "Difficulty mapping super-population for $pop!\n";
			exit;
		}
		
		if ($rela eq "unrel"){
			$sample_hash{$ID}=$pop;
			print OUTPUTFILE "$ID\t$super_pop\n";
		}elsif(($rela eq "Child")|($rela eq "child")|($rela eq "daughter")){
			$sample_hash{$ID}=$pop;
			print OUTPUTFILE "$ID\t$super_pop\n";
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

print OUTPUTFILE "^$sample_name\tunknown\n";

close(OUTPUTFILE);


#define positions to combine
my %individual_hash;

print "Reading individual VCF...\n";

$line_count=0;
open(INPUTFILE, $VCF_Individual) || die("Could not open $VCF_Individual!");
while (<INPUTFILE>){
	$line_count++;
	my $line = $_;
	chomp $line;


	if(!($line =~ /^#/)){
		#print "$line\n";

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
		my $geno = $line_info[9];
		
		if($filter eq "PASS"){
			my $varID = "$chr:$pos:$ref:$alt";
			#print "$varID\n";
			$individual_hash{$varID}=$geno;
		}#end if($filter eq "PASS")
	}#end if(!($line =~ /^#/))
}#end while (<INPUTFILE>)
			
close(INPUTFILE);

#define indices to count, output allele frequencies

print "Reading and appending 1000 Genomes VCF...\n";

open(OUTPUTFILE, ">$VCF_Combined") || die("Could not open $VCF_Combined!");

my @output_indices;

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
			my $varID = "$chr:$pos:$ref:$alt";
			
			if(exists($individual_hash{$varID})){
				my $extra_geno = $individual_hash{$varID};
				print OUTPUTFILE "$chr\t$pos\t$ID\t$ref\t$alt\t$qual\t$filter\t$info\t$format";			

				foreach my $i_out (@output_indices){
					print OUTPUTFILE "\t".$line_info[$i_out];
				}#end foreach my $super_pop (keys %super_pop_indices)
				
				print OUTPUTFILE "\t$extra_geno\n";
			}#end if(exists($sample_hash{$sample}))		
		}else{
			for (my $i = 9; $i < scalar(@line_info); $i++){
				my $sample = $line_info[$i];
				
				if(exists($sample_hash{$sample})){
					push(@output_indices,$i);
				}#end if(exists($sample_hash{$sample}))
			}#end for (my $i = 9; $i < scalar(@line_info): $i++)
			
			print OUTPUTFILE "CHR\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT";
			
			foreach my $i_out (@output_indices){
				print OUTPUTFILE "\t".$line_info[$i_out];
			}#end foreach my $super_pop (keys %super_pop_indices)

			print OUTPUTFILE "\t$sample_name\n";
		}#end else
	}#end if (!($line =~ /^##/))
}#end while (<INPUTFILE>)
			
close(INPUTFILE);
close(OUTPUTFILE);

exit;