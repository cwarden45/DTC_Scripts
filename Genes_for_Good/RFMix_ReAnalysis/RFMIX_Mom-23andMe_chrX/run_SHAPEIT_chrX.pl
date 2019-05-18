use warnings;
use strict;
use diagnostics;

my $threads = 4;
my $sample_name = "MOM";
my $SHAPEIT_chr_folder = "SHAPEIT";
my $inputVCF="ALL.chip.omni_broad_sanger_combined.20140818.snps_frequencies_UNRELATED_plus_1child_PLUS_23andMe_MOM.vcf";

my @chr_long = ("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chr20","chr21","chr22","chrX_nonPAR");
my @chr_short = ("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X");

my $SHAPEIT_binary = "/opt/SHAPEIT/shapeit.v2.904.3.10.0-693.11.6.el7.x86_64/bin/shapeit";
my $plink_binary = "/opt/plink/plink2";

my $map_folder = "../../../RFMix/genetic_map_files";

my %output_hash;

foreach my $VCF_chr (@chr_short){
	my $chr_VCF_out = "$SHAPEIT_chr_folder/chr$VCF_chr\_input.vcf";
	open($output_hash{$VCF_chr},"> $chr_VCF_out") || die("Could not open $chr_VCF_out!");
}#end foreach my $VCF_chr (@chr_short)

my $line_count=0;
open(INPUTFILE, $inputVCF) || die("Could not open $inputVCF!");
while (<INPUTFILE>){
	$line_count++;
	my $line = $_;

	if($line_count == 1){
		$line =~ s/CHR/CHROM/;
		foreach my $temp_chr (@chr_short){
			print {$output_hash{$temp_chr}} "#$line";
		}#end foreach my $temp_chr (@chr_short)
	}else{
		my @line_info = split("\t",$line);
		my $chr = $line_info[0];
		
		if(exists($output_hash{$chr})){
			print {$output_hash{$chr}} $line;
		}#end if(exists($output_hash{$chr}))
	}#end else
}#end while (<INPUTFILE>)
			
close(INPUTFILE);

#also run plink and SHAPEIT

my $VCF_IN = "$SHAPEIT_chr_folder/chrX_input.vcf";
my $MAP = "$map_folder/genetic_map_chrX_nonPAR_combined_b37.txt";
	
my $IN_Prefix = "$SHAPEIT_chr_folder/chrX_input";
my $command = "$plink_binary --vcf $VCF_IN --make-bed --out $IN_Prefix";
system($command);
	
my $OUT_Prefix = "$SHAPEIT_chr_folder/chrX_phased";
#add --chrX, as described in http://mathgen.stats.ox.ac.uk/genetics_software/shapeit/shapeit.html#chrX
$command = "$SHAPEIT_binary --input-bed $IN_Prefix.bed $IN_Prefix.bim $IN_Prefix.fam -M $MAP -O $OUT_Prefix --chrX --thread $threads --force";
system($command);
	
my $VCF_OUT = "$SHAPEIT_chr_folder/chrX_phased.vcf";
$command = "$SHAPEIT_binary -convert --input-haps $OUT_Prefix --output-vcf $VCF_OUT";
system($command);

exit;