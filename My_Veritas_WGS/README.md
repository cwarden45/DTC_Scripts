### For Research Purposes Only! ###

**Step #1**) Download .bam.tgz and .vcf.gz files

1a) Extract the per-chromosome .bam files (the [ID].bam.tgz file) into a folder called "chr_bam".  On Windows, you can do this using [7zip](http://www.7-zip.org/).

**Step #2**) Download IGV: https://www.broadinstitute.org/software/igv/download

**Make sure you have [JRE](http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html) installed on your computer

At this point, you can already visualize your genomic alignment (separately for each chromosome)

**Step #3**) Download [Docker](https://docs.docker.com/engine/installation/) and Dependencies from Docker Image: `docker pull cwarden45/dnaseq-dependencies`

If you download [Docker Toolbox](https://www.docker.com/products/docker-toolbox) for your PC, you also also add Git during the installation process.

On Windows, if you run `git clone https://github.com/cwarden45/DNAseq_templates` in your Documents folder, then you will re-create the path I use in the next step (with your own username).  Strictly speaking, you don't need git to run the next steps, but you will have to copy and paste the contents of each script you want to run (in a plain-text editor, like [Notepad++](https://notepad-plus-plus.org/)).  If you try to save the GitHub links to target files, you'll likely end up with an .html file instead of a .py or .pl file.

**Step #4**) Combine, remove duplicates, and re-index your .bam files

4a) Open an interactive Docker session, with access to the folder containing your .bam file (or the folder containing these scripts).  For example, on Windows, your command will likely look something like:

```
docker run -it -v /c/Users/Charles/Documents/DNAseq_templates/My_Veritas_WGS:/mnt/wgs cwarden45/dnaseq-dependencies
```

4b) Move the folder containing the .bam file (run `cd /mnt/wgs`)

4c) If the scripts and BAM folder (named *chr_bam*) are in the same directory, run `python combine_bams.py`.  Otherwise, you can specify the full file path using `python combine_bams.py --bam_folder=chr_bam`

The Java memory limit is set to 4GB (4g).  If you have more memory (and have allocated extra memory/CPU to docker), you can change this setting via `python combine_bams.py --java_mem=4g`.  You can also decrease the memory requirements, but the script already takes a few hours to run (with default settings) on my PC with 8 GB RAM and 4 CPU (with 5 GB RAM and 4 CPU allocated to the Docker VM).  Run `python combine_bams.py --help` for more information.`

If everything works correctly, you can delete the *veritas_wgs.bam* file after the script stops running.

Now, you can visualize coverage for all chromosomes simultaneously in IGV. After loading veritas_wgs.sort.filtered.bam in IGV, go to Tools --> igvtools --> count (produces veritas_wgs.sort.filter.bam.tdf file).  You might want to increase the window size to produce the .tdf file more quickly (perhaps try 200+ bp), but I was able to keep the 25 bp window without any problems.

**Step #5**) Produce [snpEff](http://snpeff.sourceforge.net/index.html) variant summary

5a) You can produce an HMTL summary of functional annotations for your variants (within the Docker container) by running `python run_SnpEff.py --input=[ID].vcf`.  The HTML file will be called "snpEff_summary.html".  It might take a few hours to produce this file.

5b) If you run the scripts in the "Advanced Users" section, you can also use snpEff to add gene annotations to your structural variant calls.

### For Advanced Users ###

**1**) Use [ANNOVAR](http://annovar.openbioinformatics.org/en/latest/user-guide/download/) for additional annotations

You can download ANNOVAR [here](http://www.openbioinformatics.org/annovar/annovar_download_form.php).  It is free for private use, but you will be encouraged to buy a commerical license if you provide a .com e-mail address.  So, it would be best if you could provide an educational or non-profit e-mail address.

The script assumes that the ANNOVAR code as been extracted in the same directory as your .vcf file (in a folder called "annovar").  Assuming that is the case, you can use `python run_ANNOVAR.py --vcf=[ID].vcf` to annotate your variants.

You can see the ANNOVAR [ClinVar](http://www.ncbi.nlm.nih.gov/clinvar/) annotations in **annovar_[file name].hg19_clinvar_20160302_dropped**.

**2**) Make additional structural variant calls using [DELLY](https://github.com/tobiasrausch/delly) (via `python run_DELLY.py`), [LUMPY](https://github.com/arq5x/lumpy-sv) (via `python run_LUMPY.py`), [GASVPro](http://compbio.cs.brown.edu/projects/gasv/) (via `python run_GASVPro.py`), and/or [Manta](https://github.com/Illumina/manta) (via `python run_Manta.py`).

- In order to run DELLY, you must first run `python download_ref.py`.  You will be asked to enter your e-mail address as a password.
- Delly is [Dockerized](https://hub.docker.com/r/trausch/delly/), so you can download and run the Docker container (used with the script) with a command similar to this one:

```
docker run -it -v /c/Users/Charles/Documents/DNAseq_templates/My_Veritas_WGS:/mnt/wgs trausch/delly
```

- You will probably need to allow a few hours for these programs to run.
- You can get an idea about how the size of the deletions/duplications/insertions compare for DELLY/LUMPY versus those provided in the Vertias .vcf file by running:
```
python vcf_to_bed.py --vcf=[file.vcf] --caller=[Veritas/LUMPY/DELLY_DEL/DELLY_DUP/DELLY_INS]
```
Run `python vcf_to_bed.py --help` for more information.

- You should probably also filter putative deletions based upon coverage in order to reduce false positives.  I've provided a script to accomlish this:

```
python DEL_cov_filter.py --bed=[LUMPY_DEL.bed|DELLY_DEL.bed]
```

The same logic would apply to duplications, but I'm focusing on deletions on the assumption that they will be more likely to be deleterious (if they overlap a substantial portion of a genes - if you have more than a handful of filtered hits, you can use `run_SnpEff.py` to find exonic overlaps).

**3**) I've also provided scripts for analyzing 23andMe data in the `23andMe` folder, which I will compare to my WGS variants.  See [README.md](https://github.com/cwarden45/DNAseq_templates/tree/master/My_Veritas_WGS/23andMe) in `23andMe` folder.
