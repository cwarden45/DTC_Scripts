![estimated genotype recovery](low_coverage_self_recovery-n5.png "estimated genotype recovery")

I have uploaded the imputed .vcf files for myself to my [Personal Genome Project page](https://my.pgp-hms.org/profile/hu832966).

At least currently, I have uploaded the imputed .vcf files for my cat (Bastu) on Google Cloud at the following locations:

**Down-Sample 50x**:

[Gencove_basepaws-cat_downsample_50x_impute-vcf.vcf.gz](https://storage.googleapis.com/bastu-cat-genome/Gencove_basepaws-cat_downsample_50x_impute-vcf.vcf.gz)

**Down-Sample 100x**:

[Gencove_basepaws-cat_downsample_100x_impute-vcf.vcf.gz](https://storage.googleapis.com/bastu-cat-genome/Gencove_basepaws-cat_downsample_100x_impute-vcf.vcf.gz)

There is also more information about the original data for my cat [here](https://github.com/cwarden45/Bastu_Cat_Genome).

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
      	<th align="center">% full recovery</br>(% partial recovery)</th>
	<th align="center">% full recovery</br>(% partial recovery)</th>
	<th align="center">% full recovery </br>(% partial recovery)</th>
    </tr>
    <tr>
	<th align="center">basepaws-Downsample-100x</br>(cat)</th>
      	<th align="center">% full recovery</br>(% partial recovery)</th>
	<th align="center">% full recovery</br>(% partial recovery)</th>
	<th align="center">% full recovery</br>(% partial recovery)</th>
    </tr>
</tbody>
</table>

Please note that the relatedness/kinship calculation uses the 1000 Genomes overlapping sites for human, whereas the custom script compares my WGS data to my Gencove imputated data (considering a larger number of sites, although the statistics in the table above are only for positions that vary from the reference sequence).

You can also see similar results for the imputed .gVCF provided from Nebula in [this blog post](http://cdwscience.blogspot.com/2019/08/low-coverage-sequencing-is-not.html).  For example, it looks like recovery of the new set of genotypes (from Gencove re-analysis) is a little higher than the provided set of imputed genotypes.
