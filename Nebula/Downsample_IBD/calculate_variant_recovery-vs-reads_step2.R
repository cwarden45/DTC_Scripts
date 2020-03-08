#setwd("E:\\WGS_Exome_Analysis\\My_Veritas_WGS\\STITCH\\lcWGS_Genotype_Estimations")

K1G_file = "variant_recovery-1000_genomes_20140502_plus_2-SNP-chip.txt"
WGS_file = "variant_recovery-Veritas_WGS.txt"

K1G.table = read.table(K1G_file, head=T, sep="\t")
WGS.table = read.table(WGS_file, head=T, sep="\t")

polygon.mat = data.frame(x=c(0,WGS.table$Read.Count,rev(K1G.table$Read.Count)), y=c(0,WGS.table$Recovered.Var,rev(K1G.table$Recovered.Var)))

png("1read_SNP_recovery.png")
par(mfcol=c(1,3))
#full plot
plot(WGS.table$Read.Count, WGS.table$Recovered.Var,
	type = "l", col="gray", lwd=2,
	xlab="Read Count", ylab="Recovered SNPs")
lines(K1G.table$Read.Count, K1G.table$Recovered.Var,
		col="black",lwd=2)
abline(h=1000, col="orange")
abline(h=500, col="red")
polygon(polygon.mat, col=rgb(red=1, green=1, blue=0, alpha=0.5), border=NA)
legend("topleft",
		legend=c("WGS SNPs","1000 Genomes Example"),
		col = c("gray","black"), lwd=2, cex=0.7)
#zoomed plot
plot(WGS.table$Read.Count, WGS.table$Recovered.Var,
	type = "l", col="gray", lwd=2,
	xlab="Read Count", ylab="Recovered SNPs",
	xlim=c(0,400000), ylim=c(0,2000))
lines(K1G.table$Read.Count, K1G.table$Recovered.Var,
		col="black",lwd=2)
abline(h=1000, col="orange")
abline(h=500, col="red")
polygon(polygon.mat, col=rgb(red=1, green=1, blue=0, alpha=0.5), border=NA)
legend("topright",
		legend=c("WGS SNPs","1000 Genomes Example"),
		col = c("gray","black"), lwd=2, cex=0.7)
#zoomed plot2
plot(WGS.table$Read.Count, WGS.table$Recovered.Var,
	type = "l", col="gray", lwd=2,
	xlab="Read Count", ylab="Recovered SNPs",
	xlim=c(0,20000), ylim=c(0,2000))
lines(K1G.table$Read.Count, K1G.table$Recovered.Var,
		col="black",lwd=2)
abline(h=1000, col="orange")
abline(h=500, col="red")
polygon(polygon.mat, col=rgb(red=1, green=1, blue=0, alpha=0.5), border=NA)
legend("topleft",
		legend=c("WGS SNPs","1000 Genomes Example"),
		col = c("gray","black"), lwd=2, cex=0.7)
dev.off()