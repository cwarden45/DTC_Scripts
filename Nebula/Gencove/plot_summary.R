IBD_cat   = c("assume-het",
				"Gencove-human","Gencove-human",
				"Gencove-cat","Gencove-cat",
				"STITCH-ref99","STITCH-ref99","STITCH-ref99","STITCH-ref99","STITCH-ref99",
				"STITCH-ref286","STITCH-ref286","STITCH-ref286","STITCH-ref286","STITCH-ref286")
num_reads = c(4563716,
				4563716, 4563716/2,
				166490724/50,166490724/100,
				4563716, 4563716/2, 4563716/4, 4563716/10, 4563716/20,
				4563716, 4563716/2, 4563716/4, 4563716/10, 4563716/20)
IBD_value = c(0.237397,
				0.489226, 0.499961,
				0.448409, 0.426991,
				0.483219, 0.472075, 0.449329, 0.372013, 0.179748,
				0.485009, NA, 0.452603, 0.370261, 0.157386)
dot_col   = c("black",
				"blue","blue",
				"cyan","cyan",
				"maroon","maroon","maroon","maroon","maroon",
				"purple","purple","purple","purple","purple")

png("low_coverage_self_recovery.png")
plot(num_reads, IBD_value,
	ylab = "plink KING kinship value", xlab="number of reads",
	xlim = c(0,5000000),ylim=c(-0.6,0.6), pch=16, col=dot_col)
abline(h=0.5, col="green", lwd=1)
rect(-1000000, 0.45, 10000000, 0.5, col=rgb(red=0.2, green=0.8, blue=0.2, alpha=0.5), border=NA)
rect(-1000000, 0.35, 10000000, 0.45, col=rgb(red=0.5, green=0.5, blue=0.5, alpha=0.5), border=NA)
rect(-1000000, 0.2, 10000000, 0.35, col=rgb(red=0.2, green=0.2, blue=0.2, alpha=0.5), border=NA)
rect(-1000000, -0.7, 10000000, 0.2, col=rgb(red=1, green=0, blue=0, alpha=0.5), border=NA)
box()

lines(num_reads[IBD_cat == "Gencove-human"],IBD_value[IBD_cat == "Gencove-human"], col="blue", lwd=1)
lines(num_reads[IBD_cat == "Gencove-cat"],IBD_value[IBD_cat == "Gencove-cat"], col="cyan", lwd=1)
lines(num_reads[IBD_cat == "STITCH-ref286"],IBD_value[IBD_cat == "STITCH-ref286"], col="purple", lwd=1)
lines(num_reads[IBD_cat == "STITCH-ref99"],IBD_value[IBD_cat == "STITCH-ref99"], col="maroon", lwd=1)


legend("top",
		legend = c("assume-het","STITCH-ref286",
					"Gencove-human","STITCH-ref99",
					"Gencove-cat"),
		col=c("black","purple","blue","maroon","cyan"),
		pch=16, ncol=3, cex=0.8,
		xpd=T, inset = -0.12)
dev.off()