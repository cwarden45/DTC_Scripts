#!/bin/sh

BATCHFILE=16S_2021-SILVA-FULL.batch
SUBFOLDER=.
export REF=/home/cwarden/Ref/mothur/silva.nr_v132/silva.nr_v132
export CONF=80

#based upon https://mothur.org/wiki/miseq_sop/
#general batch mode instructions: https://mothur.org/wiki/batch_mode/
export DIR=$(pwd)
export SUBFOLDER=$SUBFOLDER
export PREFIX=16S_2021
export PROC=4
export MAXLENGTH=275

##mothur v.1.44.3
/opt/mothur/mothur \"$BATCHFILE\"