bam_list = "Nebula_full_nodup-bams.txt"
name_list = "Nebula_full_nodup-names.txt"
output_prefix = "1KG_IMPUTE2-Nebula_full_nodup"

library("STITCH")
pos_folder = "human_g1k_v37-pos_files"

autosomal_chr = 1:22
fa_index =  "../1000_Genomes_BAMs/Ref/human_g1k_v37.fasta.fai"
fa_index.table = read.table(fa_index, head=F, sep="\t")

#human_genfile = "gen_sequencing.txt" #this is supposed to be optional
human_K = 10
human_nGen = 4 * 20000 / human_K
temp_folder = tempdir()

#try to follow human example 3: https://github.com/rwdavies/STITCH/blob/master/examples/examples.R

for (chr in autosomal_chr){
	print(paste("Running STITCH for ",chr,"...",sep=""))
	human_posfile = paste(pos_folder,"/",chr,"_pos.txt",sep="")
	output_folder = paste(output_prefix,"_",chr,sep="")

	human_reference_sample_file = "../1000_Genomes_BAMs/IMPUTE2_Files/1000GP_Phase3/1000GP_Phase3.sample"
	human_reference_legend_file = paste("../1000_Genomes_BAMs/IMPUTE2_Files/1000GP_Phase3/1000GP_Phase3_chr",chr,".legend.gz",sep="")
	human_reference_haplotype_file = paste("../1000_Genomes_BAMs/IMPUTE2_Files/1000GP_Phase3/1000GP_Phase3_chr",chr,".hap.gz",sep="")

	STITCH(
		bamlist = bam_list,
		sampleNames_file = name_list,
		outputdir = output_folder,
		method = "diploid",
		regenerateInput = TRUE,
		regionStart = 1,
		regionEnd = fa_index.table$V2[fa_index.table$V1 == chr],
		buffer = 10000,
		niterations = 20,
		chr = chr,
		inputBundleBlockSize = 100,
		reference_populations = c("CEU", "GBR", "ACB"),
		reference_haplotype_file = human_reference_haplotype_file,
		reference_sample_file = human_reference_sample_file,
		reference_legend_file = human_reference_legend_file,
		posfile = human_posfile,
		shuffleHaplotypeIterations = NA,
		refillIterations = NA,
		K = human_K, tempdir = temp_folder, nCores = 1, nGen = human_nGen)
	  
	  stop()
}#end for (chr in autosomal_chr)