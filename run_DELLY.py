import sys
import re
import os

filteredBam = "veritas_wgs.filter.bam"
ref = "hg19.fasta"

#use -q 20 to only call varients supported by high quality reads (and decrease run-time)

bcf = "DELLY_DEL.bcf"
command = "delly call -t DEL -q 20 -g " + ref + " -o " + bcf + " " + filteredBam
os.system(command)
vcf = "DELLY_DEL.vcf"
command = "bcftools view " + bcf + " > " + vcf
os.system(command)

bcf = "DELLY_DUP.bcf"
command = "delly call -t DUP -q 20 -g " + ref + " -o " + bcf + " " + filteredBam
os.system(command)
vcf = "DELLY_DUP.vcf"
command = "bcftools view " + bcf + " > " + vcf
os.system(command)

bcf = "DELLY_INV.bcf"
command = "delly call -t INV -q 20 -g " + ref + " -o " + bcf + " " + filteredBam
os.system(command)
vcf = "DELLY_INV.vcf"
command = "bcftools view " + bcf + " > " + vcf
os.system(command)

bcf = "DELLY_TRA.bcf"
command = "delly call -t TRA -q 20 -g " + ref + " -o " + bcf + " " + filteredBam
os.system(command)
vcf = "DELLY_TRA.vcf"
command = "bcftools view " + bcf + " > " + vcf
os.system(command)

bcf = "DELLY_INS.bcf"
command = "delly call -t INS -q 20 -g " + ref + " -o " + bcf + " " + filteredBam
os.system(command)
vcf = "DELLY_INS.vcf"
command = "bcftools view " + bcf + " > " + vcf
os.system(command)