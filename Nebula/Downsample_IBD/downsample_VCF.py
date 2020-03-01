import sys
import re
import os

#down_fraction = 10
#down_fraction = 20
#down_fraction = 100
#down_fraction = 200
down_fraction = 300

inputfile="1000_genomes_20140502_plus_2-SNP-chip_plus_Veritas_plus_Nebula.vcf"

pedIn = re.sub(".vcf",".ped",inputfile)

outputfile = re.sub(".vcf$","_down"+str(down_fraction)+".vcf",inputfile)
pedOut = re.sub(".ped","_down"+str(down_fraction)+".ped",pedIn)

print inputfile
print outputfile

outHandle = open(outputfile, 'w')

inHandle = open(inputfile)
line = inHandle.readline()

lineCount = 0
			
while line:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	lineInfo = line.split("\t")
	
	lineCount+=1
	
	if (lineCount == 1):
		text = line + "\n"
		outHandle.write(text)
	elif (lineCount % down_fraction == 0):
		text = line + "\n"
		outHandle.write(text)		

	line = inHandle.readline()
	
inHandle.close()

command = "cp "+ pedIn + " " + pedOut
os.system(command)