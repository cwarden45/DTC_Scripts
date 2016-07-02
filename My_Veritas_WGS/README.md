### For Research Purposes Only! ###

**Step #1**) Download .bam.tgz and .vcf.gz files

1a) Extract the per-chromosome .bam files (the [ID].bam.tgz file) into a folder called "chr_bam".  On Windows, you can do this using [7zip](http://www.7-zip.org/).

**Step #2**) Download IGV: https://www.broadinstitute.org/software/igv/download

**Make sure you have [JRE](http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html) installed on your computer

At this point, you can already visualize your genomic alignment (separately for each chromosome)

**Step #3**) Download [Docker](https://docs.docker.com/engine/installation/) and Dependencies from Docker Image: `docker pull cwarden45/dnaseq-dependencies`

If you download [Docker Toolbox](https://www.docker.com/products/docker-toolbox) for your PC, you also also add Git during the installation process.

On Windows, if you run `git clone https://github.com/cwarden45/DNAseq_templates` in your Documents folder, then you will re-create the path I use in the next step (with your own username).  Strictly speaking, you don't need git to run the next steps, but you will have to copy and paste the contents of each script you want to run (in a plain-text editor, like [Notepad++](https://notepad-plus-plus.org/)).  If you try to save the GitHub links to target files, you'll likely end up with an .html file instead of a .py or .pl file.

**Step #4**) Combine and re-index your .bam files

4a) Open an interactive Docker session, with access to the folder containing your .bam file (or the folder containing these scripts).  For example, on Windows, your command will likely look something like:

```
docker run -it -v /c/Users/Charles/Documents/DNAseq_templates/My_Veritas_WGS:/mnt/wgs cwarden45/dnaseq-dependencies
```

4b) Move the folder containing the .bam file (run `cd /mnt/wgs`)

4c) Run ``


### For Advanced Users ###

I've also provided scripts for analyzing 23andMe data in the `23andMe` folder, which I will compare to my WGS variants
