#!/bin/sh

#something very similar to this worked on AWS (although that requires "yum" instead of "apt-get")

N_SHARDS=8
OUTPUT_DIR=/mnt/cdw-genome/Charles_Human/Genos_Exome/BWA-MEM_Alignment/DeepVariant_Output
REF=/mnt/cdw-genome/Ref/hg19.gatk.fasta
BAM=/mnt/cdw-genome/Charles_Human/Genos_Exome/BWA-MEM_Alignment/BWA-MEM_realign_TARGET.bam
MODEL_NAME=DeepVariant-inception_v3-0.7.2+data-wes_standard

### ideally, edit above this point ###

MODEL=/mnt/cdw-genome/Ref/DeepVariant/${MODEL_NAME}/model.ckpt
CALL_VARIANTS_OUTPUT="${OUTPUT_DIR}/call_variants_output.tfrecord.gz"
FINAL_OUTPUT_VCF="${OUTPUT_DIR}/output.vcf.gz"
LOGDIR=logs

## step #1: make_examples ##

sudo apt-get install time
sudo apt-get -y install parallel #you may have to install this before running the script

sudo mkdir -p ${OUTPUT_DIR}
sudo mkdir -p "${LOGDIR}"

time seq 0 $((N_SHARDS-1)) | \
  parallel --eta --halt 2 --joblog "${LOGDIR}/log" --res "${LOGDIR}" \
  sudo docker run \
    -v /home/cwarden/cdw-genome:/mnt/cdw-genome \
    gcr.io/deepvariant-docker/deepvariant \
    /opt/deepvariant/bin/make_examples \
    --mode calling \
    --ref "${REF}" \
    --reads "${BAM}" \
    --examples "${OUTPUT_DIR}/examples.tfrecord@${N_SHARDS}.gz" \
    --task {}

## step #2: call_variants ##

sudo docker run \
  -v /home/cwarden/cdw-genome:/mnt/cdw-genome \
  gcr.io/deepvariant-docker/deepvariant \
  /opt/deepvariant/bin/call_variants \
  --outfile "${CALL_VARIANTS_OUTPUT}" \
  --examples "${OUTPUT_DIR}/examples.tfrecord@${N_SHARDS}.gz" \
  --checkpoint "${MODEL}"
 
## step #3: postprocess_variants ##

sudo docker run \
  -v /home/cwarden/cdw-genome:/mnt/cdw-genome \
  gcr.io/deepvariant-docker/deepvariant \
  /opt/deepvariant/bin/postprocess_variants \
  --ref "${REF}" \
  --infile "${CALL_VARIANTS_OUTPUT}" \
  --outfile "${FINAL_OUTPUT_VCF}"
