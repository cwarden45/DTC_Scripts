my $inputVCF = "../23andMe.vcf";

#use population frequncy table calculated from ALL.chip.omni_broad_sanger_combined.20140818.snps_frequencies_UNRELATED_plus_1child.txt.vcf
my $pop_freq = "ALL.chip.omni_broad_sanger_combined.20140818.snps_frequencies_UNRELATED_plus_1child.txt";
my $outputTXT = "cwarden_example_1000_Genomes_Omni-combined_UNRELATED_plus_1child_frequencies.txt";

open(OUTPUTFILE, ">$outputTXT") || die("Could not open $outputTXT!");

#define population frequency hash
#only use CHR, POS, REF, ALT in mapping
print "Creating 1000 Genomes Mappings\n";
my %pop_hash;

my $line_count=0;
open(INPUTFILE, $pop_freq) || die("Could not open $pop_freq!");
while (<INPUTFILE>){
	$line_count++;
	my $line = $_;
	chomp $line;
	my @line_info = split("\t",$line);
	my $chr = shift(@line_info);
	my $pos = shift(@line_info);
	my $ID = shift(@line_info);
	my $ref = shift(@line_info);
	my $alt = shift(@line_info);
	my $qual = shift(@line_info);
	my $filter = shift(@line_info);
	my $info = shift(@line_info);
	my $format = shift(@line_info);

	my $varID = "chr$chr\t$pos\t$ref\t$alt";

	my $text = "$qual\t$filter\t$info\t".join("\t",@line_info);
	
	if($line_count == 1){
		print OUTPUTFILE "CHR\tPOS\tID\tREF\tALT\tQUAL.1KG\tFILTER.1KG\tINFO.1KG\t".join("\t",@line_info)."\n";
	}else{
		$pop_hash{$varID}=$text;
	}#end if($line_count > 1)
}#end while (<INPUTFILE>)
			
close(INPUTFILE);

#output variants present in vcf file
#-->skip "repeat" variants (only output "PASS" variants) and those with genotype of "0/0"

print "Parsing PASS variants present in VCF\n";

my $line_count=0;
open(INPUTFILE, $inputVCF) || die("Could not open $inputVCF!");
while (<INPUTFILE>){
	$line_count++;
	my $line = $_;
	chomp $line;
	if($line_count > 1){
		my @line_info = split("\t",$line);
		my $chr = $line_info[0];
		my $pos = $line_info[1];
		my $ID = $line_info[2];
		my $ref = $line_info[3];
		my $alt = $line_info[4];

		my $filter = $line_info[6];


		my $geno = $line_info[9];

		my $varID = "$chr\t$pos\t$ref\t$alt";
		
		if(($filter eq "PASS")&(($geno eq "1/1")|($geno eq "0/1")|($geno eq "1/0"))){
			if(exists($pop_hash{$varID})){
				print OUTPUTFILE "$chr\t$pos\t$ID\t$ref\t$alt\t".$pop_hash{$varID}."\n";
			}#end if(exists($pop_hash{$varID}))
		}#end if(($filter eq "PASS")&(($geno eq "1/1")|($geno eq "0/1")|($geno eq "1/0")))
	}#end if($line_count > 1)
}#end while (<INPUTFILE>)
			
close(INPUTFILE);
close(OUTPUTFILE);

exit;