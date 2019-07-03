use warnings;
use strict;
use diagnostics;

my $subsample_ref = 20;
my $subsample_probe = 18; #18x reduction is 15,924 probes

my $threads = 4;
my $sample_name = "GFG";
my $SHAPEIT_chr_folder = "SHAPEIT_Ref$subsample_ref\_Probe$subsample_probe";
my $inputVCF="../Genes_for_Good/ALL.chip.omni_broad_sanger_combined.20140818.snps_frequencies_UNRELATED_plus_1child_PLUS_GFG_CW.vcf";

my @chr_long = ("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chr20","chr21","chr22","chrX_nonPAR");
my @chr_short = ("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X");

my $SHAPEIT_binary = "/opt/SHAPEIT/shapeit.v2.904.3.10.0-693.11.6.el7.x86_64/bin/shapeit";
my $plink_binary = "/opt/plink/plink2";

my $map_folder = "../genetic_map_files";

my $command = "mkdir $SHAPEIT_chr_folder";
system($command);

my %output_hash;

foreach my $VCF_chr (@chr_short){
	my $chr_VCF_out = "$SHAPEIT_chr_folder/chr$VCF_chr\_input.vcf";
	open($output_hash{$VCF_chr},"> $chr_VCF_out") || die("Could not open $chr_VCF_out!");
}#end foreach my $VCF_chr (@chr_short)

my $total_probe=0;

my $line_count=0;
open(INPUTFILE, $inputVCF) || die("Could not open $inputVCF!");
while (<INPUTFILE>){
	$line_count++;
	my $line = $_;
	chomp $line;

	my @line_info = split("\t",$line);
	my $chr = $line_info[0];
	my $pos = $line_info[1];
	my $id = $line_info[2];
	my $ref = $line_info[3];
	my $alt = $line_info[4];
	my $qual = $line_info[5];
	my $filter = $line_info[6];
	my $info = $line_info[7];
	my $format = $line_info[8];
	my $test_sample = $line_info[scalar(@line_info)-1];
	
	my $new_line = "$chr\t$pos\t$id\t$ref\t$alt\t$qual\t$filter\t$info\t$format";
	
	for (my $i=9; $i < scalar(@line_info)-1; $i++){
		if ($i % $subsample_ref == 0){
			$new_line = $new_line."\t$line_info[$i]";
		}#end if ($i % $subsample_ref == 0)
	}#end for (my $i=9; $i < scalar(@line_info)-1; $i++)
	
	$new_line = $new_line."\t$test_sample\n";

	if($line_count == 1){
		$new_line =~ s/CHR/CHROM/;
		foreach my $temp_chr (@chr_short){
			print {$output_hash{$temp_chr}} "#$new_line";
		}#end foreach my $temp_chr (@chr_short)
	}else{
		
		if(exists($output_hash{$chr}) and ($line_count % $subsample_probe == 0)){
			$total_probe++;
			print {$output_hash{$chr}} $new_line;
		}#end if(exists($output_hash{$chr}) and ($line_count % $subsample_probe == 0))
	}#end else
}#end while (<INPUTFILE>)
			
close(INPUTFILE);

###run slightly different commands for chrX

my $VCF_IN = "$SHAPEIT_chr_folder/chrX_input.vcf";
my $MAP = "$map_folder/genetic_map_chrX_nonPAR_combined_b37.txt";
	
my $IN_Prefix = "$SHAPEIT_chr_folder/chrX_input";
$command = "$plink_binary --vcf $VCF_IN --make-bed --out $IN_Prefix";
system($command);
	
my $OUT_Prefix = "$SHAPEIT_chr_folder/chrX_phased";
#add --chrX, as described in http://mathgen.stats.ox.ac.uk/genetics_software/shapeit/shapeit.html#chrX
$command = "$SHAPEIT_binary --input-bed $IN_Prefix.bed $IN_Prefix.bim $IN_Prefix.fam -M $MAP -O $OUT_Prefix --chrX --thread $threads --force";
system($command);
	
my $VCF_OUT = "$SHAPEIT_chr_folder/chrX_phased.vcf";
$command = "$SHAPEIT_binary -convert --input-haps $OUT_Prefix --output-vcf $VCF_OUT";
system($command);

###run similar code for autosomal chromosomes
for (my $i=0; $i < 22; $i++){
	$VCF_IN = "$SHAPEIT_chr_folder/chr".$chr_short[$i]."_input.vcf";
	$MAP = "$map_folder/genetic_map_".$chr_long[$i]."_combined_b37.txt";
	
	$IN_Prefix = "$SHAPEIT_chr_folder/chr".$chr_short[$i]."_input";
	$command = "$plink_binary --vcf $VCF_IN --make-bed --out $IN_Prefix";
	system($command);
	
	$OUT_Prefix = "$SHAPEIT_chr_folder/chr".$chr_short[$i]."_phased";
	$command = "$SHAPEIT_binary --input-bed $IN_Prefix.bed $IN_Prefix.bim $IN_Prefix.fam -M $MAP -O $OUT_Prefix --thread $threads --force";
	system($command);
	
	$VCF_OUT = "$SHAPEIT_chr_folder/chr".$chr_short[$i]."_phased.vcf";
	$command = "$SHAPEIT_binary -convert --input-haps $OUT_Prefix --output-vcf $VCF_OUT";
	system($command);
}#end for (my $i=0; $i < scalar(@chr_long); $i++)

print "Total Probes Kept: $total_probe\n";

exit;