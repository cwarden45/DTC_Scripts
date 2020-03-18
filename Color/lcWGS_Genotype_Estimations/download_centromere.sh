#!/bin/bash

#based upon https://www.biostars.org/p/2349/
curl -s "http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/cytoBand.txt.gz" | gunzip -c | grep acen > UCSC_Download_Centromere.txt