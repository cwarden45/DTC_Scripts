bam_list = "Nebula_full_nodup-bams.txt"
name_list = "Nebula_full_nodup-names.txt"
output_prefix = "Nebula_full_nodup"
pos_folder = "human_g1k_v37-pos_files"

library("STITCH")

#human_genfile = "gen_sequencing.txt" #this is supposed to be optional
human_K = 10
human_nGen = 4 * 20000 / human_K
temp_folder = tempdir()

human_posfile = "STITCH_human_example_2016_10_18/pos.txt"
human_reference_sample_file = "1000GP_Phase3.sample"
human_reference_legend_file =  "1000GP_Phase3_chr20.legend.gz"
human_reference_haplotype_file = "1000GP_Phase3_chr20.hap.gz"

human_matched_to_reference_genfile = "STITCH_human_reference_example_2018_07_11/gen_sequencing.intersect.txt"#also optional?
human_matched_to_reference_posfile = "STITCH_human_reference_example_2018_07_11/pos.intersect.txt"
human_matched_to_reference_reference_legend_file = "STITCH_human_reference_example_2018_07_11/1000GP_Phase3_20.1000000.1100000.legend.gz"
human_matched_to_reference_reference_haplotype_file = "STITCH_human_reference_example_2018_07_11/1000GP_Phase3_20.1000000.1100000.hap.gz"


#try to follow human example 3: https://github.com/rwdavies/STITCH/blob/master/examples/examples.R

chr = 20
output_folder = paste(output_prefix,"_",chr,sep="")

STITCH(
  bamlist = bam_list,
  sampleNames_file = name_list,
  outputdir = output_folder,
  method = "diploid",
  originalRegionName = "20.1000000.1100000",
  regenerateInput = TRUE,
  regionStart = 1000000,
  regionEnd = 1100000,
  buffer = 10000,
  niterations = 20,
  chr = chr,
  inputBundleBlockSize = 100,
  reference_populations = c("CEU", "GBR", "ACB"),
  reference_haplotype_file = human_matched_to_reference_reference_haplotype_file,
  reference_sample_file = human_reference_sample_file,
  reference_legend_file = human_matched_to_reference_reference_legend_file,
  posfile = human_posfile,
  shuffleHaplotypeIterations = NA,
  refillIterations = NA,
  K = human_K, tempdir = temp_folder, nCores = 1, nGen = human_nGen)