import sys
import re
import os

filteredBam = "veritas_wgs.filter.bam"
javaMem = "-Xmx4g"

print "Create GASV Input"
command = "java -jar " + javaMem + " /opt/gasv/bin/BAMToGASV.jar " + filteredBam + " -GASVPro True"
os.system(command)

print "Run GASV"
gasvInput = filteredBam + ".gasv.in"
command = "java -jar " + javaMem + " /opt/gasv/bin/GASV.jar --output regions --minClusterSize 6 --readlength 150 --batch " + gasvInput
os.system(command)

print "Run GASVPro-CC"
gasvproParam = filteredBam + ".gasvpro.in"
clusters = filteredBam + ".gasv.in.clusters"
command = "/opt/gasv/bin/GASVPro-CC  " + gasvproParam + " " + clusters
os.system(command)

print "Pruning Clusters"
gasvproClusters = filteredBam + ".gasv.in.clusters.GASVPro.clusters"
command = "/opt/gasv/scripts/GASVPruneClusters.pl " + gasvproClusters
os.system(command)

print "Run GASVPro-graph"
gasvproGraphDir = "GASVPro-graph"
command = "mkdir " + gasvproGraphDir
os.system(command)
coverageFile = filteredBam + ".gasv.in.clusters.GASVPro.coverage"
command = "/opt/gasv/bin/GASVPro-graph  " + prunedClusters + " " + coverageFile + " " + gasvproGraphDir + " 6"
os.system(command)

print "Run GASVPro-mcmc"
command = "/opt/gasv/bin/GASVPro-mcmc  " + gasvproParam + " " + gasvproGraphDir
os.system(command)

print "Reformat 3 sets of clusters"
prunedClusters = filteredBam + ".gasv.in.clusters.GASVPro.clusters.pruned.clusters"
command = "/opt/gasv/bin/convertClusters " + clusters + " " + clusters + ".reformat"
os.system(command)
command = "/opt/gasv/bin/convertClusters " + gasvproClusters + " " + gasvproClusters + ".reformat"
os.system(command)
command = "/opt/gasv/bin/convertClusters " + prunedClusters + " " + prunedClusters + ".reformat"
os.system(command)