import sys
import re
import os

javaMem = "-Xmx8g"

ref = "/path/to/BWA/hg19.fa"
dict = "/path/to/BWA/hg19.dict"
command = "java " + javaMem + " -jar /opt/picard-tools-2.5.0/picard.jar CreateSequenceDictionary R=" + ref + " O=" + dict
os.system(command)

bed = "S04380110_V5/S04380110_Covered.bed"
interval = "Picard_SureSelect_V5_hg19.interval_list"
command = "java " + javaMem + " -jar /opt/picard-tools-2.5.0/picard.jar BedToIntervalList I=" + bed + " O=" + interval + " SD=" + dict
os.system(command)