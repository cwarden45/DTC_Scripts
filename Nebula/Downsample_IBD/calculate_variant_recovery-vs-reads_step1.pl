use warnings;
use strict;
use diagnostics;

#copied and modified from https://github.com/cwarden45/DTC_Scripts/blob/master/Helix_Mayo_GeneGuide/IBD_Genetic_Distance/combine_VCF.pl'

## 92546 of 93938 SNPs differ from genome reference (seems high?)
#my $pileup_Individual = "../BWA_MEM.hg19.C50.pileup";
#my $VCF_var_list = "../../STITCH_Gencove/1000_genomes_20140502_plus_2-SNP-chip.vcf";
#my $outputfile = "variant_recovery-1000_genomes_20140502_plus_2-SNP-chip.txt";

# 3949111 of 3949415 SNPs differ from genome reference (this should be high - I am starting from a VCF rather than a gVCF)
my $pileup_Individual = "../BWA_MEM.hg19.C50.pileup";
my $VCF_var_list = "../../Veritas/hg19.gatk.GATK.HC.vcf";
my $outputfile = "variant_recovery-Veritas_WGS.txt";

#define positions to combine
my %individual_hash;

print "Find positions (and genotypes) from VCF\n";

my $var_count = 0;
my $snp_count = 0;
	
open(INPUTFILE, $VCF_var_list) || die("Could not open $VCF_var_list!");
while (<INPUTFILE>){
	my $line = $_;
	chomp $line;
	if (!($line =~ /^##/)){
		my @line_info = split("\t",$line);
		my $chr = $line_info[0];
		my $pos = $line_info[1];
		my $ref = $line_info[3];	
		my $alt = $line_info[4];
		my $geno_text = $line_info[scalar(@line_info)-1];#this is a heuristic that happens to work with both of the files that I provide.

		$chr =~ s/^chr//;

		#only check .pileup file for SNPs (not indels)
		if(!($line =~ /^#/) & (length($ref) == 1) & (length($alt) == 1)){			
			
			$snp_count++;

			my $prev_geno = substr($geno_text,0,3);
			if (($prev_geno eq "1/1") or ($prev_geno eq "1/0") or ($prev_geno eq "0/1")){
				$var_count++;
				
				my $varID = "$chr:$pos:$ref";
				$individual_hash{$varID}="$alt";
			}#end if (($prev_geno eq "1/1") or ($prev_geno eq "1/0") or ($prev_geno eq "0/1"))
		}#end if(!($line =~ /^#/) & (length($ref) == 1) & (length($alt) == 1))
	}#end if (!($line =~ /^##/))
	}#end while (<INPUTFILE>)
				
close(INPUTFILE);

print "$var_count / $snp_count SNPs vary from the reference!\n";

print "Reading individual .pileup file...\n";

open(OUTPUTFILE, ">$outputfile") || die("Could not open $outputfile!");
print OUTPUTFILE "Read.Count\tRecovered.Var\n";

my $read_count = 0;
my $recovered_count = 0;

open(INPUTFILE, $pileup_Individual) || die("Could not open $pileup_Individual!");
while (<INPUTFILE>){
	my $line = $_;
	chomp $line;

	my @line_info = split("\t",$line);
	my $chr = $line_info[0];
	my $pos = $line_info[1];
	my $ref = $line_info[2];	
	my $cov = int($line_info[3]);
	my $seq_text = $line_info[4];
	my $qual_text = $line_info[5];
	
	$chr =~ s/^chr//;
	
	my @read_counts = $seq_text =~ /\^/g;
	if (scalar(@read_counts) > 0){
		#print "$seq_text\n";
		$read_count += scalar(@read_counts);
		#exit;
	}#end if (scalar(@read_counts) > 0)
	
	my $posID = "$chr:$pos:$ref";
	
	if(exists($individual_hash{$posID})){
		my $test_var = $individual_hash{$posID};
		delete $individual_hash{$posID};
		my $new_posID = "$chr:$pos:$ref:$test_var";
		
		#filter deletions
		$seq_text =~ s/\+\d+\w+//g;
		#filter insertions
		$seq_text =~ s/\-\d+\w+//g;
		
		#create one symbol for reference matches
		$seq_text =~ s/,/./g;
		
		$seq_text = uc($seq_text);
		#I reminded myself of the syntax using https://stackoverflow.com/questions/1849329/is-there-a-perl-shortcut-to-count-the-number-of-matches-in-a-string
		my @count = $seq_text =~ /$test_var/g;
		if (scalar @count  > 0){
			$recovered_count++;
			print OUTPUTFILE "$read_count\t$recovered_count\n";
		}
	}#end if(exists($individual_hash{$posID}))
}#end while (<INPUTFILE>)
			
close(INPUTFILE);
close(OUTPUTFILE);

exit;