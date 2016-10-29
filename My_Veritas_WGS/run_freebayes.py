import os

bam= "BWA_MEM_Alignment/hg19.gatk.bam"
ref = "hg19.gatk.fasta"
vcf = "BWA_MEM_Alignment/hg19.gatk.freebayes.vcf"

minVarReads = 4
minVarFreq = 0.3
minMapQual = 50
minBaseQual = 20
command = "/opt/freebayes/bin/freebayes -C "+str(minVarReads)+" -F "+str(minVarFreq)+" -m "+str(minMapQual)+" -q "+str(minBaseQual)+" -f "+ ref +" "+bam + " > "+ vcf
os.system(command)