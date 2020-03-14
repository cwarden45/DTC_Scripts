bam_list = "28_1000_Genomes-plus-Nebula_provided-bams.txt"
name_list = "28_1000_Genomes-plus-Nebula_provided-names.txt"
output_folder = "STITCH-all_bam-Nebula_provided"

library("STITCH")
#from https://github.com/rwdavies/STITCH/blob/master/examples/examples.R
human_K = 10
human_nGen = 4 * 20000 / human_K
human_posfile = "../STITCH_Gencove/STITCH_human_example_2016_10_18/pos.txt"
temp_folder= "temp"

system(paste("mkdir ",temp_folder,sep=""))

STITCH(
  bamlist = bam_list,
  sampleNames_file = name_list,
  outputdir = output_folder,
  posfile = human_posfile,
  method = "diploid",
  regenerateInput = TRUE,
  regionStart = 1000000,
  regionEnd = 1100000,
  buffer = 10000,
  niterations = 1,
  chr = "20",
  inputBundleBlockSize = 100,
  shuffleHaplotypeIterations = NA,
  refillIterations = NA,
  K = human_K, tempdir = temp_folder, nCores = 1, nGen = human_nGen)