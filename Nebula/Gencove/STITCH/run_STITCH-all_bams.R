bam_list = "28_1000_Genomes-plus-Nebula_provided-bams.txt"
name_list = "28_1000_Genomes-plus-Nebula_provided-names.txt"
output_prefix = "STITCH-all_bam-Nebula_provided"
pos_folder = "../STITCH_Gencove/human_g1k_v37-pos_files"

autosomal_chr = 1:22
fa_index =  "Ref/human_g1k_v37.fasta.fai"

fa_index.table = read.table(fa_index, head=F, sep="\t")

library("STITCH")
#from https://github.com/rwdavies/STITCH/blob/master/examples/examples.R
human_K = 10
human_nGen = 4 * 20000 / human_K
temp_folder = tempdir()

for (chr in autosomal_chr){
	print(paste("Running STITCH and indexing for ",chr,"...",sep=""))
	human_posfile = paste(pos_folder,"/",chr,"_pos.txt",sep="")
	output_folder = paste(output_prefix,"_",chr,sep="")
	STITCH(
	  bamlist = bam_list,
	  sampleNames_file = name_list,
	  outputdir = output_folder,
	  posfile = human_posfile,
	  method = "diploid",
	  regenerateInput = TRUE,
	  regionStart = 1,
	  regionEnd = fa_index.table$V2[fa_index.table$V1 == chr],
	  buffer = 10000,
	  niterations = 20,
	  chr = chr,
	  inputBundleBlockSize = 100,
	  shuffleHaplotypeIterations = NA,
	  refillIterations = NA,
	  K = human_K, tempdir = temp_folder, nCores = 1, nGen = human_nGen)
	  
	vcfGZ =  paste("STITCH-all_bam-Nebula_provided_",chr,"/stitch.",chr,".1.",fa_index.table$V2[fa_index.table$V1 == chr],".vcf.gz",sep="", collapse=" ")
	command = paste("/opt/htslib/tabix -p vcf ",vcfGZ,sep="")
	#print(command)
	system(command)
}#end for (chr in autosomal_chr)

##I get an error with this message
#input_arr = paste("I=STITCH-all_bam-Nebula_provided_",autosomal_chr,"/stitch.",autosomal_chr,".1.",fa_index.table$V2[match(autosomal_chr,fa_index.table$V1)],".vcf.gz",sep="", collapse=" ")
#command = paste("java -jar /opt/picard-v2.21.9.jar MergeVcfs ",
#				input_arr,
#				" O=all-bam_merged.vcf.gz",
#				" D=Ref\\human_g1k_v37.dict", collapse="")
				
##this almost works, but samples appear in separate column per chromosome.  I also want to extract just my genotype, so leave that for subsequent code
#input_arr = paste("STITCH-all_bam-Nebula_provided_",autosomal_chr,"/stitch.",autosomal_chr,".1.",fa_index.table$V2[match(autosomal_chr,fa_index.table$V1)],".vcf.gz",sep="", collapse=" ")
#command = paste("/opt/bcftools-1.10.2/bcftools merge ",
#				input_arr,
#				" --force-samples -Ov -o all-bam_merged.vcf", collapse="")				
#print(command)
#system(command)