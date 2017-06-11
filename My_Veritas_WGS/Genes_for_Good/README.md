[Genes for Good](https://genesforgood.sph.umich.edu/) is crowd-sourced study on genetic variation using SNP chips.  So, it is similar to 23andMe, except it is free for participants and different types of results are provided (and the SNP chips are not identical).

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
      <td align="center">A</td>
      <td align="center">A*01,A*02</td>
      <td align="center">A*01,A*02</td>
      <td align="center">A*01,A*02</td>
      <td align="center">A*01,A*02 (BWA-MEM)<br/>A*01,A*68 (BWA)</td>
      </tr>
  </tbody>
</table>


For SNP chips, the [dbSNP](https://www.ncbi.nlm.nih.gov/projects/SNP/) rsIDs (or, more precisely, the snpID) rather than chromosomal position is used for HLA2SNP and HIBAG.  In the case of HIBAG, there was an error message for my Genes for Good file (which I created from the 23andMe-formated genotype file) due to duplicate snpIDs.
