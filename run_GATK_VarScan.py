import sys
import re
import os
from Bio import SeqIO

bam= "veritas_wgs.filter.rg.bam"
ref = "hg19.fasta"
javaMem = "4g"
gatkFlag="1"
varscanFlag = "1"

for arg in sys.argv:
	bamResult = re.search("^--bam=(.*)",arg)
	refResult = re.search("^--ref=(.*)",arg)
	memResult = re.search("^--mem=(.*)",arg)
	gatkResult = re.search("^--gatk=(.*)",arg)
	varscanResult = re.search("^--varscan=(.*)",arg)
	helpResult = re.search("^--help",arg)
	
	if bamResult:
		bam = bamResult.group(1)

	if refResult:
		ref = refResult.group(1)
		
	if memResult:
		javaMem = memResult.group(1)

	if gatkResult:
		gatkFlag = gatkResult.group(1)
		
	if varscanResult:
		varscanFlag = varscanResult.group(1)
		
	if helpResult:
		print "Usage: python run_GATK_VarScan.py --bam=veritas_wgs.filter.rg.bam --ref=hg19.fasta --mem=4g\n"
		print "--bam : Karyotype-Ordered (for GATK), sorted .bam file with read groups (and duplicates removed)\n"
		print "--ref : FASTA reference\n"
		print "--mem : Memory to be used by GATK, VarScan, and Picard\n"
		print "--gatk : Run GATK? (1=yes, 0=no)\n"
		print "--varscan : Run GATK? (1=yes, 0=no)\n"
		sys.exit()

#GATK ref order/format code
if (bam == "veritas_wgs.filter.rg.bam") and (ref == "hg19.fasta"):
	#FYI, it's faster to download the GATK ucsc hg19 ref: https://software.broadinstitute.org/gatk/download/bundle
	print "Creating Karyotype-Sored Reference for GATK"

	#can't use all chromosomes - get error that chrUn_gl000249 has different length in header versus ref (and supplemental chromosome alignmetns aren't provided)
	#chrOrder =  ["chrM","chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chr20","chr21","chr22","chrX","chrY","chr1_gl000191_random","chr1_gl000192_random","chr4_ctg9_hap1","chr4_gl000193_random","chr4_gl000194_random","chr6_apd_hap1","chr6_cox_hap2","chr6_dbb_hap3","chr6_mann_hap4","chr6_mcf_hap5","chr6_qbl_hap6","chr6_ssto_hap7","chr7_gl000195_random","chr8_gl000196_random","chr8_gl000197_random","chr9_gl000198_random","chr9_gl000199_random","chr9_gl000200_random","chr9_gl000201_random","chr11_gl000202_random","chr17_ctg5_hap1","chr17_gl000203_random","chr17_gl000204_random","chr17_gl000205_random","chr17_gl000206_random","chr18_gl000207_random","chr19_gl000208_random","chr19_gl000209_random","chr21_gl000210_random","chrUn_gl000211","chrUn_gl000212","chrUn_gl000213","chrUn_gl000214","chrUn_gl000215","chrUn_gl000216","chrUn_gl000217","chrUn_gl000218","chrUn_gl000219","chrUn_gl000220","chrUn_gl000221","chrUn_gl000222","chrUn_gl000223","chrUn_gl000224","chrUn_gl000225","chrUn_gl000226","chrUn_gl000227","chrUn_gl000228","chrUn_gl000229","chrUn_gl000230","chrUn_gl000231","chrUn_gl000232","chrUn_gl000233","chrUn_gl000234","chrUn_gl000235","chrUn_gl000236","chrUn_gl000237","chrUn_gl000238","chrUn_gl000239","chrUn_gl000240","chrUn_gl000241","chrUn_gl000242","chrUn_gl000243","chrUn_gl000244","chrUn_gl000245","chrUn_gl000246","chrUn_gl000247","chrUn_gl000248","chrUn_gl000249"]	
	
	#so, use canonical chromosomes and give .bam file new header
	chrOrder = ["chrM","chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chr20","chr21","chr22","chrX","chrY"]
	
	newRef = "hg19.karyotype.fasta"
	outHandle = open(newRef, 'w')
	
	for chr in chrOrder:
		print "Looking for " + chr
		fasta_sequences = SeqIO.parse(open(ref),'fasta')
		for fasta in fasta_sequences:
			chrName = fasta.id
			chrSequence = str(fasta.seq)
			
			if chrName == chr:
				print "match found"
				text = ">" + chr + "\n"
				text = text + chrSequence + "\n"
				outHandle.write(text)

	ref = newRef
	command = "/opt/samtools-1.3/samtools faidx " + ref
	os.system(command)

	oldHeader = "old.header"
	command = "/opt/samtools-1.3/samtools view -H " + bam + " > " + oldHeader
	os.system(command)
	
	inHandle = open(oldHeader)
	lines = inHandle.readlines()
				
	newHeader = "new.header"
	outHandle = open(newHeader, 'w')
	
	for line in lines:
		lineInfo = line.split("\t")
		seqResult = re.search("@SQ",line)
		
		if seqResult:
			suppResult = re.search("_",lineInfo[1])
			if not suppResult:
				outHandle.write(line)
		else:
			outHandle.write(line)
	inHandle.close()
	outHandle.close()
	
	command = "rm "+ oldHeader
	os.system(command)
	
	tempBam = "readheader.bam"
	command = "/opt/samtools-1.3/samtools reheader " + newHeader + " " + bam + " > " + tempBam
	os.system(command)
	
	command = "rm "+ newHeader
	os.system(command)
	
	refDict = 	re.sub(".fasta$",".dict",ref)
	command = "java -jar -Xmx" +javaMem+ " /opt/picard-tools-2.5.0/picard.jar CreateSequenceDictionary R=" + ref + " O=" + refDict
	os.system(command)
	
	gatkBam = re.sub(".bam$",".karyotype.bam",bam)
	if not os.path.isfile(gatkBam):
		print "Re-Order Bam for GATK"
		#still complains about discordant length for chrY, so re-align with karyotype .bam (using BWA-MEM)
		command = "java -jar -Xmx" +javaMem+ " /opt/picard-tools-2.5.0/picard.jar ReorderSam R=" + ref + " I=" + tempBam + " O=" + gatkBam + " CREATE_INDEX=TRUE"
		os.system(command)

	command = "rm "+ tempBam
	os.system(command)
	
	bam = gatkBam
	
