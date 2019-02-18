use warnings;
use strict;
use diagnostics;

my $NatGeo_Geno_input_file = "../Genetic.csv";
my $UCSC_dbSNP_mapping_file = "../snp138.txt";
my $dbSNP_converted_23andMe_format_output_file = "../Geno2.0_23andMe_format.txt";

#define dbSNP hash
print "Creating dbSNP hash...\n";
my %dbSNP_hash;

open(INPUTFILE, $UCSC_dbSNP_mapping_file) || die("Could not open $UCSC_dbSNP_mapping_file!");
while (<INPUTFILE>){
	my $line = $_;
	chomp $line;
	my @line_info = split("\t",$line);
	my $chr = $line_info[1];
	$chr =~ s/chr//;#23andMe format excludes "chr";
	my $pos = $line_info[3];#visually checked first variant; it was actually at 2nd position
	my $rsID = $line_info[4];
	##confirmed trend was the same for 1st SNP on reverse strand
	#my $strand = $line_info[6];
	#if($strand eq "-"){
	#	print "$line\n";
	#	print "$chr:$pos:$rsID\n";
	#	exit;
	#}
	
	$dbSNP_hash{$rsID}="$chr\t$pos";
	
	if($chr eq "2"){
		last;
	}
}#end while (<INPUTFILE>)

close(INPUTFILE);

#convert lines with dbSNP hits
print "Reformatting Geno 2.0 file...\n";
open(OUTPUTFILE, ">$dbSNP_converted_23andMe_format_output_file") || die("Could not open $dbSNP_converted_23andMe_format_output_file!");

open(INPUTFILE, $NatGeo_Geno_input_file) || die("Could not open $NatGeo_Geno_input_file!");
while (<INPUTFILE>){
	my $line = $_;
	chomp $line;
	my @line_info = split(",",$line);
	if(scalar(@line_info) == 4){
		my $varID = $line_info[0];
		my $chr = $line_info[1];
		my $allele1 = $line_info[2];
		my $allele2 = $line_info[3];
		if(exists($dbSNP_hash{$varID})){
			my $pos_info = $dbSNP_hash{$varID};
			if($pos_info =~ $pos_info){
				print OUTPUTFILE "$varID\t$pos_info\t$allele1$allele2\n";
			}else{
				print "Chromosome discrepancy for $varID:\n";
				print "Geno 2.0 Info: $line\n";
				print "UCSC dbSNP Info: $pos_info\n";
				#exit;
			}
		}#end if(exists($dbSNP_hash{$varID}))
	}#end if(scalar(@line_info) == 4)
}#end while (<INPUTFILE>)

close(INPUTFILE);
close(OUTPUTFILE);

exit;