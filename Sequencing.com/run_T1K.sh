R1=../CharlesWarden-NG1J8B7TDM-30x-WGS-Sequencing_com-10-13-21.1.fq.gz
R2=../CharlesWarden-NG1J8B7TDM-30x-WGS-Sequencing_com-10-13-21.2.fq.gz
REF=/opt/T1K/hlaidx/hlaidx_dna_seq.fa 
THREADS=4
OUTPRE=Sequencing.com

/opt/T1K/run-t1k -1 $R1 -2 $R2 --preset hla-wgs -f $REF -o $OUTPRE -t $THREADS