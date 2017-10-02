use warnings;
use strict;

my $min_tumor_pileup_freq = 0.20;
my $max_normal_pileup_freq = 0.05;
my $min_coverage = 10;
my $samtools = "samtools";

my @muTectVCF = ("Somatic_[compID].mutect2.vcf");
my @tumorBam = ("/path/to/[sampleID].nodup.bam");
my @normalBam = ("/path/to/[sampleID].nodup.bam");
my $refFa = "/path/to/ref.fa";

for (my $i=0; $i<scalar(@muTectVCF); $i++){
	print "Processing $muTectVCF[$i]\n";
	my $filteredVCF = $muTectVCF[$i];
	$filteredVCF =~ s/.vcf$/.filtered.vcf/;
	
	my $tempPileup = "muTect.combined.pileup";
	my $command = "samtools mpileup -C50 -f $refFa -l $muTectVCF[$i] $tumorBam[$i] $normalBam[$i] > $tempPileup";
	system($command);
	
	my %pileup_hash;
	
	open(PILEIN,$tempPileup)||die("Cannot open $tempPileup\n");
	while(<PILEIN>){
		my $line=$_;
		chomp $line;
		$line =~ s/\r//g;
		$line =~ s/\n//g;
		
		my @line_info = split("\t",$line);
		my $pileup_key = $line_info[0].":".$line_info[1];
		
		$pileup_hash{$pileup_key}=$line
	}#end while(<PILEIN>)
	close(PILEIN);
	
	open(VCFOUT,"> $filteredVCF")||die("Cannot open $filteredVCF\n");
	open(VCFIN,$muTectVCF[$i])||die("Cannot open $muTectVCF[$i]\n");
	while(<VCFIN>){
		my $line=$_;
		chomp $line;
		$line =~ s/\r//g;
		$line =~ s/\n//g;
		
		if($line =~ /^#/){
			print VCFOUT "$line\n";
		}else{
			my @line_info = split("\t",$line);
			my $var_chr = $line_info[0];
			my $var_pos = $line_info[1];
			my $ref_seq = $line_info[3];
			my $var_seq = $line_info[4];
			my $var_status = $line_info[6];
			
			if($var_status eq "PASS"){
				my $var_key = "$var_chr:$var_pos";
				
				if(exists($pileup_hash{$var_key})){
					my $pileup_text = $pileup_hash{$var_key};
					my @pileup_info = split("\t", $pileup_text);
					
					my $tumor_cov = $pileup_info[3];
					my $tumor_text = uc($pileup_info[4]);

					my $normal_cov = $pileup_info[6];
					my $normal_text = uc($pileup_info[7]);
					
					if($var_seq =~ /,/){
						print "Need to add code for checking complex variant: $ref_seq --> $var_seq\n"
					}else{
						#one variant at position
						
						my $tumor_frequency = 0;
						my $normal_frequency = 1;
						
						if((length($ref_seq) == 1)*(length($var_seq) == 1)){
							#SNP
							
							#tumor frequency
							#clear insertions
							$tumor_text =~ s/\\+\\d+\\w+//g;
							#clear deletions
							$tumor_text =~ s/-\\d+\\w+//g;
							my @tumor_hits = $tumor_text =~ /$var_seq/g;
							$tumor_frequency = scalar(@tumor_hits) / $tumor_cov;
							
							#normal frequency
							#clear insertions
							$normal_text =~ s/\\+\\d+\\w+//g;
							#clear deletions
							$normal_text =~ s/-\\d+\\w+//g;
							my @normal_hits = $normal_text =~ /$var_seq/g;
							$normal_frequency = scalar(@normal_hits) / $normal_cov;
						}elsif(length($var_seq) > length($ref_seq)){
							#insertion
							my $ins_nucs = $var_seq;
							$ins_nucs =~ s/^$ref_seq//g;
							my $insertion_match = "\\+\\d+$ins_nucs";

							#tumor frequency
							my @tumor_hits = $tumor_text =~ /$insertion_match/g;
							$tumor_frequency = scalar(@tumor_hits) / $tumor_cov;
							
							#normal frequency
							my @normal_hits = $normal_text =~ /$insertion_match/g;
							$normal_frequency = scalar(@normal_hits) / $normal_cov;						
						}elsif(length($ref_seq) > length($var_seq)){
							#deletion
							my $del_nucs = $ref_seq;
							$del_nucs =~ s/^$var_seq//g;
							my $deletion_match = "-\\d+$del_nucs";

							#tumor frequency
							my @tumor_hits = $tumor_text =~ /$deletion_match/g;
							$tumor_frequency = scalar(@tumor_hits) / $tumor_cov;
							
							#normal frequency
							my @normal_hits = $normal_text =~ /$deletion_match/g;
							$normal_frequency = scalar(@normal_hits) / $normal_cov;
						}else{
							die("Define rule for Ref:$ref_seq, Var:$var_seq\n")
						}
						
						if(($tumor_frequency >= $min_tumor_pileup_freq)&&($normal_frequency <= $max_normal_pileup_freq)&&($tumor_cov >= $min_coverage)&&($normal_cov >= $min_coverage)){
							print VCFOUT "$line\n";
						}
					}#end else
				}#end if(exists($pileup_hash{$var_key}))
			}#end if($var_status eq "PASS")
		}#end else
	}#end while(<PILEIN>)
	close(VCFIN);
	close(VCFOUT);

	$command = "rm $tempPileup";
	system($command);
}#end for (my $i=0; $i<scalar(@muTectVCF); $i++)