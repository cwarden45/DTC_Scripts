### For Research Purposes Only! ###

**Step #1**) Download .bam.tgz and .vcf.gz files

4a) Extract the per-chromosome .bam files (the [ID].bam.tgz file) into a folder called "chr_bam"

**Step #2**) Download IGV: https://www.broadinstitute.org/software/igv/download

**Make sure you have [JRE](http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html) installed on your computer

At this point, you can already visualize your genomic alignment (separately for each chromosome)

**Step #3**) Download [Docker](https://docs.docker.com/engine/installation/) and Dependencies from Docker Image: `docker pull cwarden45/dnaseq-dependencies`

**Step #4**) Index your .bam file to view in IGV

4a) Open an interactive Docker session, with access to the folder containing your .bam file.  For example, on Windows, your command will likely look something like:

```
docker run -it -v /c/Users/Charles/Documents/My_Veritas_WGS:/mnt/wgs cwarden45/dnaseq-dependencies
```

4b) Move the folder containing the .bam file (for example, `cd /mnt/wgs`)

4c) Run ``


### For Advanced Users ###

I've also provided scripts for analyzing 23andMe data in the `23andMe` folder, which I will compare to my WGS variants
