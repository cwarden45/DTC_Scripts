args <- commandArgs(trailingOnly = TRUE)

bed = args[1]
print(paste("BED Input: ",bed,sep=""))
caller = args[2]
print(paste("Variant caller: ",caller,sep=""))
output.file = gsub(".bed$",".png",bed)
print(paste("Histrogram Output: ",output.file,sep=""))

bed.table = read.table(bed,sep="\t", head=F)
print(dim(bed.table))

x.label = "SV size (bp)"
if (caller == "Veritas"){
	x.label  = "Var vs. Ref Length Difference (bp)"
}

if ((caller == "Veritas")|(caller == "LUMPY")){
	caller = gsub(".bed$","",bed)
}

png(output.file)
size = bed.table[,5]

med.size = size[(size > 50) & (size < 5000)]
percent.med = round(100*length(med.size)/length(size),digits=1)

subtitle = paste("n=",length(size),", median = ",round(median(size, na.rm=T))," bp",
					", Percent(50bp-5kb)=",percent.med,"%",sep="")

hist(size, col="blue", xlab=x.label, main = paste(caller,"Variants",sep=" "))
mtext(subtitle, side=3)
dev.off()