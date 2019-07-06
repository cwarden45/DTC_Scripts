use warnings;
use strict;
use diagnostics;

#copied and modified from https://github.com/cwarden45/DTC_Scripts/blob/master/Genes_for_Good/RFMix_ReAnalysis/combine_VCF.pl

#my $individual_ID = "CDW";
#my $individual_gender = 1;#male
#my $sample_name = "GFG";
#my $VCF_Individual = "GFG_filtered_unphased_genotypes.vcf";
#my $VCF_prev = "../RFMix_Ancestry/ALL.chip.omni_broad_sanger_combined.20140818.snps.genotypes.vcf";#from ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/release/20130502/supporting/hd_genotype_chip/ALL.chip.omni_broad_sanger_combined.20140818.snps.genotypes.vcf
#my $VCF_Combined = "1000_genomes_20140502_plus_GFG.vcf";
#my $prev_ped = "../RFMix_Ancestry/20140502_all_samples.ped";#from ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/working/20140502_sample_summary_info/
#my $updated_ped = "1000_genomes_20140502_plus_GFG.ped";
#my $GATK4_flag = 0;

#my $individual_ID = "CDW";
#my $individual_gender = 1;#male
#my $sample_name = "CW23";
#my $VCF_Individual = "23andMe.vcf";
#my $VCF_prev = "1000_genomes_20140502_plus_GFG.vcf";
#my $VCF_Combined = "1000_genomes_20140502_plus_2-SNP-chip.vcf";
#my $prev_ped = "1000_genomes_20140502_plus_GFG.ped";
#my $updated_ped = "1000_genomes_20140502_plus_2-SNP-chip.ped";
#my $GATK4_flag = 0;

my $individual_ID = "CDW";
my $individual_gender = 1;#male
my $sample_name = "Veritas.BWA";
my $VCF_Individual = "../BWA_MEM_Alignment/hg19.gatk.flagged.gVCF";
my $VCF_prev = "1000_genomes_20140502_plus_2-SNP-chip.vcf";
my $VCF_Combined = "1000_genomes_20140502_plus_2-SNP-chip_plus_Veritas.vcf";
my $prev_ped = "1000_genomes_20140502_plus_2-SNP-chip.ped";
my $updated_ped = "1000_genomes_20140502_plus_2-SNP-chip_plus_Veritas.ped";
my $GATK4_flag = 1;

#add row at bottom of .ped file

open(OUTPUTFILE, ">$updated_ped") || die("Could not open $updated_ped!");

my $line_count=0;
open(INPUTFILE, $prev_ped) || die("Could not open $prev_ped!");
while (<INPUTFILE>){
	$line_count++;
	my $line = $_;
	chomp $line;
	if($line_count > 1){
		my @line_info = split("\t",$line);
		my $familyID = $line_info[0];
		my $sampleID = $line_info[1];
		my $patID = $line_info[2];
		my $matID = $line_info[3];
		my $gender = $line_info[4];
		my $phenotype = -9;

		print OUTPUTFILE "$familyID\t$sampleID\t$patID\t$matID\t$gender\t$phenotype\n";

	}#end if($line_count > 1)
}#end while (<INPUTFILE>)
			
close(INPUTFILE);

print OUTPUTFILE "$individual_ID\t$sample_name\t0\t0\t$individual_gender\t-9\n";

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
		
		$chr =~ s/^chr//;
		
		if($GATK4_flag == 1){
		
			if($alt eq "<NON_REF>"){
				$alt = $ref;
			}else{
				$alt =~ s/,<NON_REF>//;
			}
			
			$geno = substr($line_info[9],0,3);
		}#end if(($GATK4_flag == 1)&($alt eq "<NON_REF>"))
		
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

open(INPUTFILE, $VCF_prev) || die("Could not open $VCF_prev!");
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

		$chr =~ s/^chr//;

		if(!($line =~ /^#/)){			
			my $varID = "$chr:$pos:$ref:$alt";
			
			if(exists($individual_hash{$varID})){
				my $extra_geno = $individual_hash{$varID};
				print OUTPUTFILE "$line\t$extra_geno\n";
			}#end if(exists($sample_hash{$sample}))		
		}else{
			print OUTPUTFILE "$line\t$sample_name\n";
		}#end else
	}#end if (!($line =~ /^##/))
}#end while (<INPUTFILE>)
			
close(INPUTFILE);
close(OUTPUTFILE);

exit;