#!/bin/bash
set -euo pipefail
# Set common settings.
PROJECT_ID=cdw-deepvariant-wgs-exome
OUTPUT_BUCKET=gs://cdw-genome/Charles_Human/Genos_Exome/BWA-MEM_Alignment/DeepVariant_Output
STAGING_FOLDER_NAME=wes_staging
OUTPUT_FILE_NAME=Exome_BWA-MEM.vcf

## Model for calling Exome sequencing data
MODEL=gs://deepvariant/models/DeepVariant/0.7.2/DeepVariant-inception_v3-0.7.2+data-wes_standard

IMAGE_VERSION=0.7.2
DOCKER_IMAGE=gcr.io/deepvariant-docker/deepvariant:"${IMAGE_VERSION}"
COMMAND="/opt/deepvariant_runner/bin/gcp_deepvariant_runner \
  --project ${PROJECT_ID} \
  --zones us-west2-* \
  --docker_image ${DOCKER_IMAGE} \
  --outfile ${OUTPUT_BUCKET}/${OUTPUT_FILE_NAME} \
  --staging ${OUTPUT_BUCKET}/${STAGING_FOLDER_NAME} \
  --model ${MODEL} \
  --bam gs://cdw-genome/Charles_Human/Genos_Exome/BWA-MEM_Alignment/BWA-MEM_realign_TARGET.bam \
  --ref gs://cdw-genome/Ref/hg19.gatk.fasta \
  --gcsfuse"
  
# Run the pipeline.
# run after 'gcloud config set compute/region ""'
gcloud alpha genomics pipelines run \
    --project "${PROJECT_ID}" \
    --regions us-west2 \
    --service-account-scopes="https://www.googleapis.com/auth/cloud-platform" \
    --logging "${OUTPUT_BUCKET}/${STAGING_FOLDER_NAME}/runner_logs_$(date +%Y%m%d_%H%M%S).log" \
	--docker-image gcr.io/deepvariant-docker/deepvariant_runner:"${IMAGE_VERSION}" \
    --command-line "${COMMAND}"
