R1=../CharlesWarden-NG1J8B7TDM-30x-WGS-Sequencing_com-10-13-21.1.fq.gz
R2=../CharlesWarden-NG1J8B7TDM-30x-WGS-Sequencing_com-10-13-21.2.fq.gz
OUTPRE=Sequencing.com

BWAKIT=/opt/bwakit-0.7.12_x64-linux/bwa.kit/

$BWAKIT/seqtk mergepe $R1 $R2 \
  | $BWAKIT/trimadap 2> $OUTPRE.log.trim \
  | $BWAKIT/bwa mem -p -t4 -R'@RG\tID:Sequencing.com\tSM:unknown' $BWAKIT/hs38DH.fa - 2> $OUTPRE.log.bwamem \
  | $BWAKIT/samblaster 2> $OUTPRE.log.dedup \
  | $BWAKIT/k8 $BWAKIT/bwa-postalt.js -p $OUTPRE.hla $BWAKIT/hs38DH.fa.alt \
  | $BWAKIT/samtools view -1 - > $OUTPRE.aln.bam;
$BWAKIT/run-HLA $OUTPRE.hla > $OUTPRE.hla.top 2> $OUTPRE.log.hla;
touch $OUTPRE.hla.HLA-dummy.gt; cat $OUTPRE.hla.HLA*.gt | grep ^GT | cut -f2- > $OUTPRE.hla.all;
