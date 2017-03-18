import sys
import re
import os

bed = ""
interval = ""
ref = ""
javaMem = "4g"


for arg in sys.argv:
	replacementResult = re.search("^--bam_folder=(.*)",arg)
	memResult = re.search("^--java_mem=(.*)",arg)
	inputResult = re.search("^--input=(.*)",arg)
	outputResult = re.search("^--output=(.*)",arg)
	refResult = re.search("^--ref=(.*)",arg)
	helpResult = re.search("^--help",arg)
	
	if replacementResult:
		bamFolder = replacementResult.group(1)

	if memResult:
		javaMem = memResult.group(1)

	if inputResult:
		bed = inputResult.group(1)

	if outputResult:
		interval = outputResult.group(1)

	if refResult:
		ref = refResult.group(1)
		
	if helpResult:
		print "Usage: python create_interval_file.py --input=targets.bed --output=targets.interval_list --ref=ref.fa --java_mem=4g\n"
		print "--input : .bed file with target regions\n"
		print "--output : name of output .interal_list for target regions\n"
		print "--ref : Reference FASTA (must end with .fa or .fasta)\n"
		print "--java_mem : Java memory limit for Picard\n"
		sys.exit()

faResult = re.search(".fa$",ref)
fastaResult = re.search(".fasta$",ref)

if fastaResult:
	dict = os.path.abspath(re.sub(".fasta$",".dict",ref))
	print "\nUsing .dict file: " + dict
elif faResult:
	dict = os.path.abspath(re.sub(".fa$",".dict",ref))
	print "\nUsing .dict file: " + dict
else:
	print ".dict index file created based upon FASTA ref name, which must end with .fa or .fasta"
	print "Provided Ref: " + ref
	sys.exit()

if not os.path.exists(dict):
	print "Creating .dict index for reference..."
	command = "java -Xmx" + javaMem + " -jar /opt/picard-tools-2.5.0/picard.jar CreateSequenceDictionary R=" + ref + " O=" + dict
	os.system(command)
	
command = "java -Xmx" + javaMem + " -jar /opt/picard-tools-2.5.0/picard.jar BedToIntervalList I=" + bed + " O=" + interval + " SD=" + dict
print command
os.system(command)