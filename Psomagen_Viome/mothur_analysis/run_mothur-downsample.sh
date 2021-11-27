#!/bin/sh

#BATCHFILE=16S_2021-RDP.batch
#SUBFOLDER=FQ_40k_reads-RDP
#export REF=/home/cwarden/Ref/mothur/RDPv18/trainset18_062020.rdp/trainset18_062020
#export CONF=80

#BATCHFILE=16S_2021-SILVA.batch
#SUBFOLDER=FQ_40k_reads-SILVA_seed
#export REF=/home/cwarden/Ref/mothur/silva.seed_v132/silva.seed_v132
#export CONF=80

#BATCHFILE=16S_2021-SILVA.batch
#SUBFOLDER=FQ_40k_reads-SILVA_full
#export REF=/home/cwarden/Ref/mothur/silva.nr_v132/silva.nr_v132
#export CONF=80

#BATCHFILE=16S_2021-SILVA.batch
#SUBFOLDER=FQ_40k_reads-SILVA_full_70conf
#export REF=/home/cwarden/Ref/mothur/silva.nr_v132/silva.nr_v132
#export CONF=70

BATCHFILE=16S_2021-SILVA.batch
SUBFOLDER=FQ_40k_reads-SILVA_full_50conf
export REF=/home/cwarden/Ref/mothur/silva.nr_v132/silva.nr_v132
export CONF=50

MINSIZE=40000

#based upon https://mothur.org/wiki/miseq_sop/
#general batch mode instructions: https://mothur.org/wiki/batch_mode/
export DIR=$(pwd)
export SUBFOLDER=$SUBFOLDER
export PREFIX=16S_2021
export PROC=4
export MAXLENGTH=275

mkdir $SUBFOLDER

#follow https://superuser.com/questions/31464/looping-through-ls-results-in-bash-shell-script
for R1 in *_R1.fastq.gz; do
	#follow https://stackoverflow.com/questions/16623835/remove-a-fixed-prefix-suffix-from-a-string-in-bash
	SAMPLE=${R1%"_R1.fastq.gz"}
	echo $SAMPLE
	
	R1IN=$SAMPLE\_R1.fastq.gz
	R2IN=$SAMPLE\_R2.fastq.gz
	
	R1OUT=$SUBFOLDER/$SAMPLE\_R1.fastq
	R2OUT=$SUBFOLDER/$SAMPLE\_R2.fastq
	
	##seqtk v1.3-r117-dirty
	/opt/seqtk/seqtk sample -s100 $R1IN $MINSIZE > $R1OUT
	/opt/seqtk/seqtk sample -s100 $R2IN $MINSIZE > $R2OUT
done

##mothur v.1.44.3
/opt/mothur/mothur \"$BATCHFILE\"