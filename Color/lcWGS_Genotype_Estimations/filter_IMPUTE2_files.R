autosomal_chr = 1:22

for (chr in autosomal_chr){
	human_posfile = paste(chr,"_pos.txt",sep="")
	
	input_hap =  paste("1000GP_Phase3_chr",chr,".hap.gz",sep="")
	input_legend =  paste("1000GP_Phase3_chr",chr,".legend.gz",sep="")

	output_hap =  paste(chr,"_hap.txt",sep="")
	output_legend =  paste(chr,"_legend.txt",sep="")

	#create STITCH position file
	if(!(file.exists(human_posfile))){
		print(paste("Generating full position file for chromosome ",chr,"...",sep=""))
		#use code modified from STITCH troubleshooting suggestion: https://github.com/rwdavies/STITCH/issues/29#issuecomment-601192607
		library("data.table")
		temp.legend = fread(cmd = paste0("gunzip -c ", input_legend), sep = " ", head=T)
		#even though I can extract the informaton from the above file, I think it is faster to just use the following (provided) command
		pos2 = fread(cmd = paste0("gunzip -c ", input_legend), data.table = FALSE)
		pos = cbind(chr, pos2[, 2], pos2[, 3], pos2[, 4])
		matchableID = apply(pos,1,paste,collapse=":")#some values start with rsID instead of chromosome (so, I need this to compare the original legend file)
		pos.counts =  table(pos2[, 2])
		print(table(pos.counts))
		pos.counts = pos.counts[pos.counts == 1]
		#file needs to be sorted for STITCH (with unique positions)
		print(dim(pos))
		#remove sites with multiple variants at the same position
		pos = pos[match(names(pos.counts), pos2[, 2]),]
		print(dim(pos))
		#only include SNPs
		refNuc = pos[, 3]
		names(refNuc) = pos[, 2]
		refNucLen = sapply(refNuc, nchar)
		refNucLen = refNucLen[match(as.character(pos[, 2]), names(refNucLen))]
		refNucLen[is.na(refNucLen)]=0
		refNucLen =  as.numeric(refNucLen)

		varNuc = pos[, 4]
		names(varNuc) = pos[, 2]
		varNucLen = sapply(varNuc, nchar)
		varNucLen = varNucLen[match(as.character(pos[, 2]), names(varNucLen))]
		varNucLen[is.na(varNucLen)]=0
		varNucLen =  as.numeric(varNucLen)		
		
		pos = pos[(refNucLen == 1)&(varNucLen == 1),]
		print(dim(pos))
		
		kept.pos = apply(pos,1,paste,collapse=":")
		kept_rows = match(kept.pos, matchableID)
		
		write.table(pos,
					human_posfile,
					sep = "\t",
					quote = FALSE,
					row.names = FALSE,
					col.names = FALSE)
		rm(pos.counts)
		rm(refNuc)
		rm(refNucLen)
		rm(varNuc)
		rm(varNucLen)
		rm(pos)
		rm(pos2)
		#######################################################
		### create matched / filtered STITCH legend file	###
		#######################################################
		print(paste("Generating matched, filtered legend file for chromosome ",chr,"...",sep=""))
		print(dim(temp.legend))
		kept_rows = kept_rows[!is.na(kept_rows)]#I am not sure why there are missing values, but this is still a lot more than I planned on using
		temp.legend = temp.legend[kept_rows, ]
		print(dim(temp.legend))
		write.table(temp.legend,
					output_legend,
					sep = " ",
					quote = FALSE,
					row.names = FALSE,
					col.names = TRUE)
		rm(temp.legend)

		command = paste("gzip ",output_legend,sep="")
		system(command)

		#######################################################
		### create matched / filtered STITCH haplotype file	###
		#######################################################
		print(paste("Generating matched, filtered haplotype file for chromosome ",chr,"...",sep=""))
		uncompressed.file = gsub(".gz$","",input_hap)
		print(paste("Decompressing ",input_hap,"...",sep=""))
		command = paste("gunzip -c ",input_hap," > ",uncompressed.file,sep="")
		system(command)
		print(paste("Extracting desired rows from ",uncompressed.file,"...",sep=""))
		temp.count.file = "temp_count.txt"
		write.table(data.frame(pos=kept_rows), temp.count.file, row.names=F, col.names=F, quote=F)

		command = paste("perl extract_desired_rows.pl ",uncompressed.file," ",temp.count.file," ",output_hap,sep="")
		system(command)
		
		rm(kept.pos)
		command = paste("rm ",uncompressed.file,sep="")
		system(command)
		command = paste("rm ",temp.count.file,sep="")
		system(command)

		command = paste("gzip ",output_hap,sep="")
		system(command)
	}#end def if(!(file.exists(human_posfile)))
}#end 
