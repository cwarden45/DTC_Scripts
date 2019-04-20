use warnings;
use strict;
use diagnostics;

#I compress file afterwards (so, don't put ".gz" in the output file name)

#my $test_flag = "PASS";
#my $inputVCF = "82651510240740_annotated.vcf";
#my $outputVCF = "82651510240740_annotated_precisionFDA.vcf";

#my $test_flag = "PASS";
my $inputVCF = "K33YDXX.vcf";
my $outputVCF = "K33YDXX_precisionFDA.vcf";

print "Reformatting VCF\n";

open(OUTPUTFILE, "> $outputVCF") || die("Could not open $outputVCF!");
	
open(INPUTFILE, $inputVCF) || die("Could not open $inputVCF!");
while (<INPUTFILE>){
	my $line = $_;
	chomp $line;
	$line =~ s/\r//g;
	$line =~ s/\n//g;
	
	my @lineInfo = split("\t",$line);
	
	if ($line =~ /^##/){
		print OUTPUTFILE "$line\n";
	}elsif ($line =~ /^#/){
		#Veritas WGS incorrectly had an extra sample name in the header (so, remove that)
		while(scalar(@lineInfo) > 10){
			pop(@lineInfo);
		}#end while(scalar(@lineInfo) > 10)
		print OUTPUTFILE join("\t",@lineInfo),"\n";
	}else{
		my $chr = $lineInfo[0];
		my $pos = $lineInfo[1];
		my $varID = $lineInfo[2];
		my $ref = uc($lineInfo[3]);
		my $var = uc($lineInfo[4]);
		my $flag = $lineInfo[6];
		my $format_text = $lineInfo[8];
		my $geno_text = $lineInfo[9];
		
		if($flag eq $test_flag){
			#Genos provided .vcf with some other rows
			#hopefully, this works with .vcf files from all programs: otherwise, perhaps need to modify code (or set $test_flag to ".")
			
			if($chr eq "chrM"){
				$chr = "MT";
			}#end if($chr eq "chrM")
			if ($chr =~ /^chr/){
				$chr =~ s/^chr//;
			}#end if ($chr =~ /^chr/)
			$lineInfo[0] =  $chr;

			#delete if you can't actually have complex variants
			print OUTPUTFILE join("\t",@lineInfo),"\n";

			#if (!($var =~ /,/)){
			#	#I thought I needed to filter out complex variants - I got an error message when I tried to use https://platform.dnanexus.com/login?scope=%7B%22full%22%3A+true%7D&redirect_uri=https%3A%2F%2Fprecision.fda.gov%2Freturn_from_login&client_id=precision_fda_gov (with .bed file for RefSeq CDS regions)
			#	#this ended up not being the case, but I left this code so that additional filters could potentially be added (if desired)
			#	print OUTPUTFILE join("\t",@lineInfo),"\n";
			#}else{
			#	print "Filter complex variant -  ref: $ref, var: $var\n";
			#}#end else

		}#end if($flag eq "PASS")
	}#end if (!($line =~ /^#/))
}#end while (<INPUTFILE>)
close(INPUTFILE);
close(OUTPUTFILE);

print "Compressing VCF\n";
my $command = "gzip $outputVCF";
system($command);

exit;
