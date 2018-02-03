import sys
import re
import os

print "Download and Re-format hg19 Reference Sequence for WGS QC Metrics"
print "Enter your e-mail as a password"
command = "wget --timestamping 'ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/chromFa.tar.gz' --user=anonymous --ask-password"
os.system(command)

command = "tar -xvzf chromFa.tar.gz"
os.system(command)

print "Merging hg19 chromosomes"
cwdContents = os.listdir(".")
chrFa = []
for file in cwdContents:
	faMatch = re.search(".fa$",file)
	if faMatch:
		chrFa.append(file)
		
command = "cat " + " ".join(chrFa) + " > hg19.fasta"
os.system(command)

command = "rm *.fa"
os.system(command)
