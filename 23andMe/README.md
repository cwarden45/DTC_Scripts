### For Research Purposes Only! ###

Please see this [blog post](http://cdwscience.blogspot.com/2012/06/my-23andme-results-getting-free-second.html) to learn more about the Perl scripts.

The [Genes_for_Good](https://github.com/cwarden45/DTC_Scripts/tree/master/Genes_for_Good) section has some comparisons for overlapping sites, and then HLA typing (for Veritas Whole Genome Sequencing, Genos Exome Sequencing, and 23andMe / Genes for Good Genotyping).  However, this is mostly a way to save similar code.

**Perl Script Notes**
- hg19 is no longer the latest reference sequence, but it is what was used for my WGS sample and you can get hg19 annotationsfrom SeattleSeq here: http://snp.gs.washington.edu/SeattleSeqAnnotation138/
- SeattleSNP didn't recognize some alleles from 23andMe (mostly indels)

**New Scripts**
- **23andMe_to_VCF.py** - converts 23andMe raw format to VCF (`python 23andMe_to_VCF.py --input=[23andMe file]`, if you've run the Vertias WGS scripts.  Type `python 23andMe_to_VCF.py --help` for more information)
- **VCF_recovery.py** - reports discordant variants from a smaller set of variants, using two VCF files.  To identify 23andMe variants not found in Veritas WGS .vcf file run `python python VCF_recovery.py --smallVCF=[23andMe].vcf --largeVCF=../[VeritasID].vcf`.  Type `python VCF_recovery.py --help` for more information)

You'll want to check the 23andMe data portal for variants with "D" or "I" annotations, since you can't tell if you have an insertion or deletion from the raw data output alone (although this is also the format for "Plus" genotypes used by Illumina's GenomeStudio).  So, unless you happen to have the same genotype as me, you'll have to modify the python code (and possibly add insertion sequences from [dbSNP](http://www.ncbi.nlm.nih.gov/snp)).  More specifically, I skip "DD" and "II" genotypes (since they usually match the reference) - so, that reduces the amount of the code that needs to be modified (and deleterious indels on autosomal chromosomes are probably more likely to be heterozygous in normal subjects anyways), but I'm not actually checking the WGS genotype for most indels on the 23andMe chip.

**Other Notes**

* Independent of these scripts, you can also test uploading your raw 23andMe data into [DNA.LAND](https://dna.land/)
* With the caveat that the conversion isn't perfect (such as the missing indels), you can upload the .vcf file into the Variant Effect Predictor ([VEP](http://grch37.ensembl.org/Homo_sapiens/Tools/VEP))
  * Please note that it may take a little while to get your VEP result (for me, it was more than 1 hour).
* [Family Tree DNA](https://www.familytreedna.com/) allows you to upload your 23andMe data to search for matches (should be available within 24 hours), but you have to may extra for functionality ($19 for ancestry predictions, chromosome view, etc.)
  * Family Tree DNA "myOrigins" indicated I was 95% European and 3% African
  * *However, please be aware that I got a strange match result, which I am looking into more.*
  
**Personal Notes**
  
I've recently been asking family members to undergo DNA profiling, and I have **only** been asking them to do genotyping through 23andMe (unlike myself, where I have been testing / comparing different companies).  So, I think that is a relatively good endorsement for 23andMe.
  
However, I also have some things that I believe can be improved upon:

**1)** I think they should be more conservative when reporting genetic matches.  They essentually do this with the "close match" desigation, but I think they should have you opt-in into seeing more distant matches (and not include those counts on the home page).  This may mean some people don't have any matches, but I think people's first impression of the data should focus on what is most significant (and they can then learn more about genetics subsequent times that they visit the website).

**2)** The 23andMe ads that I see on TV bother me because I think they can give people a false sense of confidence in their results.  As I mention in a [subsection](https://github.com/cwarden45/DTC_Scripts/tree/master/23andMe/Ancestry_plus_1000_Genomes) of this page, 2 out of the 3 results that seemed strange to me could go away if I increase the confidence threshold.  However, kind of like the genetic matches, I think the results should start with the higher confidence results, and allow people to choose to view lower confidence results (instead of the other way around).

**3)** It isn't just 23andMe, but "HLA-DQA1 and HLA-DQB1" Celiac Disease risk assessment" using 2 SNPs that are not actually within the coding genome annotations may be confusing to some people.  While the organization of my GitHub notes is probably also a little confusing to people, you can get a better idea about what I mean at the bottom of the [AncestryDNA page](https://github.com/cwarden45/DTC_Scripts/tree/master/AncestryDNA), underneath the table of HLA assignments made with multiple markers / reads with varying technologies and methods.  So, I don't think this should really be on the front-page in the "meet your genes" format.  Also, the asteric next to celiac disease, is actually a notice about the 3 SNPs for the BRCA1/2 risk assessment.
