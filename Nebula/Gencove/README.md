![estimated genotype recovery](low_coverage_self_recovery.png "estimated genotype recovery")

I started using a bam-only alignment to start testing the STITCH code, but I got much better performance when using the 1000 Genomes samples as higher confidence genotype references for my imputation.  While including more reads and/or reference .bams may help, this already became more of an issue on my local computer.  ***NOTE*: So, instead of using the scripts in the "STITCH" subfolder of this subfolder, I ran analysis with the much larger number of sites from the [IMPUTE2 reference set](https://mathgen.stats.ox.ac.uk/impute/impute_v2.html#reference), as recommended by the [developer](https://github.com/rwdavies/STITCH/issues/29).**  It is currently hard to see (the maroon dot in the partially transparent green region looks grey), but the STITCH results so far look compariable to Gencove.  Additional details for running STITCH in this way can be found [here](https://github.com/cwarden45/DTC_Scripts/tree/master/Color/lcWGS_Genotype_Estimations).

I have uploaded the imputed .vcf files for myself to my [Personal Genome Project page](https://my.pgp-hms.org/profile/hu832966).

At least currently, I have uploaded the imputed .vcf files for my cat (Bastu) on Google Cloud at the following locations:

**Down-Sample 50x**:

[Gencove_basepaws-cat_downsample_50x_impute-vcf.vcf.gz](https://storage.googleapis.com/bastu-cat-genome/Gencove_basepaws-cat_downsample_50x_impute-vcf.vcf.gz)

**Down-Sample 100x**:

[Gencove_basepaws-cat_downsample_100x_impute-vcf.vcf.gz](https://storage.googleapis.com/bastu-cat-genome/Gencove_basepaws-cat_downsample_100x_impute-vcf.vcf.gz)

There is also more information about the original data for my cat [here](https://github.com/cwarden45/Bastu_Cat_Genome).  To be fair, it might be worth taking into consideration that [~30% of the fragments](https://github.com/cwarden45/Bastu_Cat_Genome/tree/master/Basepaws_Notes/Read_QC) were smaller than the insert size for the higher coverage sequencing data for my cat: this causes the adapters to be seqeunced, and it drops the true amount of genomic coverage.  As mentioned in [this blog post](https://google.github.io/deepvariant/posts/2019-09-10-twenty-is-the-new-thirty-comparing-current-and-historical-wgs-accuracy-across-coverage/), having 15x coverage instead of 20x coverage may have some effect on the results.

A slight increase or decrease should probably be thought of as a flat line.  In terms of possibly more intuitive numbers, here is the variant recovery with a custom script (described in [this blog post](http://cdwscience.blogspot.com/2019/05/precisionfda-and-custom-scripts-for.html)):

<table>
  <tbody>
    <tr>
	<th align="center">Gencove Input</th>
	<th align="center">SNP WGS Recovery</th>
	<th align="center">Insertion WGS Recovery</th>
	<th align="center">Deletion WGS Recovery</th>
    </tr>
    <tr>
	<th align="center">Nebula-Provided</br>(human)</th>
      	<th align="center">95.5% full recovery</br>(96.9% partial recovery)</th>
	<th align="center">79.6% full recovery</br>(83.7% partial recovery)</th>
	<th align="center">77.6% full recovery</br>(83.8% partial recovery)</th>
    </tr>
    <tr>
	<th align="center">Nebula-Downsample-2x</br>(human)</th>
      	<th align="center">94.9% full recovery</br>(96.8% partial recovery)</th>
	<th align="center">80.0% full recovery</br>(84.3% partial recovery)</th>
	<th align="center">77.7% full recovery</br>(84.3% partial recovery)</th>
    </tr>
      <tr>
	<th align="center">basepaws-Downsample-50x</br>(cat)</th>
      	<th align="center">84.7% full recovery</br>(88.6% partial recovery)</th>
	<th align="center">50.8% full recovery</br>(55.6% partial recovery)</th>
	<th align="center">45.8% full recovery </br>(50.4% partial recovery)</th>
    </tr>
    <tr>
	<th align="center">basepaws-Downsample-100x</br>(cat)</th>
      	<th align="center">83.6% full recovery</br>(88.4% partial recovery)</th>
	<th align="center">51.4% full recovery</br>(56.6% partial recovery)</th>
	<th align="center">46.4% full recovery</br>(51.3% partial recovery)</th>
    </tr>
</tbody>
</table>

Please note that the relatedness/kinship calculation uses the 1000 Genomes overlapping sites for human, whereas the custom script compares my WGS data to my Gencove imputated data (considering a larger number of sites, although the statistics in the table above are only for positions that vary from the reference sequence).

You can also see similar results for the imputed .gVCF provided from Nebula in [this blog post](http://cdwscience.blogspot.com/2019/08/low-coverage-sequencing-is-not.html).  For example, it looks like recovery of the new set of genotypes (from Gencove re-analysis) is a little higher than the provided set of imputed genotypes.

In general, I believe there may also be relevant comparisons in [Wragg et al. 2024](https://gsejournal.biomedcentral.com/articles/10.1186/s12711-024-00875-w), for canine samples.
