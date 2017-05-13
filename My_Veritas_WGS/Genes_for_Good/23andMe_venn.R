library("VennDiagram")

#code assumes both files in 23andMe format
table23 = read.table("../23andMe/genome_Charles_Warden_v3_Full.txt", head=F, sep="\t")
tableG4G = read.table("GFG_filtered_unphased_genotypes_23andMe.txt", head=F, sep="\t")

probe23 = table23[,1]
probeG4G = tableG4G[,1]

vennObj = list(probe23=probe23, Genes4Good=probeG4G)
names(vennObj)=c("23andMe","Genes4Good")

venn.diagram(vennObj, filename="probe_name_overlap.png", 
			alpha=c(0.5, 0.5), fill=c("green","blue"),
			cat.cex=c(0.6, 0.6), scaled=T)

#both positions are for hg19, so I can also define overlap by position
probe23 = paste(table23[,2],table23[,3],sep=":")
probeG4G = paste(tableG4G[,2],tableG4G[,3],sep=":")

vennObj = list(probe23=probe23, Genes4Good=probeG4G)
names(vennObj)=c("23andMe","Genes4Good")

venn.diagram(vennObj, filename="probe_position_overlap.png", 
			alpha=c(0.5, 0.5), fill=c("green","blue"),
			cat.cex=c(0.6, 0.6), scaled=T)

#uses implementation of 'VennDiagram' function in limma.
#mostly a reminder for an alternative code (to either VennDiagram or Vennerable), but without proporitional circles
#library("limma")
#totalProbes = union(probe23, probeG4G)
#status23=rep(0,length(totalProbes))
#status23[match(probe23,totalProbes)]=1
#statusG4G=rep(0,length(totalProbes))
#statusG4G[match(probeG4G,totalProbes)]=1
#status.table = data.frame(status23, statusG4G)
#status.table = as.matrix(status.table)
#colnames(status.table)=c("23andMe","Genes4Good")
#vennObj = vennCounts(status.table, include="up")
#vennDiagram(vennObj, circle.col=c("green","blue"), cex=c(0.4,1,1))

