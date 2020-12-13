QUERY=RefSeq_Combined.fasta
REF=RefSeq_Combined.fasta
OUT=RefSeq-Self_BLAST_hits.txt
OUT2=RefSeq-Self_BLAST_1hit.txt



## empty files (for mismatched BRCA genes) were not uploaded to GitHub, but all commands below were run


#QUERY=BRCA1_RefSeq.fasta
#REF=BRCA1_NCBI_Gene-Other_seq.fa
#OUT=BRCA1_RefSeq-to-BRCA1_NCBI_Gene_Other-BLAST_hits.txt
#OUT2=BRCA1_RefSeq-to-BRCA1_NCBI_Gene_Other-BLAST_1hit.txt

#QUERY=BRCA1_RefSeq.fasta
#REF=BRCA2_NCBI_Gene-Other_seq.fa
#OUT=BRCA1_RefSeq-to-BRCA2_NCBI_Gene_Other-BLAST_hits.txt
#OUT2=BRCA1_RefSeq-to-BRCA2_NCBI_Gene_Other-BLAST_1hit.txt

#QUERY=BRCA1_RefSeq.fasta
#REF=BRCA1_NCBI_Nucleotide.fasta
#OUT=BRCA1_RefSeq-to-BRCA1_NCBI_Nucleotide-BLAST_hits.txt
#OUT2=BRCA1_RefSeq-to-BRCA1_NCBI_Nucleotide-BLAST_1hit.txt

#QUERY=BRCA1_RefSeq.fasta
#REF=BRCA2_NCBI_Nucleotide.fasta
#OUT=BRCA1_RefSeq-to-BRCA2_NCBI_Nucleotide-BLAST_hits.txt
#OUT2=BRCA1_RefSeq-to-BRCA2_NCBI_Nucleotide-BLAST_1hit.txt



#QUERY=BRCA2_RefSeq.fasta
#REF=BRCA1_NCBI_Gene-Other_seq.fa
#OUT=BRCA2_RefSeq-to-BRCA1_NCBI_Gene_Other-BLAST_hits.txt
#OUT2=BRCA2_RefSeq-to-BRCA1_NCBI_Gene_Other-BLAST_1hit.txt

#QUERY=BRCA2_RefSeq.fasta
#REF=BRCA2_NCBI_Gene-Other_seq.fa
#OUT=BRCA2_RefSeq-to-BRCA2_NCBI_Gene_Other-BLAST_hits.txt
#OUT2=BRCA2_RefSeq-to-BRCA2_NCBI_Gene_Other-BLAST_1hit.txt

#QUERY=BRCA2_RefSeq.fasta
#REF=BRCA1_NCBI_Nucleotide.fasta
#OUT=BRCA2_RefSeq-to-BRCA1_NCBI_Nucleotide-BLAST_hits.txt
#OUT2=BRCA2_RefSeq-to-BRCA1_NCBI_Nucleotide-BLAST_1hit.txt

#QUERY=BRCA2_RefSeq.fasta
#REF=BRCA2_NCBI_Nucleotide.fasta
#OUT=BRCA2_RefSeq-to-BRCA2_NCBI_Nucleotide-BLAST_hits.txt
#OUT2=BRCA2_RefSeq-to-BRCA2_NCBI_Nucleotide-BLAST_1hit.txt



/opt/ncbi-blast-2.9.0+/bin/makeblastdb -in $REF -dbtype nucl

#format BLAST output based upon: https://github.com/cwarden45/metagenomics_templates/blob/master/MiSeq_16S/run_classifier.py
/opt/ncbi-blast-2.9.0+/bin/blastn -num_threads 1 -max_hsps 1 -evalue 1e-10 -query $QUERY -db $REF -out $OUT -outfmt "6 qseqid qlen qstart qend sseqid slen sstart send length pident nident mismatch gaps evalue qcovs qcovhsp qcovus"
/opt/ncbi-blast-2.9.0+/bin/blastn -num_threads 1 -num_alignments 1 -evalue 1e-10 -query $QUERY -db $REF -out $OUT2 -outfmt "6 qseqid qlen qstart qend sseqid slen sstart send length pident nident mismatch gaps evalue qcovs qcovhsp qcovus"