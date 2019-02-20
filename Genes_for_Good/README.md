### For Research Purposes Only! ###

[Genes for Good](https://genesforgood.sph.umich.edu/) is crowd-sourced study on genetic variation using SNP chips.  So, it is similar to 23andMe, except it is free for participants and different types of results are provided (and the SNP chips are not identical).

```diff
+ Overall, I  would recommend Genes for Good for genotyping (with or without 23andMe testing).
+ In addition to being free, they provided the most raw data formats to use with 3rd party software
+ They also provided the most information about different pre-procesessing steps (to generate different sets of genotypes for the same sample).
```

My 23andMe sample is from several years ago, on their V3 chip.  My Genes for Good sample was collected a couple years ago.  So, I don't know exactly how the latest results would compare, but I've provided a Venn Diagram below showing the overlap of probes (based upon genomic position, which is similar but slightly better than using the probe name):

![alt text](probe_position_overlap.png "SNP chip Probe Position Overlap")

Raw data is provided in a few different formats, including .vcf format and 23andMe raw data format.  So, most of the scripts for analyzing 23andMe data can also be applied to Genes for Good data.

So, I am going to mostly use this page for notes on HLA typing with my different genomics technologies.  Namely, there was a [recent study](https://www.ncbi.nlm.nih.gov/pubmed/28490672) using imputed HLA types from SNP chip data, so I would like to test how my own imputed results compare to those from Illumina DNA-Seq (mostly from Genos Exome .fastq files, since the Veritas WGS raw data was a set of bams with aligned reads for each canonical chromosome, with a noticable drop in coverage in the highly variable HLA region on chr6).


<table>
  <tbody>
    <tr>
      <th align="center">Marker</th>
      <th align="center">SNP2HLA</th>
      <th align="center">HIBAG</th>
      <th align="center">bwakit</th>
      <th align="center">HLAminer</th>
    </tr>
    <tr>
      <td align="center">HLA-A</td>
      <td align="left">A*01, A*02<br/>(23andMe)<br/><br/>A*01, A*02<br/>(Genes for Good)</td>
      <td align="left">A*01, A*02<br/>(23andMe)</td>
      <td align="left">A*01, A*02<br/>(Genos Exome BWA-MEM)</td>
      <td align="left">A*01, A*02<br/>(Genos Exome BWA-MEM)<br/><br/>A*01, A*68<br/>(Genos Exome BWA)</td>
     </tr>
    <tr>
      <td align="center">HLA-B</td>
      <td align="left">B*08, B*40<br/>(23andMe)<br/><br/>B*08, B*40<br/>(Genes for Good)</td>
      <td align="left">B*08, B*40<br/>(23andMe)</td>
      <td align="left">B*08, B*40<br/>(Genos Exome BWA-MEM)</td>
      <td align="left">B*08, B*40<br/>(Genos Exome BWA-MEM)<br/><br/>B*08, B*41<br/>(Genos Exome BWA)</td>
     </tr>
    <tr>
      <td align="center">HLA-C</td>
      <td align="left">C*03, C*07<br/>(23andMe)<br/><br/>C*03, C*07<br/>(Genes for Good)</td>
      <td align="left">C*03, C*07<br/>(23andMe)</td>
      <td align="left">C*03, C*07<br/>(Genos Exome BWA-MEM)</td>
      <td align="left">C*03, C*07<br/>(Genos Exome BWA-MEM)<br/><br/>C*03, C*07<br/>(Genos Exome BWA)</td>
     </tr>
    <tr>
      <td align="center">HLA-DRB1</td>
      <td align="left">DRB1*01, DRB1*03<br/>(23andMe)<br/><br/>DRB1*01, DRB1*03<br/>(Genes for Good)</td>
      <td align="left">DRB1*03, DRB1*11<br/>(23andMe)</td>
      <td align="left">DRB1*04, DRB1*04<br/>(Genos Exome BWA-MEM)</td>
      <td align="left">DRB1*01, DRB1*15<br/>(Genos Exome BWA-MEM)<br/><br/>DRB1*01, DRB1*15<br/>(Genos Exome BWA)</td>
     </tr>
     <tr>
      <td align="center">HLA-DQA1</td>
      <td align="left">DQA1*05, DQA1*05<br/>(23andMe)<br/><br/>DQA1*01, DQA1*05<br/>(Genes for Good)</td>
      <td align="left">DQA1*05, DQA1*05<br/>(23andMe)</td>
      <td align="left">DQA1*03, DQA1*03<br/>(Genos Exome BWA-MEM)</td>
      <td align="left">DQA1*02, DQA1*03<br/>(Genos Exome BWA-MEM)<br/><br/>DQA1*02, DQA1*03<br/>(Genos Exome BWA)</td>
     </tr>
     <tr>
      <td align="center">HLA-DQB1</td>
      <td align="left">DQB1*02, DQB1*05<br/>(23andMe)<br/><br/>DQB1*02, DQB1*02<br/>(Genes for Good)</td>
      <td align="left">DQB1*02, DQB1*03<br/>(23andMe)</td>
      <td align="left">DQB1*03, DQB1*03<br/>(Genos Exome BWA-MEM)</td>
      <td align="left">DQB1*02, DQB1*03<br/>(Genos Exome BWA-MEM)<br/><br/>DQB1*02, DQB1*03<br/>(Genos Exome BWA)</td>
     </tr>
</tbody>
</table>

So, for the Genos Exome Alignments, HLAminer assignments were more similar to bwakit if using BWA-MEM instead of BWA for HLA-A and HLA-B (and bwakit / HLAminer made the same assignments for HLA-C, HLA-DQA1, and HLA-DQB1), but there were discrepancies for the top DRB1 assignments (between the Exome HLA calls).

For HLA-A, HLA-B, and HLA-C, the imputed HLA types from the SNP chips match the BWA-MEM HLA assignments (for either HLAtype or bwakit).

For SNP chips, the [dbSNP](https://www.ncbi.nlm.nih.gov/projects/SNP/) rsIDs (or, more precisely, the snpID in the genotype file) rather than chromosomal position is used for HLA2SNP and HIBAG.  In the case of HIBAG, there was an error message for my Genes for Good file (which I created from the 23andMe-formated genotype file) due to duplicate snpIDs.

Other Notes
-----------------

I also liked that they described limitations to the ancestry predictions within Genes for Good.  For example, I copied the following warning verbatim (which I hope is OK):

*Please note: it is not possible to assign correct ancestry to all locations in the genome. Thus, some short regions may have been assigned to populations that you are not descended from. Potential reasons include errors in the DNA measurements, flaws in the statistical model that assigns ancestry, or a segment of your DNA just happens to be more similar to a sequence that is more common in another population. Attempting to correct for these errors could introduce biases, so we chose to pass on the results unfiltered and encourage you to critically consider this information when attempting to understand your genetic origins.*

*In particular, the Genes for Good team noticed that*

- *Central and South Asian ancestry, and Native American ancestry, was often assigned to chromosomal segments of individuals who appear to actually have East Asian or European Ancestry, and vice-versa.*
- *West Asian and North African Ancestry was often assigned to some portions of individuals who appear to actually have European ancestry and vice-versa.*

I mention this because I would otherwise note that some chromosome painting results seemed like they may be false positives (even though my pie chart was 99% European, and I was clearly in the European cluster in the PCA plot).  However, with this warning, I feel very comfortable with the overall results (and, most importantly, the raw data), particulary given that they were free.
