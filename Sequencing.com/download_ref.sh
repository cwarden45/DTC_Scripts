#!/bin/bash

#copied and modified from `run-gen-ref` (from http://sourceforge.net/projects/bio-bwa/files/bwakit/bwakit-0.7.12_x64-linux.tar.bz2/download )

#url38="ftp://ftp.ncbi.nlm.nih.gov/genbank/genomes/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh38/seqs_for_alignment_pipelines/GCA_000001405.15_GRCh38_full_analysis_set.fna.gz"
url38="ftp://ftp.ncbi.nlm.nih.gov/genomes/archive/old_genbank/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh38/seqs_for_alignment_pipelines/GCA_000001405.15_GRCh38_full_analysis_set.fna.gz"


wget $url38 
gunzip GCA_000001405.15_GRCh38_full_analysis_set.fna.gz
cat GCA_000001405.15_GRCh38_full_analysis_set.fna resource-GRCh38/hs38DH-extra.fa > hs38DH.fa
rm GCA_000001405.15_GRCh38_full_analysis_set.fna
cp resource-GRCh38/hs38DH.fa.alt hs38DH.fa.alt