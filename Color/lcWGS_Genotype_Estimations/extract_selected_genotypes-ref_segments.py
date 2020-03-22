import sys
import re
import os

STITCHprefix = "1KG_IMPUTE2-Nebula_full_nodup"
individual_VCF = "1KG_IMPUTE2-Nebula_full_nodup-for_CW.vcf"

#extract imputed genotypes

outHandle = open(individual_VCF, 'w')

segment_names = ["1_left","1_right","2_left","2_right","3_left","3_right","4_left","4_right","5_left","5_right","6_left","6_right","7_left","7_right","8_left","8_right","9_left","9_right","10_right","11_left","11_right","12_right","13_right","14_right","15_right","16_right","17_right","18_right"]
segment_start = [10000001,138900000,10000001,106800000,10000001,103900000,10000001, 62700000,10000001, 36100000,10000001, 73300000,10000001, 71700000,10000001, 58100000,10000001, 60700000,  52300000, 10000001,  65700000,  48200000,  29500000,  29100000,  30700000,  48600000,  35800000,29000000]
segment_stop = [111500000,239250621,80500000,233199373,77900000,188022430,38200000,181154276,36100000,170915260,48700000,161115067,48000000,149138663,33100000,136364022,37300000,131213431, 125534747, 41600000, 125006516, 123851895, 105169878,  97349540,  92531392,  80354753,  71195210,29000000]#need to change this for chr18
for i in range(0,len(segment_names)):
	temp_name = segment_names[i]
	temp_start = segment_start[i]
	temp_stop = segment_stop[i]
	print"Working on chromosome " + temp_name + "... "
	output_folder = STITCHprefix+"_"+temp_name
	
	chr = re.sub("_left","",temp_name)
	chr = re.sub("_right","",chr)
	
	inputedVCF = output_folder + "/stitch."+chr+"."+str(temp_start)+"."+str(temp_stop)+".vcf"
	if not os.path.isfile(inputedVCF):
		print "Creating uncompressed STITCH .vcf file"
		command = "gunzip -c " + inputedVCF+ ".gz > " +  inputedVCF
		os.system(command)
	
	sampleIndex = -1

	inHandle = open(inputedVCF)
	line = inHandle.readline()

	while line:
		line = re.sub("\n","",line)
		line = re.sub("\r","",line)
		
		commentResult = re.search("^##",line)
		
		if not commentResult:		
			lineInfo = line.split("\t")
			chr =  lineInfo[0]
			pos =  lineInfo[1]
			varID =  lineInfo[2]
			ref =  lineInfo[3]
			alt =  lineInfo[4]
			qual =  lineInfo[5]
			filter =  lineInfo[6]
			info =  lineInfo[7]
			format =  lineInfo[8]
			
			headerResult = re.search("^#",line)
			
			if headerResult:
				text = line+ "\n"
				outHandle.write(text)
			else:	
				if filter == "PASS":
					geno_text = lineInfo[9]
					#print line
					#print geno_text
					geno = geno_text[0:3]
					
					if (geno == "0/0") or (geno == "1/1") or (geno == "0/1") or (geno == "1/0"):
						text = chr + "\t" + pos + "\t" + varID + "\t" +  ref + "\t"  +  alt + "\t" + qual + "\t" + filter + "\t" + info + "\tGT\t" +geno+ "\n"
						outHandle.write(text)					
					elif geno != "./.":
						print "Update code to decide whether to keep genotype: |" + geno + "|"
						sys.exit()
			
		line = inHandle.readline()
		
	inHandle.close()

outHandle.close()