#GATK dict file
refSearch1 = re.search(".fasta$",ref)
refSearch2 = re.search(".fa$",ref)

if refSearch1:
	refDict = 	re.sub(".fasta$",".dict",ref)
elif refSearch2:
	refDict = 	re.sub(".fa$",".dict",ref)
else:
	print "Reference needs to end with .fasta or .fa: " + ref
	sys.exit()
	
if not os.path.isfile(refDict):
	print "Creating Sequence Dict for GATK"
	command = "java -jar -Xmx" +javaMem+ " /opt/picard-tools-2.5.0/picard.jar CreateSequenceDictionary R=" + ref + " O=" + refDict
	os.system(command)

#run VarScan
if varscanFlag == "1":
	print "Creating .pileup file for VarScan"
	nodupPileup = re.sub(".bam$",".pileup",bam)
	command = "/opt/samtools-1.3/samtools mpileup -C50 -f " + ref + " " + bam + " > " + nodupPileup
	os.system(command)
	
	minCoverage = 10
	minVarReads = 4
	minQual = 20
	minFreq = 0.3
	
	print "Defining VarScan SNPs"
	nodupVarScanSNP = re.sub(".bam$",".varscan.snp.vcf",bam)
	command = "java -jar -Xmx" +javaMem+ " /opt/VarScan.v2.4.2.jar mpileup2snp "+nodupPileup+" --min-coverage "+str(minCoverage)+" --min-reads2 "+str(minVarReads)+" --min-avg-qual "+str(minQual)+" --min-var-freq "+str(minFreq)+" --output-vcf > " + nodupVarScanSNP
	os.system(command)

	print "Defining VarScan Indels"
	nodupVarScanSNP = re.sub(".bam$",".varscan.indel.vcf",bam)
	command = "java -jar -Xmx" +javaMem+ " /opt/VarScan.v2.4.2.jar mpileup2indel "+nodupPileup+" --min-coverage "+str(minCoverage)+" --min-reads2 "+str(minVarReads)+" --min-avg-qual "+str(minQual)+" --min-var-freq "+str(minFreq)+" --output-vcf > " + nodupVarScanSNP
	os.system(command)

	command = "rm " +nodupPileup
	os.system(command)
	
if gatkFlag == "1":
	print "Call SNPs and Indels using GATK HaplotypeCaller"
	#nodupGATKvcf = re.sub(".bam$",".GATK.HC.vcf",bam)
	nodupGATKvcf = re.sub(".bam$",".GATK.HC.vcf",os.path.basename(bam))
	command = "/opt/gatk-4.0.1.1/gatk --java-options '-Xmx" +javaMem+ "' HaplotypeCaller --reference "+ ref +" --input "+bam+" --output " + nodupGATKvcf
	os.system(command)

	nodupGATKvcf = re.sub(".bam$",".GATK.HC.nosoftclip.vcf",os.path.basename(bam))
	command = "/opt/gatk-4.0.1.1/gatk --java-options '-Xmx" +javaMem+ "' HaplotypeCaller --reference "+ ref +" --input "+bam+" --output " + nodupGATKvcf + " --dont-use-soft-clipped-bases true"
	os.system(command)
	
	filteredGATKvcf = re.sub(".bam$",".GATK.HC.nosoftclip.filtered.vcf",os.path.basename(bam))
	command = "/opt/gatk-4.0.1.1/gatk --java-options '-Xmx" +javaMem+ "' VariantFiltration --variant "+nodupGATKvcf+" --output " + filteredGATKvcf + " -window 35 -cluster 3 -filter-name QD -filter \"QD < 2.0\" -filter-name FS -filter \"FS > 30.0\""
	os.system(command)