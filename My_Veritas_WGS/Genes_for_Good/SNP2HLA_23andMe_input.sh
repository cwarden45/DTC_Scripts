#!/bin/sh

#be sure to copy over beagle.jar / linkage2beagle.jar (from older version of BEAGLE) and beagle2linkage.jar (separate from BEAGLE package), as described at http://software.broadinstitute.org/mpg/snp2hla/snp2hla_manual.html

#You can download Genes for Good genotypes in 23andMe format, so this script with work with either 23andMe data or G4G data

PREFIX=G4G
INPUT23=../GFG_filtered_unphased_genotypes_23andMe.txt

#Please note that the lateset version of plink version 1.9 is needed for directly parsing 23andMe format file (and also seems to work with SNP2HLA, even though v1.07 is recommended) 
plink_linux_x86_64/plink --23file $INPUT23 Warden Charles --out $PREFIX --noweb

HLAOUT=$PREFIX\_SNP2HLA_OUT
SNP2HLA_package_v1.0.3/SNP2HLA/SNP2HLA.csh $PREFIX SNP2HLA_package_v1.0.3/SNP2HLA/HM_CEU_REF $HLAOUT plink_linux_x86_64/plink 2000 1000

grep "HLA" $HLAOUT.bim | awk '$5 == "P" || $6 == "P"' > $PREFIX\_SNP2HLA_HLAalleles.bim