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

4c) Download the reference genome (*hg19.fasta*) by running `python download_ref.py`.   You will be asked to enter your e-mail address as a password.

4d) If the scripts and BAM folder (named *chr_bam*) are in the same directory, run `python combine_bams.py`.  Otherwise, you can specify the full file path using `python combine_bams.py --bam_folder=chr_bam`

The Java memory limit is set to 4GB (4g).  If you have more memory (and have allocated extra memory/CPU to docker), you can change this setting via `python combine_bams.py --java_mem=4g`.  You can also decrease the memory requirements, but the script already takes a few hours to run (with default settings) on my PC with 8 GB RAM and 4 CPU (with 5 GB RAM and 4 CPU allocated to the Docker VM).  Run `python combine_bams.py --help` for more information.`

If everything works correctly, you can delete the *veritas_wgs.bam* and *veritas_wgs.sort.bam* files after the script stops running.

Now, you can visualize coverage for all chromosomes simultaneously in IGV. After loading veritas_wgs.sort.filtered.bam in IGV, go to Tools --> igvtools --> count (produces veritas_wgs.sort.filter.bam.tdf file).  You might want to increase the window size to produce the .tdf file more quickly (perhaps try 200+ bp), but I was able to keep the 25 bp window without any problems.

### For Advanced Users ###

I've also provided scripts for analyzing 23andMe data in the `23andMe` folder, which I will compare to my WGS variants
