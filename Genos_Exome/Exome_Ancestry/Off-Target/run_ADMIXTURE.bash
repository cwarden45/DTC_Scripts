#!/bin/bash

PREFIX=FILTERED-1000_genomes_20140502_plus_2-SNP-chip_plus_Genos-Off-Target-flank50000-ref286

##make sure you have .pop file with same name
/opt/admixture_linux-1.3.0/admixture $PREFIX.bed 5 --supervised