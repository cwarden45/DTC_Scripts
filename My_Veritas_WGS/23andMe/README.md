Please see this [blog post](http://cdwscience.blogspot.com/2012/06/my-23andme-results-getting-free-second.html) to learn more about the Perl scripts

**Perl Script Notes**
- hg19 is no longer the latest reference sequence, but it is what was used for my WGS sample and you can get hg19 annotationsfrom SeattleSeq here: http://snp.gs.washington.edu/SeattleSeqAnnotation138/
- SeattleSNP didn't recognize some alleles from 23andMe (mostly indels)

**New Scripts**
- **23andMe_to_VCF.py** - converts 23andMe raw format to VCF (`python 23andMe_to_VCF.py --input=[23andMe file]`, if you've run the Vertias WGS scripts.  Type `python 23andMe_to_VCF.py --help` for more information)
- **VCF_recovery.py** - reports discordant variants from a smaller set of variants, using two VCF files.  To identify 23andMe variants not found in Veritas WGS .vcf file run `python python VCF_recovery.py --smallVCF=[23andMe].vcf --largeVCF=../[VeritasID].vcf`.  Type `python VCF_recovery.py --help` for more information)

⋅You'll want to check the 23andMe data portal for variants with "D" or "I" annotations, since you  may consider your actual genotype is counter-intuitive (and you can't tell if you have an insertion or deletion from the raw data output alone).  So, unless you happen to have the same genotype as me, you may have to modify the python code (and possibly add insertion sequences from [dbSNP](http://www.ncbi.nlm.nih.gov/snp)).  More specifically, I skip "DD" and "II" genotypes (since they usually match the reference) - so, that reduces the amount of the code that needs to be modified (and deleterious indels on autosomal chromosomes are probably more likely to be heterozygous in normal subjects anyways), but I'm not actually checking the WGS genotype for most indels on the 23andMe chip.
