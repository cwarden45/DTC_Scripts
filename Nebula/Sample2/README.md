![Replicate PRS Concordance](PRS_Comparison.png "Replicate PRS Concordance")

As shown above, the correlation coefficient between the PRS percentiles for the 2 replicates is 0.8 (with the largest percentile difference being 2% for one replicate and 99% for the other replicate for the “*Bone mineral density (Kemp, 2017)*” PRS).  I double-checked to confirm that this was not a typo on my end.

![APOE visualization](IGV_APOE-Nebula_Sample2.png "APOE Variant Coverage")

In my previous Nebula lcWGS sample, I received a false negative in my APOE E4 heterzgyous variant status (which was supposed to be with relatively high confidence).  This time, the correct genotype of "0/1" was provided in my .vcf file:

```
19	45411941	rs429358	T	C	.	PASS	.	GT:RC:AC:GP:DS	0/1:0:2:1.26626e-09,0.9999,0.000100479:1.0001

```

The coverage for my new sample is higher than my previous sample.  So, this should help with the imputation.  However, I currently don't know if this was intentionally increased for all runs, or there is random variation among the small libraries for each run.

*I decided to trim it out of my FDA MedWatch report.  However, I thought it might still be worth noting the following:* For example, in my 23andMe report, [non-genetic factors](http://cdwscience.blogspot.com/2019/12/prs-results-from-my-genomics-data.html) contribute more than genetic factors to my risk for Type 2 Diabetes (such as BMI, etc.).  Possibly similarly, my “critical” COVID-19 risk was average, but I thought age was one of the strongest risk factors (and I would therefore consider myself lower risk).  If being used to make medical decisions, then I think that would need to be made clear.  Plus, if you use my earlier lcWGS sample, my percentage for “critical” COVID-19 risk changes from 49th to 29th.  So, I would say there is also an issue with using lcWGS for the Polygenic Risk Score analysis, which might be an even bigger problem than non-genetic risk factors in this specific example.

I can currently access a .vcf file and .bam alignment file.  However, I cannot yet download the original .fastq files (unlike my 1st lcWGS sample).  Also, I have Microbiome result for my [1st sample](https://github.com/cwarden45/DTC_Scripts/blob/master/Nebula/Nebula_Microbiome.pdf), but not my [2nd sample](https://github.com/cwarden45/DTC_Scripts/blob/master/Nebula/Sample2/Nebula_Microbiome.PNG).
