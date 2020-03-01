sampleID = "Nebula_full_nodup"
input_bam = "../Nebula/BWA_MEM.nodup.bam"

### Hopefully, edit above this point?

library("STITCH")

#human_genfile = "gen_sequencing.txt" #this is supposed to be optional
human_K = 10
human_nGen = 4 * 20000 / human_K

human_posfile = "STITCH_human_example_2016_10_18/pos-ALT.txt"
human_reference_sample_file = "1000GP_Phase3.sample"
human_reference_legend_file =  "1000GP_Phase3_chr20.legend.gz"
human_reference_haplotype_file = "1000GP_Phase3_chr20.hap.gz"

human_matched_to_reference_genfile = "STITCH_human_reference_example_2018_07_11/gen_sequencing.intersect.txt"#also optional?
human_matched_to_reference_posfile = "STITCH_human_reference_example_2018_07_11/pos.intersect.txt"
human_matched_to_reference_reference_legend_file = "STITCH_human_reference_example_2018_07_11/1000GP_Phase3_20.1000000.1100000.legend.gz"
human_matched_to_reference_reference_haplotype_file = "STITCH_human_reference_example_2018_07_11/1000GP_Phase3_20.1000000.1100000.hap.gz"


#try to follow human example 3: https://github.com/rwdavies/STITCH/blob/master/examples/examples.R

STITCH(
  #bamlist = list(input_bam),
  bamlist = input_bam,
  sampleNames_file = paste(sampleID,"-names.txt",sep=""),
  outputdir = sampleID,
  method = "diploid",
  originalRegionName = "20.1000000.1100000",
  regenerateInput = TRUE,
  regionStart = 1000000,
  regionEnd = 1100000,
  buffer = 10000,
  niterations = 1,
  chr = "chr20",
  inputBundleBlockSize = 100,
  reference_populations = c("CEU", "GBR", "ACB"),
  reference_haplotype_file = human_matched_to_reference_reference_haplotype_file,
  reference_sample_file = human_reference_sample_file,
  reference_legend_file = human_matched_to_reference_reference_legend_file,
  posfile = human_posfile,
  shuffleHaplotypeIterations = NA,
  refillIterations = NA,
  K = human_K, tempdir = "temp", nCores = detectCores(), nGen = human_nGen)