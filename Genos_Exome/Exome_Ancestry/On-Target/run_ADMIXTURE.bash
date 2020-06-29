#!/bin/bash

PREFIX=../1000_genomes_20140502_plus_2-SNP-chip_plus_Mayo-Exome_plus_Genos-BWA-MEM-Exome_plus_Veritas_WGS

##make sure you have .pop file with same name
/opt/admixture_linux-1.3.0/admixture $PREFIX.bed 5 --supervised