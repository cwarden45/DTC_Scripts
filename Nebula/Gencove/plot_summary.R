#setwd("E:\\WGS_Exome_Analysis\\My_Veritas_WGS\\Nebula\\Gencove")

IBD_cat   = c("assume-het")
num_reads = c(4563716)
IBD_value = c(0.237397)
dot_col   = c("black")

png("low_coverage_self_recovery.png")
plot(num_reads, IBD_value,
	ylab = "plink KING kinship value", xlab="number of reads",
	xlim = c(50000,10000000),ylim=c(-0.6,0.6), pch=16, col=dot_col)
abline(h=0.5, col="green", lwd=1)
rect(-1000000, 0.45, 100000000, 0.5, col=rgb(red=0.2, green=0.8, blue=0.2, alpha=0.5), border=NA)
rect(-1000000, 0.35, 100000000, 0.45, col=rgb(red=0.5, green=0.5, blue=0.5, alpha=0.5), border=NA)
rect(-1000000, 0.2, 100000000, 0.35, col=rgb(red=0.2, green=0.2, blue=0.2, alpha=0.5), border=NA)
rect(-1000000, -0.7, 100000000, 0.2, col=rgb(red=1, green=0, blue=0, alpha=0.5), border=NA)
box()

legend("bottom",
		legend = c("assume-het","Gencove-human","Gencove-cat","STITCH-human"),
		col=c("black","blue","cyan","purple"),
		inset = 0.02, pch=16, ncol=4, cex=0.8)
dev.off()