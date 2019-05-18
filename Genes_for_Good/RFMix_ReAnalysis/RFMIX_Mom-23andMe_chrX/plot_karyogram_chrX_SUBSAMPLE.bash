#!/bin/bash

#modified karyogram code from https://github.com/armartin/ancestry_pipeline

python plot_karyogram.py \
--bed_a MOM_SUBSAMPLE_A.bed \
--bed_b MOM_SUBSAMPLE_B.bed \
--ind MOM_chrX_SUBSAMPLE \
--out MOM_chrX_SUBSAMPLE.png \
--pop_order AFR,AMR,EAS,EUR,SAS \
--colors red,orange,green,blue,purple \
--centromeres centromeres_chrX_custom.bed