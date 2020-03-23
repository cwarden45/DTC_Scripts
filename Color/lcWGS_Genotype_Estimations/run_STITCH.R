bam_list = "Nebula_full_nodup-bams.txt"
name_list = "Nebula_full_nodup-names.txt"
output_prefix = "1KG_IMPUTE2-Nebula_full_nodup"
shift  = 10000000#I think this can be smaller, but I am trying to get something other than the demo window to work
buffer =  1000000#looking at the output, I think the buffer is more like the shift rather than the window size

library("STITCH")
#pos_folder = "human_g1k_v37-pos_files"
pos_folder = "../1000_Genomes_BAMs/IMPUTE2_Files/1000GP_Phase3"#change to this to match reference set (with more SNPs)

autosomal_chr = 1:22
fa_index =  "../1000_Genomes_BAMs/Ref/human_g1k_v37.fasta.fai"
fa_index.table = read.table(fa_index, head=F, sep="\t")

#created following instructions from https://www.biostars.org/p/2349/
centromere_table = read.table("UCSC_Download_Centromere.txt", head=F, sep="\t")
centromere_table$V1 = as.character(centromere_table$V1)
centromere_table$V1 = gsub("chr","",centromere_table$V1)

#human_genfile = "gen_sequencing.txt" #this is supposed to be optional
human_K = 10
human_nGen = 4 * 20000 / human_K
temp_folder = tempdir()

#try to follow human example 3: https://github.com/rwdavies/STITCH/blob/master/examples/examples.R

for (chr in autosomal_chr){
	print(paste("Finding centromere for chromosome ",chr,"...",sep=""))
	temp.centromere.table = centromere_table[centromere_table$V1 == chr,]
	pos.values = c(temp.centromere.table$V2,temp.centromere.table$V3)
	centromere.start = min(pos.values)
	centromere.stop = max(pos.values)
	print(paste("Centromere length: ",centromere.stop-centromere.start," bp",sep=""))
	
	chr_length = fa_index.table$V2[fa_index.table$V1 == chr]

	human_posfile = paste(pos_folder,"/",chr,"_pos.txt",sep="")
	human_reference_sample_file = "../1000_Genomes_BAMs/IMPUTE2_Files/1000GP_Phase3/1000GP_Phase3.sample"
	
	##swith to using filtered files (with rows matching position file), created using https://github.com/cwarden45/DTC_Scripts/tree/master/Color/lcWGS_Genotype_Estimations/filter_IMPUTE2_files.R ( + extract_desired_rows.pl)
	#human_reference_legend_file = paste("../1000_Genomes_BAMs/IMPUTE2_Files/1000GP_Phase3/1000GP_Phase3_chr",chr,".legend.gz",sep="")
	#human_reference_haplotype_file = paste("../1000_Genomes_BAMs/IMPUTE2_Files/1000GP_Phase3/1000GP_Phase3_chr",chr,".hap.gz",sep="")
	human_reference_legend_file = paste(pos_folder,"/",chr,"_legend.txt.gz",sep="")
	human_reference_haplotype_file = paste(pos_folder,"/",chr,"_hap.txt.gz",sep="")

	######################################
	### sequence "left" of centromere ###
	######################################
	STITCH_start = 1+shift
	STITCH_end = centromere.start-shift
	if((STITCH_end - STITCH_start) > 20 * buffer){
		print(paste("Running STITCH for left-side of ",chr,"...",sep=""))
		output_folder = paste(output_prefix,"_",chr,"_left",sep="")

		STITCH(
			bamlist = bam_list,
			sampleNames_file = name_list,
			outputdir = output_folder,
			method = "diploid",
			regenerateInput = TRUE,
			regionStart = STITCH_start,
			regionEnd = STITCH_end,
			buffer = buffer,
			niterations = 1,
			chr = chr,
	#		reference_populations = c("CEU", "GBR", "ACB"),#this is a reference set of 286 samples
			reference_populations = c("CEU"),#this is a reference set of 99 samples		
			reference_haplotype_file = human_reference_haplotype_file,
			reference_sample_file = human_reference_sample_file,
			reference_legend_file = human_reference_legend_file,
			posfile = human_posfile,
			shuffleHaplotypeIterations = NA,
			refillIterations = NA,
			K = human_K, tempdir = temp_folder, nCores = 1, nGen = human_nGen)
	}#end if((STITCH_end - STITCH_start) > 20 * buffer)
	
	######################################
	### sequence "right" of centromere ###
	######################################
	STITCH_start = centromere.stop+shift
	STITCH_end = chr_length-shift

	if((STITCH_end - STITCH_start) > 20 * buffer){
		print(paste("Running STITCH for right-side of ",chr,"...",sep=""))
		output_folder = paste(output_prefix,"_",chr,"_right",sep="")

		STITCH(
			bamlist = bam_list,
			sampleNames_file = name_list,
			outputdir = output_folder,
			method = "diploid",
			regenerateInput = TRUE,
			regionStart = STITCH_start,
			regionEnd = STITCH_end,
			buffer = buffer,
			niterations = 1,
			chr = chr,
	#		reference_populations = c("CEU", "GBR", "ACB"),#this is a reference set of 286 samples
			reference_populations = c("CEU"),#this is a reference set of 99 samples		
			reference_haplotype_file = human_reference_haplotype_file,
			reference_sample_file = human_reference_sample_file,
			reference_legend_file = human_reference_legend_file,
			posfile = human_posfile,
			shuffleHaplotypeIterations = NA,
			refillIterations = NA,
			K = human_K, tempdir = temp_folder, nCores = 1, nGen = human_nGen)
	}#end if((STITCH_end - STITCH_start) > 20 * buffer)
}#end for (chr in autosomal_chr)
