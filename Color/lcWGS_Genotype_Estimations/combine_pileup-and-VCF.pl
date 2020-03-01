use warnings;
use strict;
use diagnostics;

#copied and modified from https://github.com/cwarden45/DTC_Scripts/blob/master/Helix_Mayo_GeneGuide/IBD_Genetic_Distance/combine_VCF.pl'

#my $individual_ID = "CDW";
#my $individual_gender = 1;#male
#my $sample_name = "Color.pileup";
#my $pileup_Individual = "../Color/BWA_MEM.hg19.C50.pileup";
#my $VCF_prev = "1000_genomes_20140502_plus_2-SNP-chip.vcf";
#my $VCF_Combined = "1000_genomes_20140502_plus_2-SNP-chip_plus_Color-BWA-MEM-lcWGS-pileup.vcf";
#my $prev_ped = "1000_genomes_20140502_plus_2-SNP-chip.ped";
#my $updated_ped = "1000_genomes_20140502_plus_2-SNP-chip_plus_Color-BWA-MEM-lcWGS-pileup.ped";

my $individual_ID = "CDW";
my $individual_gender = 1;#male
my $sample_name = "Nebula.full.pileup";
my $pileup_Individual = "../Nebula/BWA_MEM.hg19.C50.pileup";
my $VCF_prev = "1000_genomes_20140502_plus_2-SNP-chip.vcf";
my $VCF_Combined = "1000_genomes_20140502_plus_2-SNP-chip_plus_Nebula-BWA-MEM-lcWGS-pileup.vcf";
my $prev_ped = "1000_genomes_20140502_plus_2-SNP-chip.ped";
my $updated_ped = "1000_genomes_20140502_plus_2-SNP-chip_plus_Nebula-BWA-MEM-lcWGS-pileup.ped";


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

print "Find positions (and genotypes) from VCF\n";
	
open(INPUTFILE, $VCF_prev) || die("Could not open $VCF_prev!");
while (<INPUTFILE>){
	$line_count++;
	my $line = $_;
	chomp $line;
	if (!($line =~ /^##/)){
		my @line_info = split("\t",$line);
		my $chr = $line_info[0];
		my $pos = $line_info[1];
		my $ref = $line_info[3];	
		my $alt = $line_info[4];

		$chr =~ s/^chr//;

		#only check .pileup file for SNPs (not indels)
		if(!($line =~ /^#/) & (length($ref) == 1) & (length($alt) == 1)){			
			my $varID = "$chr:$pos:$ref";
			$individual_hash{$varID}="$alt";
		}#end if(!($line =~ /^#/) & (length($ref) == 1) & (length($alt) == 1))
	}#end if (!($line =~ /^##/))
	}#end while (<INPUTFILE>)
				
close(INPUTFILE);

print "Reading individual .pileup file...\n";

$line_count=0;

open(INPUTFILE, $pileup_Individual) || die("Could not open $pileup_Individual!");
while (<INPUTFILE>){
	$line_count++;
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
			$individual_hash{$new_posID} = "0/1";
			#print "Check $line for present variant: $test_var!\n";
			#print "$seq_text\n";
			#exit;
		}else{
			my @ref_count = $seq_text =~ /\./g;
			if (scalar @ref_count > 0.5 * $cov){
				$individual_hash{$new_posID} = "0/0";
			#print "Check $line for (mostly) reference sequence!\n";
			#print "$seq_text\n";
			#exit;
			}#end if (scalar @ref_count > 0.5 * $cov)
		}#end else
		
		###I am guessing this will be a lot less effective than the imputation strategies (which I believe estimate haplotype blocks rather than individual variants?), but I want to get some sense of what this looks like.
		###For example, it looks like I don't have any overlap at these positions for my Color FASTQ file?
	}#end if(exists($individual_hash{$posID}))
}#end while (<INPUTFILE>)
			
close(INPUTFILE);

#define indices to count, output allele frequencies

print "Reading and appending 1000 Genomes VCF...\n";

open(OUTPUTFILE, ">$VCF_Combined") || die("Could not open $VCF_Combined!");

my @output_indices;


open(INPUTFILE, $VCF_prev) || die("Could not open $VCF_prev!");
while (<INPUTFILE>){
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
				if($individual_hash{$varID} ne ""){
					my $extra_geno = $individual_hash{$varID};
					print OUTPUTFILE "$line\t$extra_geno\n";
				}#end if($individual_hash{$varID} ne "")
			}#end if(exists($sample_hash{$sample}))		
		}else{
			print OUTPUTFILE "$line\t$sample_name\n";
		}#end else
	}#end if (!($line =~ /^##/))
}#end while (<INPUTFILE>)
			
close(INPUTFILE);
close(OUTPUTFILE);

exit;