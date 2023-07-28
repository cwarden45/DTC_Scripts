FQ=../GFX0457625_SL_L001_001.reads.1_1.fastq.gz
REF=/opt/T1K/hlaidx/hlaidx_dna_seq.fa 
THREADS=4
OUTPRE=DantePacBioHiFi

/opt/T1K/run-t1k -u $FQ --preset hla -f $REF -o $OUTPRE -t $THREADS