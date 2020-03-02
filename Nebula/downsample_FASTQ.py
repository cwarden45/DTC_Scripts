import sys
import re
import os

#down_fraction = 2
#down_fraction = 10
down_fraction = 100

inR1="951023c1725b4b52b150c46469121abd_R1.fastq"
inR2="951023c1725b4b52b150c46469121abd_R2.fastq"


outR1 = re.sub(".fastq$","_down"+str(down_fraction)+".fastq",inR1)
outR2 = re.sub(".fastq$","_down"+str(down_fraction)+".fastq",inR2)

print outR1
print outR2

print "Down-Sampling R1 ("+str(down_fraction)+"x)...\n"
outHandle = open(outR1, 'w')

inHandle = open(inR1)
line = inHandle.readline()

lineCount = 0
readCount = 0

writeFlag = 0
			
while line:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	lineInfo = line.split("\t")
	
	lineCount+=1
	
	if (lineCount % 4 == 1):
		readCount+=1

	if (readCount % down_fraction == 0):
		writeFlag = 1
	else:
		writeFlag = 0

	if writeFlag == 1:
		text = line + "\n"
		outHandle.write(text)

	line = inHandle.readline()
	
inHandle.close()
outHandle.close()

print "Down-Sampling R2 ("+str(down_fraction)+"x)...\n"
outHandle = open(outR2, 'w')

inHandle = open(inR2)
line = inHandle.readline()

lineCount = 0
readCount = 0

writeFlag = 0
			
while line:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	lineInfo = line.split("\t")
	
	lineCount+=1
	
	if (lineCount % 4 == 1):
		readCount+=1

	if (readCount % down_fraction == 0):
		writeFlag = 1
	else:
		writeFlag = 0

	if writeFlag == 1:
		text = line + "\n"
		outHandle.write(text)

	line = inHandle.readline()
	
inHandle.close()
outHandle.close()
