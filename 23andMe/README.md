### For Research Purposes Only! ###

Please see this [blog post](http://cdwscience.blogspot.com/2012/06/my-23andme-results-getting-free-second.html) to learn more about the Perl scripts.

The [Genes_for_Good](https://github.com/cwarden45/DTC_Scripts/tree/master/Genes_for_Good) section has some comparisons for overlapping sites, and then HLA typing (for Veritas Whole Genome Sequencing, Genos Exome Sequencing, and 23andMe / Genes for Good Genotyping).  However, this is mostly a way to save similar code.

**Perl Script Notes**
- hg19 is no longer the latest reference sequence, but it is what was used for my WGS sample and you can get hg19 annotationsfrom SeattleSeq here: http://snp.gs.washington.edu/SeattleSeqAnnotation138/
- SeattleSNP didn't recognize some alleles from 23andMe (mostly indels)

**New Scripts**
 * **23andMe_to_VCF.py** - converts 23andMe raw format to VCF (`python 23andMe_to_VCF.py --input=[23andMe file] --genome_ref=[../hg19.fasta] --vcf=[23andMe.vcf]`.  Type `python 23andMe_to_VCF.py --help` for more information)
   * ***WARNING***: I hard-coded parts of this script to compare my V3 23andMe array to my freebayes Vertias WGS .vcf file.  So, **this will not work if you were recently genotyped with a V5 array** (and the indel format is different than you might expect for some other variant callers).
   * The array version is also comment #1 under "Personal Notes" below
 * **VCF_recovery.py** - reports discordant variants from a smaller set of variants, using two VCF files.  To identify 23andMe variants not found in Veritas WGS .vcf file run `python python VCF_recovery.py --smallVCF=[23andMe].vcf --largeVCF=../[VeritasID].vcf`.  Type `python VCF_recovery.py --help` for more information)

You'll want to check the 23andMe data portal for variants with "D" or "I" annotations, since you can't tell if you have an insertion or deletion from the raw data output alone (although this is also the format for "Plus" genotypes used by Illumina's GenomeStudio).  So, unless you happen to have the same genotype as me, you'll have to modify the python code (and possibly add insertion sequences from [dbSNP](http://www.ncbi.nlm.nih.gov/snp)).  More specifically, I skip "DD" and "II" genotypes (since they usually match the reference) - so, that reduces the amount of the code that needs to be modified (and deleterious indels on autosomal chromosomes are probably more likely to be heterozygous in normal subjects anyways), but I'm not actually checking the WGS genotype for most indels on the 23andMe chip.

**Other Notes**

* Independent of these scripts, you can also test uploading your raw 23andMe data into [DNA.LAND](https://dna.land/)
* With the caveat that the conversion isn't perfect (such as the missing indels), you can upload the .vcf file into the Variant Effect Predictor ([VEP](http://grch37.ensembl.org/Homo_sapiens/Tools/VEP))
  * Please note that it may take a little while to get your VEP result (for me, it was more than 1 hour).
* [Family Tree DNA](https://www.familytreedna.com/) allows you to upload your 23andMe data to search for matches (should be available within 24 hours), but you have to may extra for functionality ($19 for ancestry predictions, chromosome view, etc.)
  * Family Tree DNA "myOrigins" indicated I was 95% European and 3% African
  * *However, please be aware that I got a strange match result, which I am looking into more.*
  
**Personal Notes**
  
I've recently been asking family members to undergo DNA profiling, and I have *only* been asking them to do genotyping through 23andMe (and/or [Genes_for_Good](https://genesforgood.sph.umich.edu/), if they wanted a *free* raw dataset with limited interpretation).  In contrast, I have been testing other companies, and I haven't been recommending them to other people.  So, I think that is a relatively good endorsement for 23andMe.
  
However, I also have some things that I believe can be improved upon:

**1)** I have a V3 chip and new relatives have the V5 chip.  However, I noticed that the carrier reports were't provided to my mom.  In fact, I couldn't even check the genotype for [rs121908769](https://www.ncbi.nlm.nih.gov/snp/rs121908769#variant_details) in her raw data on the V5 chip (to trace the source of my cystic fibrosis variant).  If informative sites were removed from newer chips, then that seems problematic.

**2)** I think they should be more conservative when reporting genetic matches.  They essentually do this with the "close match" designation, but I think they should have you opt-in into seeing more distant matches (and not include those counts on the home page).  This may mean some people don't have any matches, but I think people's first impression of the data should focus on what is most significant (and they can then learn more about genetics subsequent times that they visit the website).

**3)** The 23andMe ads that I see on TV bother me because I think they can give people a false sense of confidence in their results.  As I mention in a [subsection](https://github.com/cwarden45/DTC_Scripts/tree/master/23andMe/Ancestry_plus_1000_Genomes) of this page, 2 out of the 3 results that seemed strange to me could go away if I increase the confidence threshold.  However, kind of like the genetic matches, I think the results should start with the higher confidence results, and allow people to choose to view lower confidence results (instead of the other way around).

**4)** It isn't just 23andMe, but "*HLA-DQA1 and HLA-DQB1" Celiac Disease risk assessment*" uses 2 SNPs that are not actually within the RefSeq coding genome annotations, and that may be confusing to some people (and, due to frequent recombination / re-arrangemnets in the region, I'm not even sure if HLA-DQB1 is usually the closest gene to rs7454108, if you had a full chromosome diploid assembly for your own genome).  While the organization of my GitHub notes is probably also a little confusing to people, you may be able to get a better idea about what I mean at the bottom of [my GitHub AncestryDNA section](https://github.com/cwarden45/DTC_Scripts/tree/master/AncestryDNA), underneath the table of HLA assignments made with multiple markers / reads with varying technologies and methods.

For point #4, I had a concern that  the HLA-DQA1 / HLA-DQB1 genes shouldn't be emphasized on the [front-page of the 23andMe website](https://www.23andme.com/) in the "meet your genes" format.  The website was recently changed to not highlight the 4 sets of genes, but I am concerned that the "live in the know" emphasis still has a similar general problem of representing most of the results that you would be getting from 23andMe with too much confidence and/or predictive power (customers need to have an expectation to critically evaluate results by learning more from the external links, realize that surprising results from some genomic models like [ancestry predictions](https://github.com/cwarden45/DTC_Scripts/tree/master/23andMe/Ancestry_plus_1000_Genomes) may not be completely precise, and use available information try to gauge the extent to which a reported assoication is predictive of you actually getting the disease).

**5)** I have one copy of the APOE E4 allele.  The "Scientific Details" report a >20% risk of Late-Onset AAlzheimer's Disease for individuals over 85, and there seems to be good reproducibility between gender (with a similar age range).  However, I would expect fewer individuals in that age bin, which I believe is corroborated by the [alzgene.org](http://www.alzgene.org/geneoverview.asp?geneid=85) cohort age distriution.  So, I think it would be best if we had a way to query the 23andMe database with various filtering strategies, similar to the freely available interface from [data.color.com](https://data.color.com/).  AlzGene also provides some sense of robustness with meta-analysis [between cohorts](http://www.alzgene.org/meta.asp?geneID=85) for 5 polymorphisms that can be selected from a pull-down menu, even though it importantly doesn't provide that information for the specific [rsID](https://www.ncbi.nlm.nih.gov/snp/rs429358) used to characterize the most commonly described E3/E4 variant (which I think is important information for people to have access to, although I think it is less reasonable for 23andMe to know about all possible datasets for all possible diseases/traits/genotypes, making links to external information from specialists and/or government resources very important).

*That being said, I should also emphasize why I was recommending family members be genotyped with 23andMe to begin with*:

**a)** You are provided access to a table of genotypes, which is compatible with free programs for additional analysis like [DNA.land](https://dna.land/), [GENOtatation](http://genotation.stanford.edu/), [GEDmatch](https://genesis.gedmatch.com/login1.php), etc (kind of like a 2nd opinion, if you think of it like that).

**b)** They do a good job of connecting you to the primary literature, encouraging you to learn more about genetics / biology / medicine.

**c)** Overall, I think they provide a relatively good visual interface for people people to get an initial intepretation of their results, for those that don't know how to code (and providing a way to encourage learning to program is also a useful life skill).  Plus, the 23andMe genotype file format is accepted by at least one command-line program for analysis, [plink](https://www.cog-genomics.org/plink2/input).

**d)** They are helping conduct genomics research, and publish papers with their findings.  So, even though I am saying there is room for improvement, they have good intentions.

**e)** No additional charges after the initial costs.
